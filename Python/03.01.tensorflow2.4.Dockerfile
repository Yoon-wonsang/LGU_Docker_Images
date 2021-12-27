FROM conda.docker.repository.cloudera.com/cdsw/engine:13

#분석패키지 추가
 RUN /opt/conda/envs/python3.6/bin/pip install --no-cache-dir --no-clean -v netifaces \
        tensorflow-gpu==2.4 

#RUN /opt/conda/envs/python3.6/bin/pip install --no-cache-dir --no-clean -v netifaces \
#        tensorflow==2.4
