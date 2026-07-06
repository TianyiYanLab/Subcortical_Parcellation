%reset -f
import numpy as np
import pandas as pd
from sklearn.model_selection import RepeatedStratifiedKFold
import os
rootPath = os.path.join(os.getcwd(),'data input')
# Split cross-validation
df = pd.read_csv(fr'{rootPath}\GM.csv')
age_bin = pd.qcut(df['Age'], q=5, labels=False)  # Using quantile binning

rskf = RepeatedStratifiedKFold(n_splits=5, n_repeats= 100,random_state=42)

import pickle
splits = list(rskf.split(df, age_bin))
repeated_splits = [splits[i*5 : (i+1)*5] for i in range(100)]

for repeat_idx, split_group in enumerate(repeated_splits):
    currRepPath = os.path.join(os.getcwd(),'prediction',str(repeat_idx))
    if not os.path.exists(currRepPath):
        os.makedirs(currRepPath)
    with open(os.path.join(currRepPath,'splits.pkl'), 'wb') as f:
        pickle.dump(split_group, f)
