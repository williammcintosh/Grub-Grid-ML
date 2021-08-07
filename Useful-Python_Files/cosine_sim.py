import numpy as np
import pandas as pd
from scipy.spatial.distance import cosine
from flask import Flask

# For flask api
app = Flask(__name__)

@app.route('/cosine/<string:user_list>')
def Cosine_Similarity(user_list):
    res = [int(idx) for idx in user_list.split(',')]
    rec = res[:4]
    rat = res[4:]
    u_df = pd.read_csv("0-1000000_cleanedup_RAW_interactions.csv")
    
    # This is the list of user's input along with the ratings for each
    nu_df = pd.DataFrame(
        {
            'recipe_id': rec,
            'nu_rating': rat
        }
    )
    nu_df = nu_df.sort_values(by='recipe_id', ascending=False)
    #print(f"The list of new user rated recipes:\n{nu_df}\n")

    m_df = u_df.loc[u_df['recipe_id'].isin(nu_df['recipe_id'])]
    #print(f"There are {len(m_df)} users who have also rated some of these recipes.\n")

    g_df = m_df.groupby(by=['user_id']).size().sort_values(ascending=False).head(10)
    #print(f"Sorted list of users who have also rated the same recipes:\n{g_df}")

    # results dataframe
    r_df = pd.DataFrame(columns=['user_id','cosine','freq'])

    # Loops through all users who have rated the same recipes as the new user
    for u_id in g_df.index:
        ind = m_df.user_id == u_id
        rec = m_df.loc[ind]
        frq = rec.iloc[0].at['freq']
        p_df = pd.merge(rec, nu_df,how='outer', on='recipe_id').replace(np.nan, 0)
        cos = (1 - cosine(p_df['rating'], p_df['nu_rating']))
        #Creates a temp dataframe to append onto the results dataframe
        t_df = pd.DataFrame(columns=['user_id','cosine','freq'])
        t_df.loc[0] = [u_id,cos,frq]
        r_df = r_df.append(t_df)
        #p_df.drop(columns='Unnamed: 0',inplace=True)
        #p_df['cosine'] = cos
        #print(p_df)

    #Append p_df['user_id'] and ['cosine']
    #Remove all lower cosines
    r_df = r_df.sort_values(['cosine','freq'], ascending = (False, False))
    print(r_df)
    #Sort by freq
    #return user_id
    user = r_df.iloc[0].at['user_id']
    return str(int(user))

@app.route('/')
def home():
    multiline_str = "Hello! Welcome to Will McIntosh's API call!\n"
    multiline_str += "Please add 'cosine' to your url\n"
    multiline_str += "followed by a commas separated list of floats.\n"
    multiline_str += "an example is:\n"
    multiline_str += "\tcurl http://localhost:9999/cosine/254921,361650,215716,248350,0,1,0,1"
    return multiline_str

app.run(port=9999)

