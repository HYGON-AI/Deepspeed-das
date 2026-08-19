# DeepSpeed Build workflow

## Source build / wheel build

Use this when the user explicitly wants a compiled package.

### Prerequisites
```bash
cd {project_root}/requirements/

pip3 install -r  requirements-autotuning-ml.txt  -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
pip3 install -r  requirements-1bit-mpi.txt  -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
pip3 install -r  requirements-autotuning.txt  -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
pip3 install -r  requirements-inf.txt  -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com --no-deps
pip3 install -r  requirements-sd.txt  -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
pip3 install -r  requirements.txt  -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
pip3 install -r  requirements-dev.txt  -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com --no-deps

pip install  pluggy -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
pip install  iniconfig  -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
pip install  execnet  -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
pip install  evaluate  -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
pip install  cupy  -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
```

### Compile from source

(optional): install libaio first:

`sudo apt install libaio-dev`
```
DS_BUILD_SPARSE_ATTN=0 DS_BUILD_EVOFORMER_ATTN=0 DS_BUILD_CUTLASS_OPS=1 DS_BUILD_FP_QUANTIZER=1 DS_BUILD_GDS=1   DS_BUILD_DEEP_COMPILE=1 DS_BUILD_OPS=1  DS_ACCELERATOR='cuda' python3 setup.py install bdist_wheel
````