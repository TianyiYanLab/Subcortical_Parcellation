Subcortical Network-Specific Parcellation Framework

This repository implements the methods from:

A Cortical Network-Specific Framework for Subcortical Parcellation Identifies Signatures of Healthy Aging

It provides a full pipeline for:

Network-defined subcortical parcellation
Connectivity-based hyperalignment
Spectral clustering segmentation
Individualized parcellation
Age and cognition prediction
Feature interpretation (Haufe transform)

Repository Structure
.
├── munkres/                  # Hungarian algorithm (cluster matching)
├── pySuStaIn-master/         # Disease progression / trajectory modeling (optional extension)
├── Yeo_CBIG/                 # Yeo 7-network cortical atlas
├── subcortex-master/         # Subcortical segmentation & masks
│
├── src/
│   ├── matlab/
│   │   ├── utils/
│   │   ├── aging/
│   │   └── cognitive/
│   │
│   └── python/
│       └── hyperalignment/
│
├── scripts/
├── notebooks/
└── docs/

Environment Setup

This project uses both MATLAB and Python.

1. MATLAB Environment
Required MATLAB Version
MATLAB >= R2018b 
Required Toolboxes

Make sure the following toolboxes are installed:

Statistics and Machine Learning Toolbox
Signal Processing Toolbox
Image Processing Toolbox
Parallel Computing Toolbox (recommended)

MATLAB Dependencies (included in repo)

1. munkres/

Used for:

Cluster label alignment
Dice coefficient matching between parcellations

Implements Hungarian algorithm

2. Yeo_CBIG/

Used for:

Yeo 7-network cortical atlas
Network reference masks (VIS, SMN, DAN, VAN, LIM, FPN, DMN)

Source:

Yeo et al. (2011)

3. subcortex-master/

Used for:

Subcortical masks
Anatomical segmentation of:
Thalamus
Caudate
Putamen
Pallidum
Hippocampus
Amygdala
Nucleus accumbens

2. Python Environment
Recommended Python Version
Python 3.11
Install Dependencies
pip install numpy
pip install scipy
pip install scikit-learn
pip install nibabel
pip install matplotlib
Optional (for advanced reproducibility)
pip install pandas
pip install h5py
pip install joblib
Python Modules in this repo

hyperalignment/

Used for:

Connectivity-based hyperalignment
Alignment of subjects into common representational space
Reducing inter-subject variability in cortical networks

Based on:

Haxby et al. hyperalignment framework

3. Key Algorithm Dependencies

Spectral Clustering

Used for:

Subcortical voxel clustering
Connectivity similarity matrix partitioning

MATLAB:

spectralClustering_multiK_Larry.m

Munkres Assignment

Used for:

Cluster label consistency
Hemisphere symmetry evaluation
Cross-subject parcellation matching

Folder:

/munkres

pySuStaIn (optional extension)

Used for:

Trajectory modeling (not core paper pipeline)
Can be used for:
Aging stage modeling
Disease progression modeling

Folder:

/pySuStaIn-master

4. Data Requirements

This pipeline is designed for:

Functional MRI (resting-state)
HCP 7T dataset (primary)
Cam-CAN dataset
SALD dataset
Required preprocessing:
Motion correction
Spatial normalization
Temporal filtering
Grayordinate projection (recommended)

5. Workflow Overview
Step 1  Preprocessing
scripts/dataPreparation.m
Step 2  Hyperalignment (Python)
python src/python/hyperalignment/run_hyperalignment.py
Step 3  Connectivity Matrix Construction
voxel -> cortical network correlation
Step 4  Spectral Clustering
SpectralClustering_multiK_Larry.m
Step 5  Individualized Parcellation
SVM voxel classification
probability-based assignment
Step 6  Feature Extraction
parcel size per nucleus
Step 7  Prediction Models
Kernel Ridge Regression (KRR)
5-fold cross-validation
Step 8  Feature Interpretation
Haufe transformation

6. Outputs

The pipeline generates:

Subcortical parcellation maps (24 regions per hemisphere)
Individualized voxel-wise labels
Parcel size feature matrix
Age prediction model outputs
Cognitive prediction outputs
Feature importance (nucleus-level weights)

7. Reproducibility Notes
All clustering uses 100-1000 repetitions
Cross-validation is stratified 5-fold repeated 100 times
Statistical significance:
permutation tests (1000 iterations)
FDR correction (Benjamini-Hochberg)

8. Key References
Yeo et al., 2011 (7-network atlas)
Haxby et al., Hyperalignment
Tian et al., Subcortical parcellation framework
Haufe et al., decoding model interpretation
Nadeau & Bengio, corrected resampled t-test

9. Notes
This repository assumes familiarity with:
fMRI preprocessing
brain network analysis
MATLAB scripting
Some scripts require modification depending on dataset format (HCP / CamCAN / SALD)

10. Citation

If you use this code, please cite:

Liu et al. (2026)
A Cortical Network-Specific Framework for Subcortical Parcellation Identifies Signatures of Healthy Aging