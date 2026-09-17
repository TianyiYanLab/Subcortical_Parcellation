# Purpose: make data input.
# Input: originalVariables = pd.read_csv('data input/All nets.csv'); currCtDf = pd.read_excel('data input/Screening cognitive scale.xlsx',sheet_name=ct)
# Output: newDf.to_csv('data input/'+ct+'.csv',index=False)
# Dependencies: See README.md.

import os
from pathlib import Path
import pandas as pd
REPO_ROOT = Path(__file__).resolve().parents[3]
input_dir = REPO_ROOT / 'results/prediction/cognition/data input'
originalVariables = pd.read_csv(input_dir / 'All nets.csv')
originalVariables['Sub_ID'] = originalVariables['Sub_ID'].str.replace('sub-','')
originalVariables.rename(columns={'Sub_ID':'CCID'},inplace=True)

cogTasks = ['Fluid intelligence','Emotion expression recognition','TOT','Face recognition','Hotel','Proverb','Force matching','Motor learning']

for ct in cogTasks:
    currCtDf = pd.read_excel(input_dir / 'Screening cognitive scale.xlsx',sheet_name=ct)
    newDf =pd.merge(originalVariables,currCtDf,on='CCID',how='inner')
    newDf.to_csv(input_dir / (ct+'.csv'),index=False)
