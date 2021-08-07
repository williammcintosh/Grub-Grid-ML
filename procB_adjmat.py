import numpy as np
import sys
import pandas as pd
from scipy.sparse import csr_matrix, save_npz
import time

min_c = int(sys.argv[1])
max_c = int(sys.argv[2])
file_name = "_cleanedup_RAW_interactions"
fn = "/Users/willmcintosh/DataSciencePractice/"+str(min_c)+"-"+str(max_c)+file_name+".csv"

# Read data
df = pd.read_csv(fn, index_col=0)
n_ratings = len(df)
print(f"There are {n_ratings} ratings in this dataset.")

"""
Construct an index for users and recipes.
The i-th element of the index shows where item exists along the matrix.
Ex:
   user_index = [52, 101, 423]

   This means user 52 belongs to row 0; user 101 belongs to row 1; user 423 belongs to row 2
"""

user_index = df['user_id'].unique()
recipe_index = df['recipe_id'].unique()

# Determine shape of the user-to-recipe matrix
n_users = len(user_index)
n_recipes = len(recipe_index)
print(f"There are {n_users} users and {n_recipes} recipes")

"""
Fill in the row, col, data arrays to build sparse matrix.

The i-th element of `row` contains the position in the user index for the user of the i-th rating.
The i-th element of `col` contains the position in the recipe index for the recipe of the i-th rating.
The i-th element of `data` contains the rating that the user gave the recipe of the i-th rating.

Use numpy arrays with predetermined size so that filling them in with values is efficient.
"""
t0 = time.time()

row = np.zeros(n_ratings)
col = np.zeros(n_ratings)
data = np.zeros(n_ratings)
for i, (u,r,v) in enumerate(zip(df['user_id'], df['recipe_id'], df['rating'])):

   if i < 5:
       print(f"Rating {i} for user {u}, recipe {r} is value {v}")
   elif i == 5:
       print("...continuing.")

   row[i] = np.argwhere(user_index==u)[0]
   col[i] = np.argwhere(recipe_index==r)[0]
   data[i] = v

# Build the sparse matrix
arr = csr_matrix((data, (row, col)), shape=(n_users, n_recipes))
print(f"There are a total of {arr.nnz} nonzero elements in this sparse matrix.")
print(f"The shape of this matrix is {n_users} by {n_recipes}")

t1 = time.time()
print(f"Processing took {t1-t0} seconds.")

# Make a separate headers file
columns_headers = pd.DataFrame(data=recipe_index, index=None, columns=['recipes'])
index_headers = pd.DataFrame(data=user_index, index=None, columns=['users'])
columns_headers.to_csv(str(min_c)+"-"+str(max_c)+"_column_headers.csv")
index_headers.to_csv(str(min_c)+"-"+str(max_c)+"_index_headers.csv")

# Write to "npz" format
# https://docs.scipy.org/doc/scipy/reference/generated/scipy.sparse.save_npz.html#scipy.sparse.save_npz
# print("Saving sparse matrix in .npz format.")
# save_npz("/Users/kyleobr/Desktop/desktop/grubgrid/user-recipe-rating-adjacency-matrix.csv", arr)
path = "/Users/willmcintosh/DataSciencePractice/"
file_name = "RAW_interactions"
save_npz(path+str(min_c)+"-"+str(max_c)+"_adjmat_"+file_name+".csv", arr)



