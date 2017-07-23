# Chap05/gplus_search_web_gui.py
import os
import json
from flask import Flask
from flask import request
from flask import render_template

import pandas as pd
import numpy as np
from scipy.spatial.distance import cdist

app = Flask(__name__)

data_dir = './data/'
neurosynth = pd.read_csv(os.path.join(data_dir,'studies_metadata.csv'), index_col=0)
idxassignments = np.loadtxt(os.path.join(data_dir,'idx_assignments_6clusters.txt'), dtype=np.int )
Fis = np.loadtxt(os.path.join(data_dir,'Fis_for_projection.txt') , delimiter=' ')


def get_closest_studies(query = 10191322):
    if type(query) != int:
        query = int(query)
    qindx = np.where(neurosynth['pubmed'].values==query)[0][0]
    dists = cdist(Fis, Fis[qindx][None,:])
    closest = np.argsort(dists, axis=0)[1:].flatten()
    
    query_info = json.loads(neurosynth.iloc[qindx].to_json())
    search_results = json.loads(neurosynth.iloc[closest[:10]].to_json(orient='records'))
    
    return query_info, search_results

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/search', methods=['POST'])
def search():
    query = request.form.get('query')
    if not query:
        # query not given, show an error message
        return render_template('index.html')
    else:

        # search
        query_info, search_results = get_closest_studies(query)
        words_list = get_closest_words(query)

        words = dict([  ['words', words_list ]   ])


        return render_template('results.html',
                               query=query_info,
                               results=search_results,
                               words= words)

if __name__ == '__main__':
    app.run(debug=True)
