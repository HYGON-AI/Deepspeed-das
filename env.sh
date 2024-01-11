#!/bin/bash
source /opt/dtk/env.sh
export BUILD_ROOT=`pwd`
echo $BUILD_ROOT
export LD_LIBRARY_PATH=/usr/local/lib/python3.8/site-packages/torch/lib:$BUILD_ROOT/libaio_build/lib:$LD_LIBRARY_PATH
export C_INCLUDE_PATH=$BUILD_ROOT/libaio_build/include:$C_INCLUDE_PATH
export C_PLUS_INCLUDE_PATH=$C_INCLUDE_PATH
export CFLAGS="-Ithird_party/libaio_build/include/"
export LDFLAGS="-Lthird_party/libaio_build/lib/"
