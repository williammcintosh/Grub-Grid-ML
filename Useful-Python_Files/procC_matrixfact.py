import numpy as np
import pandas as pd
import scipy.sparse
from scipy.sparse import csr_matrix, save_npz
import time
import sys
from sklearn.decomposition import NMF

def Get_Seventy_Percentile(R):
    maxVal = R.to_numpy().max()
    minVal = R.to_numpy().min()
    return (maxVal-minVal) * 0.7
        
def Label_Inactive_Users(R):
    min_ratings = 2
    row_ind = R.gt(1)
    row_ind = row_ind.sum(axis=1)
    print(f"The list of ratings per user =\n{row_ind}")
    inact_users = row_ind.le(min_ratings)
    print(f"The list of users whose who have rated {min_ratings} or less recipes")
    return inact_users

def Trimmed_Index_Header(activities):
    ind_df = pd.read_csv(str(max_c)+"_index_headers.csv")
    prev = ind_df.shape
    t_indx = ind_df[activities == True].index
    ind_df.drop(t_indx, inplace = True)
    print(f"Size of header:\n\tbefore: {prev}\n\tafter: {ind_df.shape}")
    activities.drop(activities[activities == True].index, inplace = True)
    return ind_df

def Trim_Inactive_Users(R, activities):
    R_index = R[activities == True].index
    print(f"Complete list of inactive users is:\n{R_index}")
    R = R.drop(R_index)  
    return R, activities

def Normalize_Dataframe(newR_df):
    T = Get_Seventy_Percentile(newR_df)
    newR_df.where(newR_df > T, other=0, inplace=True)
    newR_df.where(newR_df <= T, other=1, inplace=True)
    return newR_df


if __name__ == "__main__":
    # Reading in the file, cutoff from sys arg
    min_c = int(sys.argv[1])
    max_c = int(sys.argv[2])
    file_name = "RAW_interactions"
    path = "/Users/willmcintosh/DataSciencePractice/"
    fn = path+str(min_c)+"-"+str(max_c)+"_adjmat_"+file_name+".csv.npz"

    # Converting everything
    R_npz = scipy.sparse.load_npz(fn)
    R_arr = scipy.sparse.csr_matrix.toarray(R_npz)
    R = pd.DataFrame(R_arr)
    print(f"The shape of R is {R.shape}")

    # Shortens Adjaceny Matrix
    all_users = Label_Inactive_Users(R)
    print(f"Inactive_users_df =\n{all_users}")
    active_users_df, active_users_series = Trim_Inactive_Users(R, all_users)
    print(f"The list of active users:\n{active_users_df}")

    # Factorization
    print("Performaing matrix factorization")
    nmf = NMF(n_components=5, init='random', random_state=0)
    nmf.fit(active_users_df)
    print(f"Resulting matrix:\n{active_users_df}")

    # Make DataFrame into 1s or 0s
    #newR_df = pd.DataFrame(active_users_df)
    #newR_df = Normalize_Dataframe(newR_df)
    print("Converting dataframe to binary")
    active_users_df = Normalize_Dataframe(active_users_df)
    print(f"Resulting binary matrix:\n{active_users_df}")

    # At this point, the user_ids have not been included,
    # This file, created from ProcB_...py makes the headers
    ind_df = Trimmed_Index_Header(active_users_series)
    print(f"The list of users ids:\n{ind_df}")
    
    # Save DataFrame to csv
    print(f"The active_users_series:\n{active_users_series}")
    print("saving results to a csv called:")
    col_df = pd.read_csv(str(min_c)+"-"+str(max_c)+"_column_headers.csv")
    #R_df = pd.DataFrame(data=active_users_df, index=ind_df['users'], columns=col_df['recipes'])
    active_users_df.columns = col_df['recipes']
    active_users_df.index = ind_df['users']
    active_users_df.to_csv("matrix_fact_"+str(min_c)+"-"+str(max_c)+file_name+".csv")
    print("\tmatrix_fact_"+istr(min_c)+"-"+str(max_c)+file_name+".csv")
    
