#!/bin/bash
export CXX=hipcc
export CC=hipcc
DS_BUILD_EVOFORMER_ATTN=0 DS_BUILD_CUTLASS_OPS=0 DS_BUILD_OPS=1 HIP_PLATFORM_AMD=1 DS_ACCELERATOR='cuda' python3 setup.py install bdist_wheel
