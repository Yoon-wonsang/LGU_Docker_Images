FROM cuda11.docker.repository.cloudera.com/cdsw/engine:13

############################################
# 기본 OS 설정 ODBC, language-pack-ko, TimeZone
############################################
RUN rm -f /etc/apt/sources.list.d/cloudera.list && \
    rm -f /etc/apt/sources.list.d/yarn.list && \
    cd /tmp/ && \
    apt-get update &&  \
    apt-get install -y --no-install-recommends  \
            language-pack-ko  fonts-nanum  \
            libssl-dev \
            libmariadb-client-lgpl-dev \
            mysql-client libmysqlclient20 \
            libxml2-dev  libnlopt-dev  \
            unixodbc-dev iodbc libiodbc2  \
            xorg libx11-dev  libglu1-mesa-dev  libfreetype6-dev   \
            libgmp-dev   libblas-dev libblas3 \
            libstdc++6  libcupti-dev openjdk-8-jdk 	&& \
    wget -O impala.deb --no-check-certificate https://downloads.cloudera.com/connectors/impala_odbc_2.5.41.1029/Debian/clouderaimpalaodbc_2.5.41.1029-2_amd64.deb && \
    wget -O hive.deb --no-check-certificate  https://downloads.cloudera.com/connectors/ClouderaHive_ODBC_2.6.4.1004/Debian/clouderahiveodbc_2.6.4.1004-2_amd64.deb && \
    dpkg -i  impala.deb hive.deb  && \
    rm -rf  *.deb && rm -rf /var/lib/apt/lists/*  && \
    mv /etc/default/locale /etc/default/locale.bak  && \
    echo "LANG=\"ko_KR.UTF-8\"" >> /etc/default/locale && \
    echo "LANGUAGE=\"ko_KR:ko\"" >> /etc/default/locale  && \
    ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime && \
    rm -rf /var/lib/apt/lists/*


############################################
# 오라클 OCI 설치
############################################
RUN cd /tmp/ && \
    wget http://10.200.101.253/hanwha/oracle/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm  && \
    wget http://10.200.101.253/hanwha/oracle/oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm  && \
    apt-get update &&  apt-get install -y alien libaio1  && \
    alien -i oracle-instantclient12.1-basic*.rpm && \
    alien -i oracle-instantclient12.1-devel*.rpm  && \
    export ORACLE_HOME=/usr/lib/oracle/12.1/client64 && \
    mkdir $ORACLE_HOME/rdbms  && \
    mkdir $ORACLE_HOME/rdbms/public && \
    cp /usr/include/oracle/12.1/client64/* $ORACLE_HOME/rdbms/public && \
    rm -f *.rpm  
  
############################################
# 분석패키지 추가
############################################
RUN mkdir -p /opt/conda/envs/python3.6  && \
    conda install -y nbconvert python=3.6.10 -n python3.6 && \
    conda install -y -n python3.6 bokeh  && \
    conda install -y -n python3.6 gensim  && \
    conda install -y -n python3.6 glob2  && \
    conda install -y -n python3.6 h5py  && \
    conda install -y -n python3.6 joblib  && \
    conda install -y -n python3.6 mpi4py  && \
    conda install -y -n python3.6 multiprocess  && \
    conda install -y -n python3.6 nltk  && \
    conda install -y -n python3.6 pandas  && \
    conda install -y -n python3.6 pymysql  && \
    conda install -y -n python3.6 pyodbc  && \
    conda install -y -n python3.6 scipy  && \
    conda install -y -n python3.6 statsmodels  && \
    conda install -y -n python3.6 statsd  && \
    conda install -y -n python3.6 tqdm  && \
    conda install -y -n python3.6 seaborn  && \
    conda install -y -n python3.6 matplotlib  && \
    conda install -y -n python3.6 scikit-learn  && \
    conda install -y -n python3.6 numba  && \
	conda install -y -n python3.6 numpy  && \
	conda install -y -n python3.6 lightfm && \
	conda clean -a

############################################  
#쥬피터랩 jupyterlab konlpy
############################################
RUN /opt/conda/envs/python3.6/bin/pip install --no-cache-dir --no-clean -v netifaces \
                 gputil gym  jupyterlab konlpy JPype1-py3  mglearn boruta lightgbm && \
    pip3 install --no-cache-dir --no-clean -v netifaces \
	     jupyterlab	
         
ADD jvm.py  /opt/conda/envs/python3.6/lib/python3.6/site-packages/konlpy/jvm.py
RUN cd /tmp/ && \
    wget --no-check-certificate  https://jaist.dl.sourceforge.net/project/libpng/zlib/1.2.9/zlib-1.2.9.tar.gz  && \
    tar -xvf zlib-1.2.9.tar.gz && \
    cd zlib-1.2.9   && \
    ./configure &&  make && make install && \
    cd /usr/lib/x86_64-linux-gnu/  && \
    ln -s -f /usr/local/lib/libz.so.1.2.9/lib libz.so.1 && \
    cd /tmp/ && rm -rf zlib-1.2.9

############################################ 
#은전한잎 설치
############################################
## m4, autoconf , automake, mecab-ko ##
RUN cd /tmp && wget http://ftp.gnu.org/gnu/m4/m4-1.4.18.tar.gz && \
    tar xvfz m4-1.4.18.tar.gz && \
    cd m4-1.4.18 && \
    ./configure --prefix=/usr && make && make install && \
    cd /tmp  && rm -rf m4-1.4.18 && \
    wget http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz  &&  \
    tar xvfz autoconf-2.69.tar.gz  &&  \
    cd autoconf-2.69 && ./configure &&  make &&  make install  &&  \
    cd /tmp &&  rm -rf  autoconf-2.69  &&  \
    wget  http://ftpmirror.gnu.org/automake/automake-1.11.tar.gz  &&  \
    tar -zxvf automake-1.11.tar.gz  &&  \
    cd automake-1.11  &&  \
    ./configure  &&  make  &&  make install  &&  \
    cd /tmp &&  rm -rf automake-1.11  && rm -f *.tar.gz &&  \
    echo "## install mecab-ko, mecab-ko-dic, mecab-python ##" &&  \
    cd /tmp  && \
    wget  https://bitbucket.org/eunjeon/mecab-ko/downloads/mecab-0.996-ko-0.9.2.tar.gz  && \
    tar zxfv mecab-0.996-ko-0.9.2.tar.gz  && \
    cd mecab-0.996-ko-0.9.2  && \
    ./configure  && make  && make check  && make install  && ldconfig && \
    cd /tmp &&  rm -rf mecab-0.996-ko-0.9.2 && rm -f *.tar.gz  && \
    wget  https://bitbucket.org/eunjeon/mecab-ko-dic/downloads/mecab-ko-dic-2.1.1-20180720.tar.gz  && \
    tar -zxvf mecab-ko-dic-2.1.1-20180720.tar.gz  && \
    cd mecab-ko-dic-2.1.1-20180720 && \
    ./configure && make  && make install  && ldconfig  && \
    sh -c 'echo "dicdir=/usr/local/lib/mecab/dic/mecab-ko-dic" > /usr/local/etc/mecabrc'  && \
    make install

RUN cd /tmp  && rm -rf mecab-ko-dic-2.1.1-20180720 && rm -f *.tar.gz  && \
    git clone https://bitbucket.org/eunjeon/mecab-python-0.996.git   && \
    cd mecab-python-0.996   && \
    /opt/conda/envs/python3.6/bin/python setup.py build     && \
    /opt/conda/envs/python3.6/bin/python setup.py install   && \
    cd /tmp  && rm -rf mecab-python-0.996  && rm -f *.tar.gz


############################################
## packages 추가시 수정할 부분
############################################
    
    #conda install -y -n python3.6  pyspark  && \
    

# xgboost
RUN cd /tmp && \
    cp /usr/local/lib/python3.6/site-packages/cdsw.py  /opt/conda/envs/python3.6/lib/python3.6/site-packages/ && \
    cp -r /usr/local/lib/python3.6/site-packages/cdsw-1.0.0.dist-info  /opt/conda/envs/python3.6/lib/python3.6/site-packages/ && \
    /opt/conda/envs/python3.6/bin/pip install --no-cache-dir --no-clean  \
          Cython  && \
    /opt/conda/envs/python3.6/bin/pip install --no-cache-dir --no-clean  \
	    xgboost  gower PyKomoran pydotplus graphviz pysal tslearn folium Pillow cx_Oracle  && \
# XAI 
    /opt/conda/envs/python3.6/bin/pip install --no-cache-dir --no-clean \
              pdpbox  lime  ipywidgets shap  catboost  plotly retrying 

# 한화생명
RUN conda install -y -n python3.6  pandana urbanaccess  geometric  geopandas geojson shapely plotnine && \
    conda install -y -n python3.6   asn1crypto                                && \
    conda install -y -n python3.6   astor                                     && \
    conda install -y -n python3.6   astroid                                   && \
    conda install -y -n python3.6   astropy                                   && \
    conda install -y -n python3.6   atomicwrites                              && \
    conda install -y -n python3.6   autopep8                                  && \
    conda install -y -n python3.6   argh                                      && \
    conda install -y -n python3.6   azure-core                                && \
    conda install -y -n python3.6   azure-storage-blob                        && \
    conda install -y -n python3.6   backports                                 && \
    conda install -y -n python3.6   backports.functools_lru_cache             && \
    conda install -y -n python3.6   backports.shutil_get_terminal_size        && \
    conda install -y -n python3.6   backports.tempfile                        && \
    conda install -y -n python3.6   backports.weakref                         && \
    conda install -y -n python3.6   bitarray                                  && \
    conda install -y -n python3.6   bkcharts                                  && \
    conda install -y -n python3.6   blas                                      && \
    conda install -y -n python3.6   blaze                                     && \
    conda install -y -n python3.6   blis                                      && \
    conda install -y -n python3.6   blosc                                     && \
    conda install -y -n python3.6   bottleneck                                && \
    conda install -y -n python3.6   brotlipy                                  && \
    conda install -y -n python3.6   bz2file                                   && \
    conda install -y -n python3.6   ca-certificates                           && \
    conda install -y -n python3.6   cairo                                     && \
    conda install -y -n python3.6   catalogue                                 && \
    conda install -y -n python3.6   certipy                                   && \
    conda install -y -n python3.6   clyent                                    && \
    conda install -y -n python3.6   colorlover                                && \
    conda install -y -n python3.6   confuse                                   && \
    conda install -y -n python3.6   contextlib2                               && \
    conda install -y -n python3.6   convertdate                               && \
    conda install -y -n python3.6   cufflinks-py                              && \
    conda install -y -n python3.6   curl                                      && \
    conda install -y -n python3.6   cymem                                     && \
    conda install -y -n python3.6   cytoolz                                   && \
    conda install -y -n python3.6   dask                                      && \
    conda install -y -n python3.6   dask-core                                 && \
    conda install -y -n python3.6   databricks-cli                            && \
    conda install -y -n python3.6   dbus                                      && \
    conda install -y -n python3.6   diff-match-patch                          && \
    conda install -y -n python3.6   distributed                               && \
    conda install -y -n python3.6   fastcache                                 && \
    conda install -y -n python3.6   fbprophet                                 && \
    conda install -y -n python3.6   filelock                                  && \
    conda install -y -n python3.6   flake8                                    && \
    conda install -y -n python3.6   flask                                     && \
    conda install -y -n python3.6   flask-cors                                && \
    conda install -y -n python3.6   Flask-SQLAlchemy                          && \
    conda install -y -n python3.6   fontconfig                                && \
    conda install -y -n python3.6   freetype                                  && \
    conda install -y -n python3.6   fribidi                                   && \
    conda install -y -n python3.6   fsspec                                    && \
    conda install -y -n python3.6   funcy                                     && \
    conda install -y -n python3.6   future                                    && \
    conda install -y -n python3.6   gast                                      && \
    conda install -y -n python3.6   get_terminal_size                         && \
    conda install -y -n python3.6   gevent                                    && \
    conda install -y -n python3.6   gitdb                                     && \
    conda install -y -n python3.6   gitpython                                 && \
    conda install -y -n python3.6   glib                                      && \
    conda install -y -n python3.6   gmp                                       && \
    conda install -y -n python3.6   gmpy2                                     && \
    conda install -y -n python3.6   gorilla                                   && \
    conda install -y -n python3.6   graphite2                                 && \
    conda install -y -n python3.6   greenlet                                  && \
    conda install -y -n python3.6   gst-plugins-base                          && \
    conda install -y -n python3.6   gstreamer                                 && \
    conda install -y -n python3.6   gunicorn                                  && \
    conda install -y -n python3.6   harfbuzz                                  && \
    conda install -y -n python3.6   hdf5                                      && \
    conda install -y -n python3.6   heapdict                                  && \
    conda install -y -n python3.6   holidays                                  && \
    conda install -y -n python3.6   html5lib                                  && \
    conda install -y -n python3.6   htmlmin                                   && \
    conda install -y -n python3.6   icu                                       && \
    conda install -y -n python3.6   imagehash                                 && \
    conda install -y -n python3.6   imagesize                                 && \
    conda install -y -n python3.6   imbalanced-learn                          && \
    conda install -y -n python3.6   intel-openmp                              && \
    conda install -y -n python3.6   intervaltree                              && \
    conda install -y -n python3.6   isodate                                   && \
    conda install -y -n python3.6   isort                                     && \
    conda install -y -n python3.6   itsdangerous                              && \
    conda install -y -n python3.6   jbig                                      && \
    conda install -y -n python3.6   jdcal                                     && \
    conda install -y -n python3.6   jeepney                                   && \
    conda install -y -n python3.6   jpeg                                      && \
    conda install -y -n python3.6   keyring                                   && \
    conda install -y -n python3.6   kmodes                                    && \
    conda install -y -n python3.6   lazy-object-proxy                         && \
    conda install -y -n python3.6   lcms2                                     && \
    conda install -y -n python3.6   libarchive                                && \
    conda install -y -n python3.6   libcurl                                   && \
    conda install -y -n python3.6   libedit                                   && \
    conda install -y -n python3.6   libffi                                    && \
    conda install -y -n python3.6   libgcc-ng                                 && \
    conda install -y -n python3.6   libgfortran-ng                            && \
    conda install -y -n python3.6   liblief                                   && \
    conda install -y -n python3.6   libllvm9                                  && \
    conda install -y -n python3.6   libpng                                    && \
    conda install -y -n python3.6   libsodium                                 && \
    conda install -y -n python3.6   libspatialindex                           && \
    conda install -y -n python3.6   libssh2                                   && \
    conda install -y -n python3.6   libstdcxx-ng                              && \
    conda install -y -n python3.6   libtiff                                   && \
    conda install -y -n python3.6   libtool                                   && \
    conda install -y -n python3.6   libuuid                                   && \
    conda install -y -n python3.6   libxcb                                    && \
    conda install -y -n python3.6   libxml2                                   && \
    conda install -y -n python3.6   libxslt                                   && \
    conda install -y -n python3.6   locket                                    && \
    conda install -y -n python3.6   lunarcalendar                             && \
    conda install -y -n python3.6   lz4-c                                     && \
    conda install -y -n python3.6   lzo                                       && \
    conda install -y -n python3.6   Mako                                      && \
    conda install -y -n python3.6   matplotlib-base                           && \
    conda install -y -n python3.6   mccabe                                    && \
    conda install -y -n python3.6   missingno                                 && \
    conda install -y -n python3.6   mkl                                       && \
    conda install -y -n python3.6   mlflow                                    && \
    conda install -y -n python3.6   mlxtend                                   && \
    conda install -y -n python3.6   mpc                                       && \
    conda install -y -n python3.6   mpfr                                      && \
    conda install -y -n python3.6   msgpack-python                            && \
    conda install -y -n python3.6   msrest                                    && \
    conda install -y -n python3.6   multipledispatch                          && \
    conda install -y -n python3.6   murmurhash                                && \
    conda install -y -n python3.6   navigator-updater                         && \
    conda install -y -n python3.6   ncurses                                   && \
    conda install -y -n python3.6   nose                                      && \
    conda install -y -n python3.6   numpy-base                                && \
    conda install -y -n python3.6   numpydoc                                  && \
    conda install -y -n python3.6   odo                                       && \
    conda install -y -n python3.6   openpyxl                                  && \
    conda install -y -n python3.6   pamela                                    && \
    conda install -y -n python3.6   pandas-profiling                          && \
    conda install -y -n python3.6   pandoc                                    && \
    conda install -y -n python3.6   pango                                     && \
    conda install -y -n python3.6   parmap                                    && \
    conda install -y -n python3.6   partd                                     && \
    conda install -y -n python3.6   patchelf                                  && \
    conda install -y -n python3.6   path                                      && \
    conda install -y -n python3.6   path.py                                   && \
    conda install -y -n python3.6   pathlib2                                  && \
    conda install -y -n python3.6   pathtools                                 && \
    conda install -y -n python3.6   pcre                                      && \
    conda install -y -n python3.6   pdf2image                                 && \
    conda install -y -n python3.6   pep8                                      && \
    conda install -y -n python3.6   phik                                      && \
    conda install -y -n python3.6   pixman                                    && \
    conda install -y -n python3.6   pkginfo                                   && \
    conda install -y -n python3.6   plac                                      && \
    conda install -y -n python3.6   ply                                       && \
    conda install -y -n python3.6   preshed                                   && \
    conda install -y -n python3.6   prometheus_client                         && \
    conda install -y -n python3.6   fbprophet                                 && \
    conda install -y -n python3.6   pycaret                                   && \
    conda install -y -n python3.6   pycodestyle                               && \
    conda install -y -n python3.6   pycosat                                   && \
    conda install -y -n python3.6   pycurl                                    && \
    conda install -y -n python3.6   pydocstyle                                && \
    conda install -y -n python3.6   pyflakes                                  && \
    conda install -y -n python3.6   pyldavis                                  && \
    conda install -y -n python3.6   py-lief                                   && \
    conda install -y -n python3.6   pylint                                    && \
    conda install -y -n python3.6   pymeeus                                   && \
    conda install -y -n python3.6   pyod                                      && \
    conda install -y -n python3.6   pyqt                                      && \
    conda install -y -n python3.6   PyQt5-sip                                 && \
    conda install -y -n python3.6   pystan                                    && \
    conda install -y -n python3.6   pytables                                  && \
    conda install -y -n python3.6   pytesseract                               && \
    conda install -y -n python3.6   pytest-astropy                            && \
    conda install -y -n python3.6   pytest-doctestplus                        && \
    conda install -y -n python3.6   pytest-openfiles                          && \
    conda install -y -n python3.6   pytest-remotedata                         && \
    conda install -y -n python3.6   pytest-runner                             && \
    conda install -y -n python3.6   python-bidi                               && \
    conda install -y -n python3.6   python-dateutil                           && \
    conda install -y -n python3.6   python-editor                             && \
    conda install -y -n python3.6   python-graphviz                           && \
    conda install -y -n python3.6   python-json-logger                        && \
    conda install -y -n python3.6   python-jsonrpc-server                     && \
    conda install -y -n python3.6   python-language-server                    && \
    conda install -y -n python3.6   python-libarchive-c                       && \
    conda install -y -n python3.6   python-oauth2                             && \
    conda install -y -n python3.6   pyxdg                                     && \
    conda install -y -n python3.6   qtconsole                                 && \
    conda install -y -n python3.6   qtpy                                      && \
    conda install -y -n python3.6   readline                                  && \
    conda install -y -n python3.6   livereload                                && \
    conda install -y -n python3.6   ripgrep                                   && \
    conda install -y -n python3.6   rope                                      && \
    conda install -y -n python3.6   scikit-plot                               && \
    conda install -y -n python3.6   sentencepiece                             && \
    conda install -y -n python3.6   setuptools-git                            && \
    conda install -y -n python3.6   setuptools-scm                            && \
    conda install -y -n python3.6   simplegeneric                             && \
    conda install -y -n python3.6   singledispatch                            && \
    conda install -y -n python3.6   sip                                       && \
    conda install -y -n python3.6   scikit-learn                              && \
    conda install -y -n python3.6   sphinx                                    && \
    conda install -y -n python3.6   sphinxcontrib                             && \
    conda install -y -n python3.6   sphinxcontrib-applehelp                   && \
    conda install -y -n python3.6   sphinxcontrib-devhelp                     && \
    conda install -y -n python3.6   sphinxcontrib-jsmath                      && \
    conda install -y -n python3.6   sphinxcontrib-qthelp                      && \
    conda install -y -n python3.6   sphinxcontrib-serializinghtml             && \
    conda install -y -n python3.6   sphinxcontrib-websupport                  && \
    conda install -y -n python3.6   spyder                                    && \
    conda install -y -n python3.6   spyder-kernels                            && \
    conda install -y -n python3.6   sqlalchemy                                && \
    conda install -y -n python3.6   sqlite                                    && \
    conda install -y -n python3.6   sqlparse                                  && \
    conda install -y -n python3.6   srsly                                     && \
    conda install -y -n python3.6   tablib                                    && \
    conda install -y -n python3.6   tabulate                                  && \
    conda install -y -n python3.6   tangled-up-in-unicode                     && \
    conda install -y -n python3.6   tbb                                       && \
    conda install -y -n python3.6   tblib                                     && \
    conda install -y -n python3.6   tesseract                                 && \
    conda install -y -n python3.6   textblob                                  && \
    conda install -y -n python3.6   thinc                                     && \
    conda install -y -n python3.6   time                                      && \
    conda install -y -n python3.6   tk                                        && \
    conda install -y -n python3.6   toolz                                     && \
    conda install -y -n python3.6   typing                                    && \
    conda install -y -n python3.6   ujson                                     && \
    conda install -y -n python3.6   umap-learn                                && \
    conda install -y -n python3.6   unicodecsv                                && \
    conda install -y -n python3.6   unixodbc                                  && \
    conda install -y -n python3.6   visions                                   && \
    conda install -y -n python3.6   wasabi                                    && \
    conda install -y -n python3.6   watchdog                                  && \
    conda install -y -n python3.6   websocket-client                          && \
    conda install -y -n python3.6   wordcloud                                 && \
    conda install -y -n python3.6   wurlitzer                                 && \
    conda install -y -n python3.6   xlrd                                      && \
    conda install -y -n python3.6   xlsxwriter                                && \
    conda install -y -n python3.6   xlwt                                      && \
    conda install -y -n python3.6   xmltodict                                 && \
    conda install -y -n python3.6   xz                                        && \
    conda install -y -n python3.6   yaml                                      && \
    conda install -y -n python3.6   yapf                                      && \
    conda install -y -n python3.6   yellowbrick                               && \
    conda install -y -n python3.6   zeromq                                    && \
    conda install -y -n python3.6   zict                                      && \
    conda install -y -n python3.6   zlib                                      && \
    conda install -y -n python3.6   zope                                      && \
    conda install -y -n python3.6   zope.event                                && \
    conda install -y -n python3.6   zope.interface                            && \
    conda install -y -n python3.6   zstd                                      && \
    conda clean -a

RUN conda install -y -n python3.6 tokenizers && \
    conda install -y -n python3.6 -c sas-institute swat && \
    conda install -y -n python3.6 schedule && \
    conda install -y -n python3.6 selenium && \
    conda clean -a

RUN conda install -y -n python3.6 pycodestyle==2.6.0 && \
    conda install -y -n python3.6 pyflakes==2.4.0 && \
    conda install -y -n python3.6 cmdstanpy==0.9.5 && \
    conda install -y -n python3.6 mlflow && \
    conda clean -a
