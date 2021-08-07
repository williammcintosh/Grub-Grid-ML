from googleapiclient.discovery import build
from flask import Flask

app = Flask(__name__)

@app.route('/grabimage/<string:search_term>')
def cosine(search_term):
    api_key = "mykey"
    #resource = build("customsearch", 'v1', developerKey=api_key).cse()
    result = resource.list(q=search_term, cx="myprojectid",searchType='image').execute()
    return str(result['items'][0]['link'])

@app.route('/')
def home():
    multiline_str = "Hello! Welcome to Will McIntosh's API call!\n"
    multiline_str += "Please add 'grabimage' to your url\n"
    multiline_str += "followed by a commas separated list of floats.\n"
    multiline_str += "an example is:\n"
    multiline_str += "\thttp://grubgridimagesearch.herokuapp.com/grabimage/authentic mulligatawny soup"
    return multiline_str

#app.run(port=5000)
