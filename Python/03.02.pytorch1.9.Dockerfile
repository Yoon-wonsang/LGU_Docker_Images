FROM conda.docker.repository.cloudera.com/cdsw/engine:13

RUN /opt/conda/envs/python3.6/bin/pip install torch==1.9.1+cu111 torchvision==0.10.1+cu111 torchaudio==0.9.1 -f https://download.pytorch.org/whl/torch_stable.html

RUN git clone https://github.com/SKTBrain/KoBERT.git && \
    cd KoBERT && \
    /opt/conda/envs/python3.6/bin/pip install -r requirements.txt && \
    /opt/conda/envs/python3.6/bin/pip install .

#RUN pip3 install torch==1.8.2+cu111 torchvision==0.9.2+cu111 torchaudio==0.8.2 -f https://download.pytorch.org/whl/lts/1.8/torch_lts.html
