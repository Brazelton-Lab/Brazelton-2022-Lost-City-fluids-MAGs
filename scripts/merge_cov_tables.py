# will attempt to merge all .csv files in working directory

import os
import pandas as pd

dfs = [pd.read_csv(f, index_col=[0], dtype={1:'string'})
	for f in os.listdir(os.getcwd()) if f.endswith('csv')]


finaldf = pd.concat(dfs).sort_index()
finaldf.to_csv('merged.csv')
