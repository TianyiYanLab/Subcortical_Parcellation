# Purpose: pickle2mat.
# Input: splits = pickle.load(f)
# Output: scipy.io.savemat(os.path.join(currOutPath,'splits.mat'), mdict={'splits':splits})
# Dependencies: See README.md.
from pathlib import Path
REPO_ROOT = Path(__file__).resolve().parents[3]
import os
import os
import pickle
import scipy.io
rootPath = str(REPO_ROOT / 'results/work/CamCan/Autogluon_prediction/prediction')
outPath = str(REPO_ROOT / 'results/prediction/cognition/prediction')
for rep in range(100):
    with open(os.path.join(rootPath,str(rep),'splits.pkl'), 'rb') as f:
        splits = pickle.load(f)
    currOutPath = os.path.join(outPath,str(rep))
    if not os.path.exists(currOutPath):
        os.makedirs(currOutPath)
    scipy.io.savemat(os.path.join(currOutPath,'splits.mat'), mdict={'splits':splits})
