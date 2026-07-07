# -*- coding: utf-8 -*-
from __future__ import print_function

import os
import gc
import gzip
import pickle
import numpy as np
import h5py
from scipy.io import loadmat
from mvpa2.datasets.base import Dataset
from mvpa2.algorithms.hyperalignment import Hyperalignment

# =========================
# paths
# =========================
TS_ROOT = r"path/to/your/data\function7T_timeseries"
CORTEX_INDEX_MAT = r"path/to/your/data\Parcellation\hyperalignment\cortexIndex.mat"
SCHAEFER_LABEL_MAT = r"path/to/your/data\Parcellation\hyperalignment\cortexSchaeferLabel.mat"
OUT_DIR = r"path/to/your/data\hyperalignment\hyperalignment_conn_schaefer400"

# cortex column ranges
L_START, L_END = 0, 54216
R_START, R_END = 54216, 108441

MIN_VERTICES_PER_PARCEL = 5
EXPECTED_SUBCORTEX_VOXELS = 17799
EPS = 1e-6
# =========================
# runtime knobs
# =========================

ALPHA = 1.0
BLOCK_MAX_VERTICES = 8000          # maximum total vertices per block
CHECKPOINT_EVERY_PARCELS = 1      # checkpoint every N parcels
# ====== New: subcortex PCA configuration ======
def ensure_dir(path):
    if not os.path.exists(path):
        os.makedirs(path)


def squeeze_1d(x):
    x = np.asarray(x).squeeze()
    if x.ndim != 1:
        x = x.reshape(-1)
    return x


def to_zero_based(idx):
    idx = squeeze_1d(idx).astype(np.int64)
    if idx.min() >= 1:
        idx = idx - 1
    return idx


def list_subjects(ts_root):
    subs = []
    for name in sorted(os.listdir(ts_root)):
        p = os.path.join(ts_root, name)
        if not os.path.isdir(p):
            continue
        if os.path.exists(os.path.join(p, "TS.mat")) and os.path.exists(os.path.join(p, "subcortex_TS.mat")):
            subs.append(name)
    return subs


def load_index_and_labels():
    idx_mat = loadmat(CORTEX_INDEX_MAT)
    lab_mat = loadmat(SCHAEFER_LABEL_MAT)

    left_list = to_zero_based(idx_mat["left_list"])
    right_list = to_zero_based(idx_mat["right_list"])

    left_label_full = squeeze_1d(lab_mat["leftSchaeferLabel"]).astype(np.int64)
    right_label_full = squeeze_1d(lab_mat["rightSchaeferLabel"]).astype(np.int64)

    left_label_ts = left_label_full[left_list]
    right_label_ts = right_label_full[right_list]

    if left_label_ts.shape[0] != (L_END - L_START):
        raise ValueError("Left label length mismatch: {} vs {}".format(left_label_ts.shape[0], (L_END - L_START)))
    if right_label_ts.shape[0] != (R_END - R_START):
        raise ValueError("Right label length mismatch: {} vs {}".format(right_label_ts.shape[0], (R_END - R_START)))

    return left_label_ts, right_label_ts


def build_parcel_columns(left_label_ts, right_label_ts):
    parcel_ids = sorted(set(np.unique(left_label_ts)).union(set(np.unique(right_label_ts))))
    parcel_ids = [int(p) for p in parcel_ids if p > 0]

    parcel_cols = {"L": {}, "R": {}}
    for pid in parcel_ids:
        l_local = np.where(left_label_ts == pid)[0]
        r_local = np.where(right_label_ts == pid)[0]

        if l_local.size >= MIN_VERTICES_PER_PARCEL:
            parcel_cols["L"][pid] = (l_local + L_START).astype(np.int32)
        if r_local.size >= MIN_VERTICES_PER_PARCEL:
            parcel_cols["R"][pid] = (r_local + R_START).astype(np.int32)

    return parcel_cols

def read_ts_columns(ts_mat_file, cols_global):
    cols_global = np.asarray(cols_global, dtype=np.int64)
    with h5py.File(ts_mat_file, "r") as f:
        if "TS" not in f:
            raise KeyError("{} does not contain TS".format(ts_mat_file))
        d = f["TS"]

        if len(d.shape) != 2:
            raise ValueError("Unexpected TS ndim: {}, shape={}".format(len(d.shape), d.shape))

        # Automatically determine time axis: time dimension is usually much smaller than vertex dimension
        if d.shape[0] <= d.shape[1]:
            # (T, V)
            x = d[:, cols_global]
        else:
            # (V, T)
            x = d[cols_global, :].T

    x = np.asarray(x, dtype=np.float32)
    return x



def _as_list(x):
    if isinstance(x, (list, tuple)):
        return list(x)
    if isinstance(x, np.ndarray):
        if x.dtype == np.object_:
            return list(x.flat)
        return [x]
    return [x]


def _to_text(x):
    # robust conversion for order names in py2
    if isinstance(x, np.ndarray):
        try:
            x = x.tolist()
        except Exception:
            pass
    if isinstance(x, (list, tuple)):
        return "".join([str(i) for i in x])
    try:
        return str(x)
    except Exception:
        return repr(x)


def _load_subcortex_mat_scipy(path):
    m = loadmat(path, struct_as_record=False, squeeze_me=True)

    if "subcortex_TS" not in m:
        raise KeyError("{} does not contain subcortex_TS".format(path))

    st = m["subcortex_TS"]

    # common case: matlab struct object with attributes
    if hasattr(st, "data") and hasattr(st, "order"):
        data_cells = st.data
        order_cells = st.order
    # fallback: dict-like
    elif isinstance(st, dict) and ("data" in st) and ("order" in st):
        data_cells = st["data"]
        order_cells = st["order"]
    else:
        raise ValueError("Unsupported subcortex_TS format in {}".format(path))

    data_list = _as_list(data_cells)
    order_list = _as_list(order_cells)

    if len(data_list) != len(order_list):
        raise ValueError("subcortex data/order length mismatch in {}".format(path))

    blocks = []
    order_names = []
    t_ref = None

    for arr, name in zip(data_list, order_list):
        a = np.asarray(arr, dtype=np.float32)

        if a.ndim != 2:
            raise ValueError("subcortex block must be 2D, got {}".format(a.shape))

        # Put time dimension as axis 0 (time dimension is usually longer)
        if a.shape[0] < a.shape[1]:
            a = a.T

        # Within the same subject, all blocks must have the same time length
        if t_ref is None:
            t_ref = a.shape[0]
        elif a.shape[0] != t_ref:
            raise ValueError("subcortex block time dimension mismatch: {}".format(a.shape))

        blocks.append(a)
        order_names.append(_to_text(name))

    S = np.concatenate(blocks, axis=1)  # T x Nsub
    return S, order_names


def load_subcortex_matrix(subcortex_mat_file):
    try:
        return _load_subcortex_mat_scipy(subcortex_mat_file)
    except NotImplementedError:
        raise RuntimeError(
            "subcortex_TS.mat may be MATLAB v7.3. Please use mat73.loadmat for this file."
        )

def _clean_numeric(x):
    """
    old numpy compatible finite cleanup
    """
    x = np.asarray(x, dtype=np.float32)
    x = np.nan_to_num(x)          # old version only supports this
    x[np.isposinf(x)] = 0.0
    x[np.isneginf(x)] = 0.0
    return x.astype(np.float32)


def fast_fc(subcortex_ts, cortex_ts):
    """
    input:
      subcortex_ts: T x Ns
      cortex_ts:    T x Nv
    output:
      FC: Ns x Nv (Fisher-z corr)
    """
    if subcortex_ts.shape[0] != cortex_ts.shape[0]:
        raise ValueError("Time points mismatch")

    S = _clean_numeric(subcortex_ts)
    C = _clean_numeric(cortex_ts)

    T = S.shape[0]
    fc = (S.T.dot(C)) / float(max(T - 1, 1))  # Ns x Nv
    fc = np.clip(fc, -1.0 + EPS, 1.0 - EPS)
    fc = np.arctanh(fc).astype(np.float32)
    return fc

def zscore_cols(x, eps=1e-8):
    """
    z-score each column of the matrix (axis=0)
    x: Ns x Nv
    """
    x = np.asarray(x, dtype=np.float32)
    mu = np.mean(x, axis=0, keepdims=True)
    sd = np.std(x, axis=0, keepdims=True)
    sd[sd < eps] = 1.0
    return ((x - mu) / sd).astype(np.float32)

def _make_parcel_blocks(parcel_dict, pids, max_vertices):
    """
    Group parcels into blocks by total vertex count, to avoid processing too many at once.
    """
    blocks = []
    cur = []
    cur_v = 0

    for pid in pids:
        nv = int(len(parcel_dict[pid]))

        # If a single parcel is too large, make it its own block
        if nv >= max_vertices:
            if cur:
                blocks.append(cur)
                cur = []
                cur_v = 0
            blocks.append([pid])
            continue

        if cur_v + nv > max_vertices and cur:
            blocks.append(cur)
            cur = [pid]
            cur_v = nv
        else:
            cur.append(pid)
            cur_v += nv

    if cur:
        blocks.append(cur)

    return blocks

def _build_global_parcel_plan(parcel_cols):
    # Global order: first left hemisphere pid ascending, then right hemisphere pid ascending
    plan = []
    for hemi_key, hemi_name in [("L", "left"), ("R", "right")]:
        for pid in sorted(parcel_cols[hemi_key].keys()):
            plan.append((hemi_key, hemi_name, int(pid)))
    return plan


def _init_subject_meta(subjects):
    return dict([
        (s, {
            "subject": s,
            "method": "connection_hyperalignment_parcelwise",
            "sample_axis": "subcortex_voxels",
            "feature_axis": "parcel_vertices",
            "subcortex_order": None,
            "n_subcortex_voxels": None
        }) for s in subjects
    ])


def _init_subject_buffer(subjects):
    return dict([(s, {"left": {}, "right": {}}) for s in subjects])


def _has_buffer_data(buf):
    for s in buf:
        if buf[s]["left"] or buf[s]["right"]:
            return True
    return False


def _compact_mapper_for_pickle(mapper):
    # Avoid writing recon cache (can be huge if triggered)
    if hasattr(mapper, "_recon"):
        mapper._recon = None

    # Optionally cast main numeric parameters to float32 to reduce disk usage
    if hasattr(mapper, "_proj") and (mapper._proj is not None):
        mapper._proj = np.asarray(mapper._proj, dtype=np.float32)
    if hasattr(mapper, "_offset_in") and (mapper._offset_in is not None):
        mapper._offset_in = np.asarray(mapper._offset_in, dtype=np.float32)
    if hasattr(mapper, "_offset_out") and (mapper._offset_out is not None):
        mapper._offset_out = np.asarray(mapper._offset_out, dtype=np.float32)

    return mapper

def _subject_dir(out_dir, subject):
    return os.path.join(out_dir, subject)

def _subject_shard_dir(out_dir, subject):
    return os.path.join(_subject_dir(out_dir, subject), "shards")

def _save_subject_shard_files(subjects, subj_meta, subj_buf, out_dir, tag):
    for subj in subjects:
        subject_dir = _subject_dir(out_dir, subj)
        shard_dir = _subject_shard_dir(out_dir, subj)
        ensure_dir(shard_dir)

        payload = {}
        payload.update(subj_meta[subj])
        payload["left"] = subj_buf[subj]["left"]
        payload["right"] = subj_buf[subj]["right"]

        out_file = os.path.join(
            shard_dir,
            "{}_connHA_schaefer400_{}.pkl.gz".format(subj, tag)
        )
        with gzip.open(out_file, "wb") as f:
            pickle.dump(payload, f, protocol=2)


    print("checkpoint saved (shard): {}".format(tag))


def _merge_subject_shards_to_final(subject, subj_meta, out_dir):
    shard_dir = _subject_shard_dir(out_dir, subject)
    if not os.path.exists(shard_dir):
        raise RuntimeError("Shard dir not found: {}".format(shard_dir))

    prefix = "{}_connHA_schaefer400_".format(subject)
    shard_files = sorted([
        fn for fn in os.listdir(shard_dir)
        if fn.startswith(prefix) and fn.endswith(".pkl.gz")
    ])

    if not shard_files:
        raise RuntimeError("No shard files found for subject {}".format(subject))

    final_obj = {}
    final_obj.update(subj_meta[subject])
    final_obj["left"] = {}
    final_obj["right"] = {}

    for fn in shard_files:
        p = os.path.join(shard_dir, fn)
        with gzip.open(p, "rb") as f:
            obj = pickle.load(f)
        final_obj["left"].update(obj.get("left", {}))
        final_obj["right"].update(obj.get("right", {}))

    out_file = os.path.join(
    _subject_dir(out_dir, subject),
    "{}_connHA_schaefer400.pkl.gz".format(subject)
    )
    with gzip.open(out_file, "wb") as f:
        pickle.dump(final_obj, f, protocol=2)

    print("saved final: {}".format(out_file))


def run_connection_hyperalignment(subjects, parcel_cols, out_dir, parcel_start=1, parcel_end=None):
    ensure_dir(out_dir)

    subj_meta = _init_subject_meta(subjects)
    subj_buf = _init_subject_buffer(subjects)
    plan = _build_global_parcel_plan(parcel_cols)
    total_parcels_all = len(plan)

    if parcel_end is None:
        parcel_end = total_parcels_all

    if parcel_start < 1 or parcel_end > total_parcels_all or parcel_start > parcel_end:
        raise ValueError("Invalid parcel range: start={}, end={}, total={}".format(
            parcel_start, parcel_end, total_parcels_all
        ))

    selected = plan[parcel_start - 1: parcel_end]
    selected_total = len(selected)

    # Mapping from global index to parcel for logging
    global_idx_map = {}
    for gi, (hk, _, pid) in enumerate(plan, 1):
        global_idx_map[(hk, pid)] = gi

    selected_pids = {"L": [], "R": []}
    for hk, _, pid in selected:
        selected_pids[hk].append(pid)

    print("Parcel range: {}-{} (selected {}/{})".format(
        parcel_start, parcel_end, selected_total, total_parcels_all
    ))

    processed_parcels = 0
    checkpoint_start_gid = None
    last_processed_gid = None

    # check subcortex order consistency across subjects
    ref_order = None
    for subj in subjects:
        sub_file = os.path.join(TS_ROOT, subj, "subcortex_TS.mat")
        S, order_names = load_subcortex_matrix(sub_file)

        if ref_order is None:
            ref_order = order_names
        else:
            if order_names != ref_order:
                raise ValueError("Subject {} has inconsistent subcortex order".format(subj))

        if S.shape[1] != EXPECTED_SUBCORTEX_VOXELS:
            print("Warning: subject {} subcortex voxel count = {}, expected {}".format(
                subj, S.shape[1], EXPECTED_SUBCORTEX_VOXELS
            ))

        subj_meta[subj]["subcortex_order"] = order_names
        subj_meta[subj]["n_subcortex_voxels"] = int(S.shape[1])

        del S
    gc.collect()


    for hemi_key, hemi_name in [("L", "left"), ("R", "right")]:
        pids = selected_pids[hemi_key]
        if len(pids) == 0:
            print("\n[{}] no selected parcels, skip".format(hemi_name))
            continue

        blocks = _make_parcel_blocks(parcel_cols[hemi_key], pids, BLOCK_MAX_VERTICES)

        print("\n[{}] parcel count: {}, block count: {}".format(hemi_name, len(pids), len(blocks)))

        for bi, block_pids in enumerate(blocks, 1):
            block_nv = sum([len(parcel_cols[hemi_key][pid]) for pid in block_pids])
            print("[{}] block {}/{}: n_parcels={}, total_vertices={}".format(
                hemi_name, bi, len(blocks), len(block_pids), block_nv
            ))

            for pid in block_pids:
                cols = parcel_cols[hemi_key][pid]
                print("[{}] parcel {} (selected {}/{}, global {}/{}), n_vertices={}".format(
                    hemi_name,
                    pid,
                    processed_parcels + 1,
                    selected_total,
                    global_idx_map[(hemi_key, int(pid))],
                    total_parcels_all,
                    len(cols)
                ))

                dss = []
                valid_subs = []

                for subj in subjects:
                    ts_file = os.path.join(TS_ROOT, subj, "TS.mat")
                    sub_file = os.path.join(TS_ROOT, subj, "subcortex_TS.mat")

                    try:
                        cortex_ts = read_ts_columns(ts_file, cols)     # T x Nv
                        sub_ts, _ = load_subcortex_matrix(sub_file)    # T x Ns
                        fc = fast_fc(sub_ts, cortex_ts)                # Ns x Nv
                        fc = zscore_cols(fc)

                        dss.append(Dataset(fc))
                        valid_subs.append(subj)

                        del cortex_ts, sub_ts, fc
                    except Exception as e:
                        print("  skip subject {}: {}".format(subj, e))

                if len(dss) < 2:
                    print("  parcel {} has <2 valid subjects, skipped".format(pid))
                    processed_parcels += 1
                    continue

                ha = Hyperalignment(
                    alpha=ALPHA,
                    level2_niter=1,
                    zscore_all=False,
                    zscore_common=True
                )

                try:
                    mappers = ha(dss)
                except Exception as e:
                    print("  parcel {} hyperalignment failed: {}".format(pid, e))
                    del dss, ha
                    gc.collect()
                    processed_parcels += 1
                    continue

                for subj, mapper in zip(valid_subs, mappers):
                    try:
                        mapper_obj = _compact_mapper_for_pickle(mapper)
                        subj_buf[subj][hemi_name][int(pid)] = {
                            "cols_global": cols.astype(np.int32),
                            "mapper": mapper_obj
                        }
                    except Exception as e:
                        print("  subject {} parcel {} mapper export failed: {}".format(subj, pid, e))

                del dss, mappers, ha
                gc.collect()

                processed_parcels += 1

                # checkpoint: save shards and clear memory cache
                if checkpoint_start_gid is None:
                    checkpoint_start_gid = global_idx_map[(hemi_key, pid)]

                last_processed_gid = global_idx_map[(hemi_key, pid)]

                if CHECKPOINT_EVERY_PARCELS > 0 and (processed_parcels % CHECKPOINT_EVERY_PARCELS == 0):
                    tag = "ckpt_{:04d}_{:04d}".format(checkpoint_start_gid, last_processed_gid)
                    _save_subject_shard_files(subjects, subj_meta, subj_buf, out_dir, tag)
                    subj_buf = _init_subject_buffer(subjects)
                    checkpoint_start_gid = None
                    gc.collect()

    # flush tail
    if _has_buffer_data(subj_buf):
        if checkpoint_start_gid is not None and last_processed_gid is not None:
            tag = "tail_{:04d}_{:04d}".format(checkpoint_start_gid, last_processed_gid)
        else:
            tag = "tail"
        _save_subject_shard_files(subjects, subj_meta, subj_buf, out_dir, tag)
        subj_buf = _init_subject_buffer(subjects)
        gc.collect()

    # # Merge shards into final per-subject files
    # for subj in subjects:
    #     _merge_subject_shards_to_final(subj, subj_meta, out_dir)

def main(parcel_start=1, parcel_end=None):
    ensure_dir(OUT_DIR)

    left_label_ts, right_label_ts = load_index_and_labels()
    subjects = list_subjects(TS_ROOT)

    print("Found subjects: {}".format(len(subjects)))
    if len(subjects) != 170:
        print("Warning: subject count is not 170, please check TS_ROOT")

    parcel_cols = build_parcel_columns(left_label_ts, right_label_ts)
    run_connection_hyperalignment(
        subjects, parcel_cols, OUT_DIR,
        parcel_start=parcel_start, parcel_end=parcel_end
    )
main(parcel_start=69, parcel_end=100)