# Purpose: apply hyperalignment.
# Input: idx_mat = loadmat(CORTEX_INDEX_MAT); lab_mat = loadmat(SCHAEFER_LABEL_MAT)
# Output: savemat(mat_path, {"FCS": FCS})
# Dependencies: See README.md.
# -*- coding: utf-8 -*-
from __future__ import print_function
from pathlib import Path
REPO_ROOT = Path(__file__).resolve().parents[2]
import os

import os
import gc
import gzip
import pickle
import numpy as np
import h5py
from scipy.io import loadmat, savemat
from mvpa2.datasets.base import Dataset

# =========================
# Repository-relative data and result paths
# =========================
TS_ROOT = str(REPO_ROOT / 'data/hcp/timeseries')
HA_MODELS_DIR = str(REPO_ROOT / 'results/hyperalignment/models')  # Directory where final merged pkl.gz files are stored
OUT_ROOT = str(REPO_ROOT / 'results/hyperalignment/forward') # Directory to store generated feature vectors and large FC matrices

CORTEX_INDEX_MAT = str(REPO_ROOT / 'data/templates/cortexIndex.mat')
SCHAEFER_LABEL_MAT = str(REPO_ROOT / 'data/templates/cortexSchaeferLabel.mat')
SEVEN_NET_MAT = str(REPO_ROOT / 'data/templates/SevenNet_ind.mat')

# Spatial parameters
L_START, L_END = 0, 54216
R_START, R_END = 54216, 108441
NUM_VERTICES = R_END
NUM_SUBCORTEX = 17799

# Nucleus pair names (2x7)
NUCLEI_NAMES = [
    "ACCUMBENS", "AMYGDALA", "CAUDATE", "HIPPOCAMPUS", 
    "PALLIDUM", "PUTAMEN", "THALAMUS"
]

def ensure_dir(p):
    if not os.path.exists(p):
        os.makedirs(p)

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

def _clean_numeric(x):
    x = np.asarray(x, dtype=np.float32)
    x = np.nan_to_num(x)
    x[np.isposinf(x)] = 0.0
    x[np.isneginf(x)] = 0.0
    return x

def zscore_cols(x, eps=1e-8):
    x = np.asarray(x, dtype=np.float32)
    mu = np.mean(x, axis=0, keepdims=True)
    sd = np.std(x, axis=0, keepdims=True)
    sd[sd < eps] = 1.0
    return ((x - mu) / sd).astype(np.float32)

def _as_list(x):
    if isinstance(x, (list, tuple)):
        return list(x)
    if isinstance(x, np.ndarray):
        if x.dtype == np.object_:
            return list(x.flat)
        return [x]
    return [x]

def symmat2vec(mat):
    """Extract lower triangular part of a symmetric matrix and return as a vector (excluding diagonal)"""
    # np.tril_indices expands lower triangular in row-major order, similar to MATLAB habit; if strict column-major is needed, change order
    # Here we use standard lower triangular expansion
    row, col = np.tril_indices(mat.shape[0], k=-1)
    return mat[row, col].astype(np.float32)

# =========================
# Load dependency files and index mappings
# =========================
def load_all_mappings():
    idx_mat = loadmat(CORTEX_INDEX_MAT)
    lab_mat = loadmat(SCHAEFER_LABEL_MAT)
    net_mat = loadmat(SEVEN_NET_MAT)

    left_list = to_zero_based(idx_mat["left_list"])
    right_list = to_zero_based(idx_mat["right_list"])

    left_label_full = squeeze_1d(lab_mat["leftSchaeferLabel"]).astype(np.int64)
    right_label_full = squeeze_1d(lab_mat["rightSchaeferLabel"]).astype(np.int64)

    left_label_ts = left_label_full[left_list]
    right_label_ts = right_label_full[right_list]

    # Build mapping from each Schaefer 400 subregion (1-400) to global 108441 columns
    parcel_cols_global = {}
    parcel_ids = sorted(set(np.unique(left_label_ts)).union(set(np.unique(right_label_ts))))
    parcel_ids = [int(p) for p in parcel_ids if p > 0]
    
    for pid in parcel_ids:
        l_local = np.where(left_label_ts == pid)[0]
        r_local = np.where(right_label_ts == pid)[0]
        pts = []
        if l_local.size > 0:
            pts.extend(l_local + L_START)
        if r_local.size > 0:
            pts.extend(r_local + R_START)
        if len(pts) > 0:
            parcel_cols_global[pid] = np.array(pts, dtype=np.int32)
            
    # Parse which subregions belong to each of the 7 networks
    # SevenNet_ind (7x1 cell array, cell values are 1D arrays of subregion indexes)
    seven_net_cells = net_mat['SevenNet_ind'].flatten()
    net_global_cols = []
    
    for i in range(7): # 0 to 6
        subregion_ids = np.asarray(seven_net_cells[i]).flatten()
        cols = []
        for pid in subregion_ids:
            if pid in parcel_cols_global:
                cols.extend(parcel_cols_global[pid].tolist())
        net_global_cols.append(np.array(sorted(cols), dtype=np.int32))
        
    return parcel_cols_global, net_global_cols

# =========================
# Main processing pipeline
# =========================
def process_forward_alignment():
    ensure_dir(OUT_ROOT)
    
    print("Loading index and network mapping...")
    parcel_cols_global, net_global_cols = load_all_mappings()
    print("Networks columns count:", [len(cols) for cols in net_global_cols])

    # List all subjects with available models
    all_subjects = []
    for s in sorted(os.listdir(HA_MODELS_DIR)):
        s_shard_dir = os.path.join(HA_MODELS_DIR, s, "shards")
        if os.path.isdir(s_shard_dir):
            all_subjects.append(s)
    
    # --- Check for resume capability ---
    subjects_to_run = []
    for subj in all_subjects:
        subj_out_dir = os.path.join(OUT_ROOT, subj)
        
        # Check whether all 7 .mat files and 1 .h5 file are complete
        is_complete = False
        if os.path.exists(subj_out_dir):
            all_mat_exist = all([os.path.exists(os.path.join(subj_out_dir, n + ".mat")) for n in NUCLEI_NAMES])
            h5_exist = os.path.exists(os.path.join(subj_out_dir, "{}_Aligned_FC.h5".format(subj)))
            if all_mat_exist and h5_exist:
                is_complete = True
                
        if not is_complete:
            subjects_to_run.append(subj)

    print("Found {} total subjects in model dir.".format(len(all_subjects)))
    print("Already processed: {}. Remaining to run: {}.".format(
        len(all_subjects) - len(subjects_to_run), 
        len(subjects_to_run)
    ))

    # Process only subjects that are not fully completed
    for subj in subjects_to_run:
        print("\nProcessing Subject: {}".format(subj))
        subj_out_dir = os.path.join(OUT_ROOT, subj)
        ensure_dir(subj_out_dir)
 
        # ==========================================
        # 1. Load time series required for computing original FC
        # ==========================================
        ts_file = os.path.join(TS_ROOT, subj, "TS.mat")
        sub_file = os.path.join(TS_ROOT, subj, "subcortex_TS.mat")
        
        if not os.path.exists(ts_file) or not os.path.exists(sub_file):
            print("  Missing time series for {}. Skipping.".format(subj))
            continue
            
        print("  Loading structural TS data...")
        # (We do not need to compute the whole global matrix at once; we can extract block by block)
        # Use h5py to read TS, and scipy to load subcortex
        sub_m = loadmat(sub_file, struct_as_record=False, squeeze_me=True)
        st = sub_m["subcortex_TS"]
        
        # Handle different scipy.io read formats
        if hasattr(st, "data") and hasattr(st, "order"):
            data_cells = st.data
        elif isinstance(st, dict) and ("data" in st):
            data_cells = st["data"]
        else:
            raise ValueError("Unsupported subcortex_TS format")

        sub_data_list = _as_list(data_cells)

        # Concatenate subcortical voxels horizontally to obtain full time series
        sub_blocks = []
        subcortex_voxels_count = [] 
        for arr in sub_data_list:
            a = np.asarray(arr, dtype=np.float32)
            if a.shape[0] < a.shape[1]:
                a = a.T
            sub_blocks.append(a)
            subcortex_voxels_count.append(a.shape[1])
            
        S_ts = np.concatenate(sub_blocks, axis=1) # T x 17799
        S_ts = _clean_numeric(S_ts)
        
        # Pre-allocate 17799 x 108441 array
        print("  Allocating 7GB memory matrix...")
        aligned_FC = np.zeros((NUM_SUBCORTEX, NUM_VERTICES), dtype=np.float32)
        covered_columns = np.zeros(NUM_VERTICES, dtype=bool)
        
        with h5py.File(ts_file, "r") as f_ts:
            d_ts = f_ts["TS"]
            T_cortex = d_ts.shape[0] if d_ts.shape[0] <= d_ts.shape[1] else d_ts.shape[1]
            
            # ==========================================
            # 2. Load hyperalignment model for this subject and apply Transform (iterate over shards)
            # ==========================================
            subj_shard_dir = os.path.join(HA_MODELS_DIR, subj, "shards")
            shard_files = sorted([f for f in os.listdir(subj_shard_dir) if f.endswith(".pkl.gz")])
            
            print("  Found {} shard mapper files, applying transformations...".format(len(shard_files)))
            
            for s_file in shard_files:
                model_path = os.path.join(subj_shard_dir, s_file)
                with gzip.open(model_path, "rb") as f_mdl:
                    subj_model = pickle.load(f_mdl)
                    
                # Process left and right hemispheres
                for hemi in ["left", "right"]:
                    if hemi not in subj_model: continue
                    parcel_dict = subj_model[hemi]
                    
                    for pid, payload in parcel_dict.items():
                        mapper = payload["mapper"]
                        cols_global = payload["cols_global"]
                        if np.any(covered_columns[cols_global]):
                            raise ValueError('Overlapping mapper shards; use one complete, non-overlapping run.')
                        covered_columns[cols_global] = True
                        
                        # Extract corresponding cortical time series (T x Nv)
                        if d_ts.shape[0] <= d_ts.shape[1]:
                            cortex_block = d_ts[:, cols_global]
                        else:
                            cortex_block = d_ts[cols_global, :].T
                            
                        C = _clean_numeric(np.asarray(cortex_block, dtype=np.float32))
                        
                        # Compute local FC for this parcel: Ns x Nv
                        fc_block = (S_ts.T.dot(C)) / float(max(S_ts.shape[0] - 1, 1))
                        fc_block = np.clip(fc_block, -1.0 + 1e-6, 1.0 - 1e-6)
                        fc_block = np.arctanh(fc_block).astype(np.float32)
                        
                        # [IMPORTANT] z-score columns of data entering the mapper (consistent with training)
                        fc_block_z = zscore_cols(fc_block)
                        
                        # Apply Forward Mapper projection
                        ds = Dataset(fc_block_z)
                        aligned_block = mapper.forward(ds).samples
                        
                        # Place into corresponding columns of the total array
                        aligned_FC[:, cols_global] = aligned_block
                        
        expected_columns = np.concatenate(list(parcel_cols_global.values()))
        if not np.all(covered_columns[expected_columns]):
            raise ValueError('Incomplete mapper coverage; refusing zero-filled aligned FC. Confirm any training-excluded small parcels explicitly.')
        # Free unused memory
        del S_ts, sub_blocks, sub_data_list
        gc.collect()
        
        # ==========================================
        # 3. Save the full aligned_FC as an h5 file for later query
        # ==========================================
        print("  Saving Full Aligned FC structure...")
        out_fc_path = os.path.join(subj_out_dir, "{}_Aligned_FC.h5".format(subj))
        with h5py.File(out_fc_path, "w") as f_out:
            f_out.create_dataset("aligned_FC", data=aligned_FC, compression="gzip")
            
        # ==========================================
        # 4. Build and extract network-wise similarity matrices from the aligned FC
        # ==========================================
        print("  Calculating similarity matrices...")
        
        # Determine offsets for each nucleus in the 17799 rows
        # Assumption: NUCLEI_NAMES [0] -> order L, R -> index 0, 1 -> subcortex_voxels_count[0], [1]
        nuclei_offsets = []
        cur_offset = 0
        for voxel_count in subcortex_voxels_count:
            nuclei_offsets.append((cur_offset, cur_offset + voxel_count))
            cur_offset += voxel_count
            
        # NUCLEI_NAMES fixed to 7, left and right brain totals 14 blocks.
        # Order is nucleus_1_L, nucleus_1_R, nucleus_2_L ... and so on.
        for idx_nucleus, n_name in enumerate(NUCLEI_NAMES):
            idx_L = idx_nucleus * 2
            idx_R = idx_nucleus * 2 + 1
            
            # FCS is a 2x8 cell: row 0 for Left, row 1 for Right
            FCS = np.empty((2, 8), dtype=object)
            
            # Inner loop for L / R rows
            for row, st_idx in enumerate([idx_L, idx_R]):
                row_start, row_end = nuclei_offsets[st_idx]
                
                # Extract connectivity matrix for this half-nucleus (Nv_nucleus x Total_cortex_vertices)
                fc_nucleus = aligned_FC[row_start:row_end, :]
                
                # Column 0: correlation across all cortical vertices, vectorized
                sim_all = np.corrcoef(fc_nucleus) # => (Nv_nucleus x Nv_nucleus)
                FCS[row, 0] = symmat2vec(sim_all)[..., None] # ensure nx1 array for MATLAB storage
                
                # Columns 1 ~ 7: correlation within each of the 7 SevenNet networks
                for net_idx in range(7):
                    cols_net = net_global_cols[net_idx]
                    fc_net = fc_nucleus[:, cols_net]
                    sim_net = np.corrcoef(fc_net)
                    FCS[row, net_idx + 1] = symmat2vec(sim_net)[..., None]
                    
            # Save .mat file for this nucleus
            mat_path = os.path.join(subj_out_dir, "{}.mat".format(n_name))
            savemat(mat_path, {"FCS": FCS})
            print("  -> Saved {}".format(n_name))
            
        del aligned_FC
        gc.collect()

if __name__ == "__main__":
    process_forward_alignment()
