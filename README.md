# Network-specific subcortical parcellation and healthy aging

MATLAB and Python analysis code for connectivity-based hyperalignment, group and individual subcortical parcellation, age/cognition prediction, network comparisons, spin tests, and task-fMRI validation. The current seven-network solution uses `K = [2, 2, 3, 5, 3, 6, 3]`: 24 parcels per hemisphere, **48 parcels in total** (accumbens: 2, amygdala: 2, caudate: 3, hippocampus: 5, pallidum: 3, putamen: 6, thalamus: 3 per hemisphere). The scripts are organized by analysis step; they are research code, not a software package.

## Requirements and data

- MATLAB R2019b (including Statistics and Machine Learning and Image Processing toolboxes); Python 3.8 with NumPy, SciPy, pandas, h5py, scikit-learn and PyMVPA (`mvpa2`).
- External code used by these scripts: **CBIG**, **LIBSVM**, **Tian et al. (2020) Subcortex Functions** (including the spectral-clustering, image-I/O and subcortical utilities called in the MATLAB scripts), `cifti-matlab`, a `munkres` implementation, and **BrainNet Viewer** for the optional visualization script. These dependencies are referenced by function name in the scripts and are not copied into this repository.
- Input datasets: [HCP](https://www.humanconnectome.org/study/hcp-young-adult), [Cam-CAN](https://opendata.mrc-cbu.cam.ac.uk/projects/camcan/) and [SALD](https://fcon_1000.projects.nitrc.org/indi/retro/sald.html). Obtain them from their providers and follow the applicable access and data-use terms. Imaging data and participant-level results are not included here.

## Analysis order and outputs

| Step | Code | Main intermediate output |
| --- | --- | --- |
| 1. Hyperalignment | `python/hyperalignment/` | Parcel-wise mappers and aligned connectivity fingerprints |
| 2. K selection and group parcellation | `matlab/k_selection/`, `matlab/group_parcellation/` | Reproducibility/symmetry summaries and 48-label group atlases |
| 3. Individualization | `matlab/individualization/` | Subject fingerprints, SVM probability maps, individual labels and parcel sizes |
| 4. Prediction and interpretation | `matlab/prediction/`, `python/age/`, `python/cognitive/`, `matlab/age/`, `matlab/cognitive/` | Feature tables, repeated splits, CBIG KRR results and feature-weight summaries |
| 5. Network/task validation | `matlab/evaluation/`, `matlab/spin_test/`, `matlab/task_validation/` | Network Dice matrices, spin parcellations and task eta-squared summaries |
| 6. Corrected inference | `python/statistics/` | Nadeau–Bengio corrected comparison table and 21-pair spin-test table, each with BH-FDR `q` values |

## Script guide

| Script | Purpose |
| --- | --- |
| `python/hyperalignment/train_hyperalignment.py` | Fit connectivity-based hyperalignment mappers from HCP time series. |
| `python/hyperalignment/apply_hyperalignment.py` | Apply mappers and export aligned connectivity fingerprints. |
| `matlab/k_selection/evaluate_reproducibility.m` | Estimate split-half parcellation reproducibility over K. |
| `matlab/k_selection/evaluate_symmetry.m` | Evaluate left–right parcellation symmetry over K. |
| `matlab/group_parcellation/build_group_parcellations.m` | Cluster group connectivity fingerprints for seven cortical networks. |
| `matlab/group_parcellation/combine_nuclei.m` | Assemble nucleus-level labels into whole-subcortex group maps. |
| `matlab/individualization/build_individual_fingerprints.m` | Compute Cam-CAN individual connectivity fingerprints. |
| `matlab/individualization/select_training_subjects.m` | Select the individualization training cohort. |
| `matlab/individualization/run_individualization.m` | Dilate group parcels, train/test SVMs and reconstruct individual labels. |
| `matlab/individualization/extract_parcel_sizes.m` | Measure individual parcel sizes and assemble subject information. |
| `matlab/prediction/export_parcel_features.m` | Export parcel-size feature matrices for prediction. |
| `python/age/predictive_model/split_repeated_cv.py` | Create repeated age-prediction splits. |
| `python/age/predictive_model/pickle2mat.py` | Convert saved age split/result arrays for MATLAB. |
| `matlab/age/predictive_model/gen_kfold.m` | Generate age-prediction fold definitions. |
| `matlab/age/predictive_model/setup.m` | Prepare and run age CBIG KRR jobs. |
| `matlab/age/evaluation/extract_best_accuracy.m` | Extract age-prediction scores. |
| `matlab/age/evaluation/summarize_acc.m` | Summarize age-prediction scores across runs. |
| `matlab/age/weight/pfm.m` | Compute per-network age predictive feature maps. |
| `matlab/age/weight/all_nets_prediction_pfm.m` | Aggregate age feature weights across networks and nuclei. |
| `matlab/age/weight/3_d_visualization/bnv.m` | Prepare age-weight brain visualization. |
| `python/cognitive/predictive_model/make_data_input.py` | Construct cognition prediction input tables. |
| `python/cognitive/predictive_model/split_repeated_cv.py` | Create repeated cognition-prediction splits. |
| `python/cognitive/predictive_model/pickle2mat.py` | Convert cognition split/result arrays for MATLAB. |
| `matlab/cognitive/predictive_model/gen_kfold.m` | Generate cognition-prediction fold definitions. |
| `matlab/cognitive/predictive_model/setup.m` | Prepare and run cognition CBIG KRR jobs. |
| `matlab/cognitive/evaluation/extract_best_accuracy_cog.m` | Extract cognition-prediction scores. |
| `matlab/cognitive/evaluation/summarize_acc.m` | Summarize cognition-prediction scores across runs. |
| `matlab/cognitive/weight/all_nets_prediction_pfm.m` | Aggregate cognition feature weights by network and nucleus. |
| `matlab/evaluation/network_similarity.m` | Calculate Dice similarity between network-specific atlases. |
| `matlab/spin_test/generate_null_parcellations.m` | Build network spin-null parcellations. |
| `matlab/task_validation/evaluate_task_eta_squared.m` | Compare task activation eta-squared for observed and null parcellations. |
| `python/statistics/corrected_tests.py` | Implement Nadeau–Bengio corrected resampled t tests, empirical spin P values and BH-FDR. |
| `python/statistics/run_statistics.py` | Convert run-level or 21-pair CSV inputs into corrected inference tables. |
| `python/controls/train_only_controls.py` | Fit nuisance/volume adjustment on training data and compute Haufe transforms. |
| `matlab/utils/bilateral_symmetry_munkres.m` | Match left/right labels and calculate symmetry. |
| `matlab/utils/cal_fcs.m` | Calculate connectivity fingerprints. |
| `matlab/utils/cal_roi_signal_ts.m` | Average time series within atlas regions. |
| `matlab/utils/getBoundary.m` | Find parcel boundaries. |
| `matlab/utils/getNeighbors.m` | Find neighboring voxels/labels. |
| `matlab/utils/iteration_Dice_munkres.m` | Match parcels and compute Dice similarity. |
| `matlab/utils/recon_symmat.m` | Reconstruct a symmetric matrix from its vector form. |
| `matlab/utils/symmat2vec.m` | Vectorize a symmetric matrix. |
| `matlab/utils/repo_path.m` | Resolve repository-relative `data/` and `results/` paths in MATLAB. |

## Parameters and statistical inputs

Hyperalignment uses `ALPHA = 1.0` and Schaefer-400 parcel labels in the supplied code. Group K is given above. Individualization dilates labels by one voxel (`DilThresh = 1`) and reconstructs 48 parcels. Age and cognition KRR run 100 repetitions; the cognition setup specifies five inner folds, a correlation kernel and the lambda grid defined in `matlab/cognitive/predictive_model/setup.m`. The age script sets its lambda grid in `matlab/age/predictive_model/setup.m`. SVM training/testing uses the external functions called by `matlab/individualization/run_individualization.m`; their model-specific options are set by those functions.

The spin code is configured for 1,000 rotations. `python/statistics/run_statistics.py spin` expects `pair,observed` rows for the 21 unique unordered pairs of `VIS, SMN, DAN, VAN, LIM, FPN, DMN`, followed by a null CSV with those pair names as columns and one rotation per row. It computes left-tailed empirical P values and BH-FDR q values. The `nb` mode expects one score row per repeated run plus an explicit `model_a,model_b` comparison CSV; it applies the Nadeau–Bengio correction and BH-FDR. Its default test/train ratio is 0.25. Example commands:

```text
python python/statistics/run_statistics.py spin --scores data/spin_observed.csv --null data/spin_null.csv --output results/spin_fdr.csv
python python/statistics/run_statistics.py nb --scores data/run_level_scores.csv --comparisons data/comparisons.csv --output results/nb_fdr.csv
```

Use the manuscript citation when sharing results, and cite the datasets and external toolboxes as required by their providers. 
