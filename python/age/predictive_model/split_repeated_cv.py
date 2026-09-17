# Purpose: split repeated cv.
# Input: df = pd.read_csv(fr'{rootPath}/GM.csv')
# Output: pickle.dump(split_group, f)
# Dependencies: See README.md.

import os
from pathlib import Path
import numpy as np
import pandas as pd
from sklearn.model_selection import RepeatedStratifiedKFold
import os
REPO_ROOT = Path(__file__).resolve().parents[3]
rootPath = str(REPO_ROOT / 'results/prediction/age/data input')
# Split cross-validation
df = pd.read_csv(fr'{rootPath}/GM.csv')
age_bin = pd.qcut(df['Age'], q=5, labels=False)  # Using quantile binning

rskf = RepeatedStratifiedKFold(n_splits=5, n_repeats= 100,random_state=42)

import pickle
from scipy.io import savemat
splits = list(rskf.split(df, age_bin))
repeated_splits = [splits[i*5 : (i+1)*5] for i in range(100)]

for repeat_idx, split_group in enumerate(repeated_splits):
    currRepPath = str(REPO_ROOT / 'results/prediction/age/prediction' / str(repeat_idx))
    if not os.path.exists(currRepPath):
        os.makedirs(currRepPath)
    with open(os.path.join(currRepPath,'splits.pkl'), 'wb') as f:
        pickle.dump(split_group, f)
    # Export the same zero-based indices for the next MATLAB stage.
    mat_splits = np.empty((len(split_group), 2), dtype=object)
    for fold_index, (train_indices, test_indices) in enumerate(split_group):
        mat_splits[fold_index, 0] = train_indices
        mat_splits[fold_index, 1] = test_indices
    savemat(os.path.join(currRepPath, 'splits.mat'), {'splits': mat_splits})
