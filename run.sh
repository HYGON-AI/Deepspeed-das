#!/bin/bash
export LIBRARY_PATH=/usr/local/lib:$LIBRARY_PATH
#export DS_BUILD_VERSION=dtk22.10.1
export LD_LIBRARY_PATH=/usr/local/lib/python3.7/site-packages/torch/lib:$LD_LIBRARY_PATH
DS_BUILD_STRING=.dtk22.10.1.torch1.10 DS_BUILD_RANDOM_LTD=0 DS_BUILD_QUANTIZER=0 DS_BUILD_TRANSFORMER_INFERENCE=0 DS_BUILD_OPS=1 verbose=1 CXX=hipcc CC=hipcc python3 setup.py install bdist_wheel
