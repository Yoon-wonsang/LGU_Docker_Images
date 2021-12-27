SITE_DOMAIN=$1

echo "SITE_DOMAIN=$SITE_DOMAIN"

if [ "$SITE_DOMAIN"  == "" ]; then

   echo "example : $0  goodmit.com "
   exit 1

fi

CURRENT_DATE=$2
if [ "$CURRENT_DATE"  == "" ]; then

    CURRENT_DATE=`date +"%Y%m%d"`
fi



COMMON_PKG="\
import numpy ; \
import bokeh ; \
import gensim ; \
import glob2 ; \
import h5py ; \
import joblib ; \
import mpi4py ; \
import multiprocess ; \
import nltk ; \
import pandas ; \
import pymysql ; \
import pyodbc ; \
import scipy ; \
import statsmodels ; \
import statsd ; \
import tqdm ; \
import numba ; \
import lightfm ; \
import pydotplus ; \
import sklearn  ; \
import gym ; \
import konlpy ; \
import mglearn ; \
import boruta ; \
import geometric ; \
import networkx ; \
import geopandas ; \
import geojson ; \
import shapely ; \
import pysal ; \
import tslearn ; \
import folium ; \
import plotnine ; \
import gower ; \
import PyKomoran ; \
import pickle ; \
import openpyxl ; \
import matplotlib ; \
import seaborn ; \
import PIL ; \
import six ; \
import prince ; \
import konlpy ; \
import kmodes ; \
import soyclustering ; \
import pandas_profiling ;  \
import pyspark ; \
import cdsw ; \
from soyclustering import SphericalKMeans ; \
from konlpy.tag import Mecab ; \
"
echo "#### COMMON_PKG  ####"
docker run -it --rm --net=host --pid=host \
       conda.docker.repository.cloudera.com/cdsw/engine:10  \
       /bin/bash 	\
       -c "/opt/conda/envs/python3.6/bin/python -c \"$COMMON_PKG  \"  "

echo "#### check tensorflow2.0  ####"
MY_PKG="\
import tensorflow ; \
import keras ; \
"
docker run -it --rm --net=host --pid=host \
       tensorflow2.0.${SITE_DOMAIN}/cdsw/engine:10.${CURRENT_DATE}  \
       /bin/bash 	\
	   -c "/opt/conda/envs/python3.6/bin/python -c \"$MY_PKG  \"   "	   

echo "#### check pytorch1.3  ####"	   
MY_PKG="\
import torch ; \
import torchvision ; \
import transformers ; \
import kobert ; \
import mxnet ; \
import gluonnlp ; \
import sentencepiece ; \
"
docker run -it --rm --net=host --pid=host \
       pytorch1.3.${SITE_DOMAIN}/cdsw/engine:10.${CURRENT_DATE}  \
       /bin/bash 	\
	   -c "/opt/conda/envs/python3.6/bin/python -c \"$MY_PKG  \"   "