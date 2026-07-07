%reset -f
import pandas as pd
originalVariables = pd.read_csv('data input/All nets.csv')
originalVariables['Sub_ID'] = originalVariables['Sub_ID'].str.replace('sub-','')
originalVariables.rename(columns={'Sub_ID':'CCID'},inplace=True)

cogTasks = ['Fluid intelligence','Emotion expression recognition','TOT','Face recognition','Hotel','Proverb','Force matching','Motor learning']

for ct in cogTasks:
    currCtDf = pd.read_excel('data input/Screening cognitive scale.xlsx',sheet_name=ct)
    newDf =pd.merge(originalVariables,currCtDf,on='CCID',how='inner')
    newDf.to_csv('data input/'+ct+'.csv',index=False)

dfs = {}
# Read and merge all cognitive task tables
for ct in cogTasks:
    try:
        currCtDf = pd.read_excel('data input/Screening cognitive scale.xlsx', sheet_name=ct)
        # Ensure CCID column exists
        if 'CCID' in currCtDf.columns:
            merged_df = pd.merge(originalVariables[['CCID']], currCtDf, on='CCID', how='inner')
            dfs[ct] = merged_df
        else:
            print(f"Warning: {ct} table does not have CCID column, skipping merge")
    except Exception as e:
        print(f"Error reading {ct} table: {str(e)}")

for i,dfName in enumerate(dfs.keys()):
    newMergedDf = dfs[dfName]
    newMergedDfNames = [dfName]
    del dfs[dfName]
    for dfName2 in dfs.keys():
        if dfs[dfName]['CCID'].equals(dfs[dfName2]['CCID']):
            newMergedDf = pd.merge(newMergedDf,dfs[dfName2], on='CCID',how='inner')
            newMergedDfNames.append(dfName2)
            print(newMergedDfNames)
            del dfs[dfName2]