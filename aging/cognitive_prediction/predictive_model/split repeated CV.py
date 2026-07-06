#==============================================================================================
%reset -f
import numpy as np
import pandas as pd
from sklearn.model_selection import RepeatedStratifiedKFold
import os
import scipy.io

rootPath = os.path.join(os.getcwd(), 'data input')
# cogTasks = ['Fluid intelligence','Emotion expression recognition','TOT',
#     'Face recognition','Hotel','Proverb','Force matching','Motor learning']
cogTasks = ['VSTM','PicturePriming','RTchoice','RTsimple','FamousFaces','EmotionRegulation']
for t in cogTasks:
    # Set up cross-validation splits
    df = pd.read_csv(fr'{rootPath}\{t}.csv')
    age_bin = pd.qcut(df['Age'], q=5, labels=False)  # Quantile-based binning

    rskf = RepeatedStratifiedKFold(n_splits=5, n_repeats=100, random_state=42)

    # Generate and save .mat files directly
    splits = list(rskf.split(df, age_bin))
    repeated_splits = [splits[i*5 : (i+1)*5] for i in range(100)]

    for repeat_idx, split_group in enumerate(repeated_splits):
        currRepPath = os.path.join(os.getcwd(), 'prediction', t, str(repeat_idx))
        if not os.path.exists(currRepPath):
            os.makedirs(currRepPath)
        
        # Save directly as .mat file
        scipy.io.savemat(
            os.path.join(currRepPath, 'splits.mat'),
            mdict={'splits': np.array(split_group, dtype=object)},  # Convert to numpy array for compatibility
            long_field_names=True
        )