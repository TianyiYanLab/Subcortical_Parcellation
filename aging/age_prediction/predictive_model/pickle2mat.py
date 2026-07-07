import os
import pickle
import scipy.io
rootPath = r'/path/to/your/data\CamCan\Autogluon_prediction\prediction'
outPath = 'prediction'
for rep in range(100):
    with open(os.path.join(rootPath,str(rep),'splits.pkl'), 'rb') as f:
        splits = pickle.load(f)
    currOutPath = os.path.join(outPath,str(rep))
    if not os.path.exists(currOutPath):
        os.makedirs(currOutPath)
    scipy.io.savemat(os.path.join(currOutPath,'splits.mat'), mdict={'splits':splits})
