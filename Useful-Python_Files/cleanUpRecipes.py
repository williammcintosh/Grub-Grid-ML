import pandas as pd
import numpy as np
import sys

# Maximum entries
min_cutoff = int(sys.argv[1])
max_cutoff = int(sys.argv[2])

# Gets the csv file and converts it to a dataframe
path = "/Users/willmcintosh/DataSciencePractice/"
file_name = "RAW_recipes"
recipe_df = pd.read_csv(path+file_name+".csv")

# Drop unwanted
recipe_df.drop(columns='contributor_id', inplace=True)
recipe_df.drop(columns='submitted', inplace=True)
recipe_df.drop(columns='tags', inplace=True)
recipe_df.drop(columns='description', inplace=True)
recipe_df.drop(columns='minutes', inplace=True)
recipe_df.drop(columns='nutrition', inplace=True)
recipe_df.drop(columns='n_steps', inplace=True)
recipe_df.drop(columns='n_ingredients', inplace=True)

# Truncate the number of rows from interaction dataframe
recipe_df = recipe_df.truncate(before=min_cutoff, after=max_cutoff)
# Saves the dataframe back into a csv file
# Adds quotes
recipe_df.to_csv(str(min_cutoff)+"-"+str(max_cutoff)+"_cleanedup_"+file_name+".csv", quoting=1)
print(f"Saving file:\n\t"+str(min_cutoff)+"-"+str(max_cutoff)+"_cleanedup_"+file_name+".csv")

