# <div align="center"><strong>DeepSpeed</strong></div>
## 简介
DeepSpeed是一个深度学习优化库，使分布式训练和推理变的简单、高效和有效。DeepSpeed官方github地址:[https://github.com/microsoft/DeepSpeed](https://github.com/microsoft/DeepSpeed)

## 安装

### 使用pip方式安装
DeepSpeed whl包下载目录：[https://cancon.hpccube.com:65024/4/main/deepspeed/dtk23.10](https://cancon.hpccube.com:65024/4/main/deepspeed/dtk23.10)
根据对应的pytorch版本和python版本，下载对应deepspeed的whl包
```shell
pip install deepspeed* (下载的deepspeed的whl包)
```
### 使用源码编译方式安装

#### 编译环境准备
提供2种环境准备方式：

1. 基于光源pytorch基础镜像环境：镜像下载地址：[https://sourcefind.cn/#/image/dcu/pytorch](https://sourcefind.cn/#/image/dcu/pytorch)，根据pytorch、python、dtk及系统下载对应的镜像版本。

2. 基于现有python环境：安装pytorch，pytorch whl包下载目录：[https://cancon.hpccube.com:65024/4/main/pytorch/dtk23.10](https://cancon.hpccube.com:65024/4/main/pytorch/dtk23.10)，根据python、dtk版本,下载对应pytorch的whl包。安装命令如下：
```shell
pip install torch* (下载的torch的whl包)
pip install setuptools==59.5.0 wheel
yum install -y libaio-devel
yum install -y libaio
```

#### 源码编译安装
- 代码下载
```shell
git clone -b ds-v0.12.3-rocm http://developer.hpccube.com/codes/aicomponent/deepspeed.git # 根据编译需要切换分支
```
- 编译deepspeed：
```
1. 设置环境变量
cd deepspeed
pip3 install -r  requirements/requirements.txt  -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
pip3 install -r  requirements/requirements-dev.txt  -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com --no-deps

source /opt/dtk/env.sh
export BUILD_ROOT=`pwd`
echo $BUILD_ROOT
export LD_LIBRARY_PATH=/usr/local/lib/python3.8/site-packages/torch/lib:$BUILD_ROOT/libaio_build/lib:$LD_LIBRARY_PATH
export C_INCLUDE_PATH=$BUILD_ROOT/libaio_build/include:$C_INCLUDE_PATH
export C_PLUS_INCLUDE_PATH=$C_INCLUDE_PATH
export CFLAGS="-Ithird_party/libaio_build/include/"
export LDFLAGS="-Lthird_party/libaio_build/lib/"

2. 编译whl包
export CXX=hipcc
export CC=hipcc
DS_BUILD_EVOFORMER_ATTN=0 DS_BUILD_CUTLASS_OPS=0 DS_BUILD_OPS=1 HIP_PLATFORM_AMD=1 DS_ACCELERATOR='cuda' python3 setup.py install bdist_wheel

3. 安装
pip3 install ./dist/deepspeed*.whl
```

## 版本号查询
- python -c "import deepspeed; print(deepspeed.\_\_version__)"，查询软件版本，版本号与官方版本同步；
- python -c "import deepspeed; print(deepspeed.\_\_dcu_version__)"，查询基于dcu的内部版本号；

## Known Issue
- 无

## Note
+ 若使用pip install下载安装过慢，可添加pypi清华源：-i https://pypi.tuna.tsinghua.edu.cn/simple/
+ ROCM_PATH为dtk的路径，默认为/opt/dtk

## 其他参考
- [README_ORIGIN](README_ORIGIN.md)
- [https://github.com/microsoft/DeepSpeed](https://github.com/microsoft/DeepSpeed)
