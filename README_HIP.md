# DeepSpeed

## 安装
DeepSpeed 支持
+ Python 3.7.
+ Python 3.8.
+ Python 3.9.

### 使用pip安装
DeepSpeed whl包下载目录：[https://cancon.hpccube.com:65024/4/main/deepspeed/dtk23.04](https://cancon.hpccube.com:65024/4/main/deepspeed/dtk23.04)
根据对应的pytorch版本和python版本，下载对应deepspeed的whl包

```shell
pip install deepspeed* (下载的deepspeed的whl包)
```

### 使用源码安装
编译之前，需要先安装对应版本python，安装相应的三方包依赖项，并配置DTK环境变量(以Centos7.x为例)。

pytorch whl包下载目录：[https://cancon.hpccube.com:65024/4/main/pytorch/dtk23.04](https://cancon.hpccube.com:65024/4/main/pytorch/dtk23.04)

根据python版本,下载对应pytorch的whl包。如果是基于pytorch1.13，需要注释掉op_builder/builder.py中大概L659： 
```bash
#sources[i] = str(src.relative_to(curr_file))
```
安装依赖项：
```bash
# 安装三方包的源
yum install  epel-release  -y

# 安装相关依赖项
                        
yum install libffi-devel -y
yum -y install openssl openssl-devel
                       
yum install -y libaio-devel
yum install -y libaio
ls -l

# 若python内未包含相关项，需基于上面安装的三方包重新源码编译python，再配置python环境
python3 -m pip install --upgrade pip setuptools
pip3 install wheel -i https://pypi.tuna.tsinghua.edu.cn/simple
pip3 install ninja -i https://pypi.tuna.tsinghua.edu.cn/simple



# 下载DTK并配置环境变量
# DTK tar包下载目录：光合社区/资源工具/DCU Toolkit/DTK23.04(https://cancon.hpccube.com:65024/1/main/DTK-23.04)，根据系统选择对应DTK的tar包，并解压至/opt目录。
# 如果使用的是dtk23.04前的版本，可以参考以下方式修改torch中的hipify文件(http://10.0.50.24/dcutoolkit/deeplearing/pytorch/-/commit/badafea7f4a06111d8d8b5b36859bc89f3cda305)
export ROCM_PATH=/opt/dtk-23.04
source /opt/dtk-23.04/env.sh
```

编译deepspeed

```bash
# 下载源码 
git clone -b ds-v0.8.2-rocm http://developer.hpccube.com/codes/aicomponent/deepspeed.git
cd deepspeed
sh requirements/run_pip.sh
export DS_BUILD_VERSION=abix.dtkxxx
DS_BUILD_RANDOM_LTD=0 DS_BUILD_QUANTIZER=0 DS_BUILD_TRANSFORMER_INFERENCE=0 DS_BUILD_OPS=1 verbose=1 CXX=hipcc CC=hipcc python3 setup.py install bdist_wheel
```

安装deepspeed

```bash
# nni的whl包会在dist文件夹生成
pip3 install ./dist/deepspeed*
```

## Note
+ 若使用 pip install 下载安装过慢，可添加源：-i https://pypi.tuna.tsinghua.edu.cn/simple/
+ DS_BUILD_VERSION为编译的版本号设置，版本号为0.8.2+gitxxx.abix.dtkxxx 
gitxxx：为代码自动获取；abi0：使用devtools的gcc编译；abi1：使用非devtools的gcc编译; dtkxxx为dtk的版本号：例如：dtk2304