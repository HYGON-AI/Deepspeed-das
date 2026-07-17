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

1. 基于光源pytorch基础镜像环境,根据pytorch、python、dtk及系统下载对应的镜像版本。

2. 基于现有python环境：安装pytorch，pytorch whl包下载目录：[https://cancon.hpccube.com:65024/4/main/pytorch/dtk23.10](https://cancon.hpccube.com:65024/4/main/pytorch/dtk23.10)，根据python、dtk版本,下载对应pytorch的whl包。安装命令如下：
```shell
pip install torch* (下载的torch的whl包)
pip install setuptools==59.5.0 wheel
yum install -y libaio-devel
yum install -y libaio

## Office Hours

DeepSpeed hosts regular office hours on the last Tuesday of each month at 12:00 America/New_York to discuss development plans, features, etc.  This meeting is public for anyone to join and ask questions.
The meeting is hosted on Zoom and can be joined [here](https://zoom-lfx.platform.linuxfoundation.org/meeting/93902569995?password=7d9c4fc9-3efa-4715-88f0-df8a6deb008b).

## Latest News

* [2026/05] [Using Muon Optimizer with DeepSpeed](https://github.com/deepspeedai/DeepSpeed/blob/master/blogs/muon-optimizer/README.md)

* [2026/05] [System DMA (SDMA) for ZeRO-3: offload collectives off compute units on AMD GPUs for better overlap](https://github.com/deepspeedai/DeepSpeed/blob/master/examples/sdma_allgather/README.md)

* [2026/03] DeepSpeed Team gave a tutorial at ASPLOS 2026 titled ["Building Efficient Large-Scale Model Systems with DeepSpeed: From Open-Source Foundations to Emerging Research" ](https://supercomputing-system-ai-lab.github.io/events/asplos2026-llm-tutorial/index.html)

* [2026/03] [Our SuperOffload work received an Honorable Mention for the ASPLOS 2026 Best Paper Award](https://dl.acm.org/doi/10.1145/3760250.3762217)

* [2025/12] [DeepSpeed Core API updates: PyTorch-style backward and low-precision master states](https://github.com/deepspeedai/DeepSpeed/blob/master/blogs/core_api_update/README.md)

* [2025/11] [DeepSpeed ZeRO++ powers large-scale distillation training of LLMs for Recommendation Systems at LinkedIn](https://aclanthology.org/2025.emnlp-industry.119/)

* [2025/10] We hosted the [Ray x DeepSpeed Meetup](https://luma.com/3wctqteh) at Anyscale. We shared our most recent work on SuperOffload, ZenFlow, Muon Optimizer Support, Arctic Long Sequence Training and DeepCompile. Please find the meetup slides [here](https://docs.google.com/presentation/d/1eM3mY6oW9GYkRy1Xz0iOnbbEr5T1t0JJXOM5BKtR-Ks/edit?slide=id.g38615d6b4c2_0_87#slide=id.g38615d6b4c2_0_87).

* [2025/10] [SuperOffload: Unleashing the Power of Large-Scale LLM Training on Superchips](https://pytorch.org/blog/superoffload-unleashing-the-power-of-large-scale-llm-training-on-superchips/)

* [2025/10] [Study of ZenFlow and ZeRO offload performance with DeepSpeed CPU core binding](https://github.com/deepspeedai/DeepSpeed/blob/master/blogs/zenflow-corebinding/README.md)

* [2025/08] [ZenFlow: Stall-Free Offloading Engine for LLM Training](https://pytorch.org/blog/zenflow-stall-free-offloading-engine-for-llm-training/)

* [2025/06] [Arctic Long Sequence Training (ALST) with DeepSpeed: Scalable And Efficient Training For Multi-Million Token Sequences](https://www.snowflake.com/en/engineering-blog/arctic-long-sequence-training-multi-million-token-ai/)

* [2025/06] [DeepNVMe: Affordable I/O scaling for Deep Learning Applications](https://github.com/deepspeedai/DeepSpeed/blob/master/blogs/deepnvme/06-2025/README.md)


<!-- NOTE: we must use html for news items otherwise links will be broken in the 'more news' section -->
<details>
<!-- NOTE: Maintain only three items in 'more news' section -->
 <summary>More news</summary>
 <ul>

   <li>[2025/04] <a href="https://github.com/deepspeedai/DeepSpeed/blob/master/blogs/deepcompile/README.md">DeepCompile: Unlocking Compiler Optimization for Distributed Training</a></li>

   <li>[2025/03] <a href="https://github.com/deepspeedai/DeepSpeed/blob/master/blogs/huggingface-tp/README.md">DeepSpeed AutoTP: Automatic Tensor Parallel Training of Hugging Face models</a></li>

<li>[2024/12] <a href="https://github.com/deepspeedai/DeepSpeed/blob/master/blogs/ulysses-offload/README.md">Ulysses-Offload: Democratizing Long Context LLM Training</a></li>

 </ul>
</details>

---

# Extreme Speed and Scale for DL Training

***[DeepSpeed](https://www.deepspeed.ai/) enabled the world's most powerful language models (at the time of this writing) such as [MT-530B](https://www.microsoft.com/en-us/research/blog/using-deepspeed-and-megatron-to-train-megatron-turing-nlg-530b-the-worlds-largest-and-most-powerful-generative-language-model/) and [BLOOM](https://huggingface.co/blog/bloom-megatron-deepspeed)***. DeepSpeed offers a confluence of [system innovations](https://www.deepspeed.ai/training/), that has made large scale DL training effective, and efficient, greatly improved ease of use, and redefined the DL training landscape in terms of scale that is possible. These innovations include ZeRO, ZeRO-Infinity, 3D-Parallelism, Ulysses Sequence Parallelism, DeepSpeed-MoE, etc.

---

# DeepSpeed Adoption

DeepSpeed was an important part of Microsoft’s
[AI at Scale](https://www.microsoft.com/en-us/research/project/ai-at-scale/)
initiative to enable next-generation AI capabilities at scale, where you can find more
information [here](https://innovation.microsoft.com/en-us/exploring-ai-at-scale).

DeepSpeed has been used to train many different large-scale models, below is a list of several examples that we are aware of (if you'd like to include your model please submit a PR):

  * [Megatron-Turing NLG (530B)](https://www.microsoft.com/en-us/research/blog/using-deepspeed-and-megatron-to-train-megatron-turing-nlg-530b-the-worlds-largest-and-most-powerful-generative-language-model/)
  * [Jurassic-1 (178B)](https://uploads-ssl.webflow.com/60fd4503684b466578c0d307/61138924626a6981ee09caf6_jurassic_tech_paper.pdf)
  * [BLOOM (176B)](https://huggingface.co/blog/bloom-megatron-deepspeed)
  * [GLM (130B)](https://github.com/THUDM/GLM-130B)
  * [xTrimoPGLM (100B)](https://www.biorxiv.org/content/10.1101/2023.07.05.547496v2)
  * [YaLM (100B)](https://github.com/yandex/YaLM-100B)
  * [GPT-NeoX (20B)](https://github.com/EleutherAI/gpt-neox)
  * [AlexaTM (20B)](https://www.amazon.science/blog/20b-parameter-alexa-model-sets-new-marks-in-few-shot-learning)
  * [Turing NLG (17B)](https://www.microsoft.com/en-us/research/blog/turing-nlg-a-17-billion-parameter-language-model-by-microsoft/)
  * [METRO-LM (5.4B)](https://arxiv.org/pdf/2204.06644.pdf)

DeepSpeed has been integrated with several different popular open-source DL frameworks such as:

|                                                                                                | Documentation                                |
| ---------------------------------------------------------------------------------------------- | -------------------------------------------- |
<img src="docs/assets/images/transformers-light.png#gh-light-mode-only" width="250px"><img src="docs/assets/images/transformers-dark.png#gh-dark-mode-only" width="250px"> | [Transformers with DeepSpeed](https://huggingface.co/docs/transformers/deepspeed) |
| <img src="docs/assets/images/accelerate-light.png#gh-light-mode-only" width="250px"><img src="docs/assets/images/accelerate-dark.png#gh-dark-mode-only" width="250px"> | [Accelerate with DeepSpeed](https://huggingface.co/docs/accelerate/usage_guides/deepspeed) |
| <img src="docs/assets/images/lightning-light.svg#gh-light-mode-only" width="200px"><img src="docs/assets/images/lightning-dark.svg#gh-dark-mode-only" width="200px"> | [Lightning with DeepSpeed](https://lightning.ai/docs/pytorch/stable/advanced/model_parallel.html#deepspeed) |
| <img src="docs/assets/images/mosaicml.svg" width="200px"> | [MosaicML with DeepSpeed](https://docs.mosaicml.com/projects/composer/en/latest/trainer/using_the_trainer.html?highlight=deepspeed#deepspeed-integration) |
| <img src="docs/assets/images/determined.svg" width="225px"> | [Determined with DeepSpeed](https://docs.determined.ai/latest/training/apis-howto/deepspeed/overview.html) |
| <img src="https://user-images.githubusercontent.com/58739961/187154444-fce76639-ac8d-429b-9354-c6fac64b7ef8.jpg" width=150> | [MMEngine with DeepSpeed](https://mmengine.readthedocs.io/en/latest/common_usage/large_model_training.html#deepspeed) |

---

# Build Pipeline Status

| Description | Status |
| ----------- | ------ |
| NVIDIA | [![nv-pre-compile-ops](https://github.com/deepspeedai/DeepSpeed/actions/workflows/nv-pre-compile-ops.yml/badge.svg)](https://github.com/deepspeedai/DeepSpeed/actions/workflows/nv-pre-compile-ops.yml) [![aws-torch-latest](https://github.com/deepspeedai/DeepSpeed/actions/workflows/aws-torch-latest.yml/badge.svg)](https://github.com/deepspeedai/DeepSpeed/actions/workflows/aws-torch-latest.yml) |
| AMD | [![amd-mi200](https://github.com/deepspeedai/DeepSpeed/actions/workflows/amd-mi200.yml/badge.svg?branch=master)](https://github.com/deepspeedai/DeepSpeed/actions/workflows/amd-mi200.yml) |
| CPU | [![torch-latest-cpu](https://github.com/deepspeedai/DeepSpeed/actions/workflows/cpu-torch-latest.yml/badge.svg?branch=master)](https://github.com/deepspeedai/DeepSpeed/actions/workflows/cpu-torch-latest.yml) |
| Intel Gaudi | [![hpu-gaudi2](https://github.com/deepspeedai/DeepSpeed/actions/workflows/hpu-gaudi2.yml/badge.svg?branch=master)](https://github.com/deepspeedai/DeepSpeed/actions/workflows/hpu-gaudi2.yml) |
| Intel XPU | [![xpu-max1100](https://github.com/deepspeedai/DeepSpeed/actions/workflows/xpu-max1100.yml/badge.svg?branch=master)](https://github.com/deepspeedai/DeepSpeed/actions/workflows/xpu-max1100.yml) |
| Integrations | [![aws-accelerate](https://github.com/deepspeedai/DeepSpeed/actions/workflows/aws-accelerate.yml/badge.svg)](https://github.com/deepspeedai/DeepSpeed/actions/workflows/aws-accelerate.yml) |
| Misc | [![Formatting](https://github.com/deepspeedai/DeepSpeed/actions/workflows/formatting.yml/badge.svg?branch=master)](https://github.com/deepspeedai/DeepSpeed/actions/workflows/formatting.yml) [![pages-build-deployment](https://github.com/deepspeedai/DeepSpeed/actions/workflows/pages/pages-build-deployment/badge.svg)](https://github.com/deepspeedai/DeepSpeed/actions/workflows/pages/pages-build-deployment) [![Documentation Status](https://readthedocs.org/projects/deepspeed/badge/?version=latest)](https://deepspeed.readthedocs.io/en/latest/?badge=latest)[![python](https://github.com/deepspeedai/DeepSpeed/actions/workflows/python.yml/badge.svg?branch=master)](https://github.com/deepspeedai/DeepSpeed/actions/workflows/python.yml) |
| Huawei Ascend NPU | [![Huawei Ascend NPU](https://github.com/Ascend/Ascend-CI/actions/workflows/deepspeed.yaml/badge.svg?branch=main)](https://github.com/Ascend/Ascend-CI/actions/workflows/deepspeed.yaml) |

# Installation

The quickest way to get started with DeepSpeed is via pip, this will install
the latest release of DeepSpeed which is not tied to specific PyTorch or CUDA
versions. DeepSpeed includes several C++/CUDA extensions that we commonly refer
to as our 'ops'.  By default, all of these extensions/ops will be built
just-in-time (JIT) using [torch's JIT C++ extension loader that relies on
ninja](https://pytorch.org/docs/stable/cpp_extension.html) to build and
dynamically link them at runtime.

## Requirements
* [PyTorch](https://pytorch.org/) must be installed _before_ installing DeepSpeed.
* For full feature support we recommend a version of PyTorch that is >= 2.0 and ideally the latest PyTorch stable release.
* A CUDA or ROCm compiler such as [nvcc](https://docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/#introduction) or [hipcc](https://github.com/ROCm-Developer-Tools/HIPCC) used to compile C++/CUDA/HIP extensions.
* Specific GPUs we develop and test against are listed below, this doesn't mean your GPU will not work if it doesn't fall into this category it's just DeepSpeed is most well tested on the following:
  * NVIDIA: Pascal, Volta, Ampere, and Hopper architectures
  * AMD: MI100 and MI200

## Contributed HW support
* DeepSpeed now support various HW accelerators.

| Contributor | Hardware                            | Accelerator Name | Contributor validated | Upstream validated |
|-------------|-------------------------------------|------------------| --------------------- |--------------------|
| Huawei      | Huawei Ascend NPU                   | npu              | Yes | No                 |
| Intel       | Intel(R) Gaudi(R) 2 AI accelerator  | hpu              | Yes | Yes                |
| Intel       | Intel(R) Xeon(R) Processors         | cpu              | Yes | Yes                |
| Intel       | Intel(R) Data Center GPU Max series | xpu              | Yes | Yes                |
| Tecorigin   | Scalable Data Analytics Accelerator | sdaa             | Yes | No                 |

## PyPI
We regularly push releases to [PyPI](https://pypi.org/project/deepspeed/) and encourage users to install from there in most cases.

```bash
pip install deepspeed
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
source /opt/dtk/env.sh
export BUILD_ROOT=`pwd`
echo $BUILD_ROOT
export LD_LIBRARY_PATH=/usr/local/lib/python3.10/site-packages/torch/lib:$BUILD_ROOT/libaio_build/lib:$LD_LIBRARY_PATH
export C_INCLUDE_PATH=$BUILD_ROOT/libaio_build/include:$C_INCLUDE_PATH
export C_PLUS_INCLUDE_PATH=$C_INCLUDE_PATH
export CFLAGS="-I$BUILD_ROOT/third_party/libaio_build/include/"
export LDFLAGS="-L$BUILD_ROOT/third_party/libaio_build/lib/"

2. 编译whl包
export CXX=hipcc
export CC=hipcc
DS_BUILD_SPARSE_ATTN=0 DS_BUILD_EVOFORMER_ATTN=0 DS_BUILD_CUTLASS_OPS=0 DS_BUILD_FP_QUANTIZER=0  DS_BUILD_OPS=1  DS_ACCELERATOR='cuda' python3 setup.py install bdist_wheel

3. 安装
pip3 install ./dist/deepspeed*.whl
```

## 版本号查询
- python -c "import deepspeed; print(deepspeed.\_\_version__)"，查询软件版本，版本号与官方版本同步；
- python -c "import deepspeed; print(deepspeed.\_\_hcu_version__)"，查询基于hcu的内部版本号；

## Known Issue
- 无

## Note
+ 若使用pip install下载安装过慢，可添加pypi清华源：-i https://pypi.tuna.tsinghua.edu.cn/simple/
+ ROCM_PATH为dtk的路径，默认为/opt/dtk

## 其他参考
- [README_ORIGIN](README_ORIGIN.md)
- [https://github.com/microsoft/DeepSpeed](https://github.com/microsoft/DeepSpeed)

# Further Reading

All DeepSpeed documentation, tutorials, and blogs can be found on our website: [deepspeed.ai](https://www.deepspeed.ai/)


|                                                                                                | Description                                  |
| ---------------------------------------------------------------------------------------------- | -------------------------------------------- |
| [Getting Started](https://www.deepspeed.ai/getting-started/)                                   |  First steps with DeepSpeed                  |
| [DeepSpeed JSON Configuration](https://www.deepspeed.ai/docs/config-json/)                     |  Configuring DeepSpeed                       |
| [API Documentation](https://deepspeed.readthedocs.io/en/latest/)                               |  Generated DeepSpeed API documentation       |
| [Tutorials](https://www.deepspeed.ai/tutorials/)                                               |  Tutorials                                   |
| [Blogs](https://www.deepspeed.ai/posts/)                                                       |  Blogs                                   |


# CI funding

This being an open source project we rely on others to provide us resources for CI hardware. At this moment Modal is kindly supporting our GPU CI runs by funding the hardware for us. Modal is an AI infrastructure platform for inference, fine-tuning, batch jobs and more. Get started with $30/mo in free credits today at https://modal.com. We have been getting an amazing support from Modal's team and will surely recommend them to your business.

# Contributing
DeepSpeed welcomes your contributions! Please see our
[contributing](CONTRIBUTING.md) guide for more details on formatting, testing,
etc.<br/>
Thanks so much to all of our amazing contributors!

<a href="https://github.com/deepspeedai/DeepSpeed/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=microsoft/DeepSpeed&r="  width="800px"/>
</a>

## Developer Certificate of Origin
This project welcomes contributions and suggestions. Most contributions require you to
agree to a Developer Certificate of Origin [DCO](https://wiki.linuxfoundation.org/dco)
stating that they agree to the terms published at https://developercertificate.org for
that *particular* contribution.

DCOs are per-commit, so each commit needs to be signed off.  These can be signed in
the commit by adding the `-s` flag.  DCO enforcement can also be signed off in the PR
itself by clicking on the DCO enforcement check.

## Code of Conduct
This project has adopted the [Microsoft Open Source Code of
Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the
[Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact
[opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

# Publications
1. Samyam Rajbhandari, Jeff Rasley, Olatunji Ruwase, Yuxiong He. (2019) ZeRO: memory optimizations toward training trillion parameter models. [arXiv:1910.02054](https://arxiv.org/abs/1910.02054) and [In Proceedings of the International Conference for High Performance Computing, Networking, Storage and Analysis (SC '20)](https://dl.acm.org/doi/10.5555/3433701.3433727).
2. Jeff Rasley, Samyam Rajbhandari, Olatunji Ruwase, and Yuxiong He. (2020) DeepSpeed: System Optimizations Enable Training Deep Learning Models with Over 100 Billion Parameters. [In Proceedings of the 26th ACM SIGKDD International Conference on Knowledge Discovery & Data Mining (KDD '20, Tutorial)](https://dl.acm.org/doi/10.1145/3394486.3406703).
3. Minjia Zhang, Yuxiong He. (2020) Accelerating Training of Transformer-Based Language Models with Progressive Layer Dropping. [arXiv:2010.13369](https://arxiv.org/abs/2010.13369) and [NeurIPS 2020](https://proceedings.neurips.cc/paper/2020/hash/a1140a3d0df1c81e24ae954d935e8926-Abstract.html).
4. Jie Ren, Samyam Rajbhandari, Reza Yazdani Aminabadi, Olatunji Ruwase, Shuangyan Yang, Minjia Zhang, Dong Li, Yuxiong He. (2021) ZeRO-Offload: Democratizing Billion-Scale Model Training. [arXiv:2101.06840](https://arxiv.org/abs/2101.06840) and [USENIX ATC 2021](https://www.usenix.org/conference/atc21/presentation/ren-jie). [[paper]](https://arxiv.org/abs/2101.06840) [[slides]](https://www.usenix.org/system/files/atc21_slides_ren-jie.pdf) [[blog]](https://www.microsoft.com/en-us/research/blog/deepspeed-extreme-scale-model-training-for-everyone/)
5. Hanlin Tang, Shaoduo Gan, Ammar Ahmad Awan, Samyam Rajbhandari, Conglong Li, Xiangru Lian, Ji Liu, Ce Zhang, Yuxiong He. (2021) 1-bit Adam: Communication Efficient Large-Scale Training with Adam's Convergence Speed. [arXiv:2102.02888](https://arxiv.org/abs/2102.02888) and [ICML 2021](http://proceedings.mlr.press/v139/tang21a.html).
6. Samyam Rajbhandari, Olatunji Ruwase, Jeff Rasley, Shaden Smith, Yuxiong He. (2021) ZeRO-Infinity: Breaking the GPU Memory Wall for Extreme Scale Deep Learning. [arXiv:2104.07857](https://arxiv.org/abs/2104.07857) and [SC 2021](https://dl.acm.org/doi/abs/10.1145/3458817.3476205). [[paper]](https://arxiv.org/abs/2104.07857) [[slides]](docs/assets/files/SC21-ZeRO-Infinity.pdf) [[blog]](https://www.microsoft.com/en-us/research/blog/zero-infinity-and-deepspeed-unlocking-unprecedented-model-scale-for-deep-learning-training/)
7. Conglong Li, Ammar Ahmad Awan, Hanlin Tang, Samyam Rajbhandari, Yuxiong He. (2021) 1-bit LAMB: Communication Efficient Large-Scale Large-Batch Training with LAMB's Convergence Speed. [arXiv:2104.06069](https://arxiv.org/abs/2104.06069) and [HiPC 2022](https://hipc.org/advance-program/).
8. Conglong Li, Minjia Zhang, Yuxiong He. (2021) The Stability-Efficiency Dilemma: Investigating Sequence Length Warmup for Training GPT Models. [arXiv:2108.06084](https://arxiv.org/abs/2108.06084) and [NeurIPS 2022](https://openreview.net/forum?id=JpZ5du_Kdh).
9. Yucheng Lu, Conglong Li, Minjia Zhang, Christopher De Sa, Yuxiong He. (2022) Maximizing Communication Efficiency for Large-scale Training via 0/1 Adam. [arXiv:2202.06009](https://arxiv.org/abs/2202.06009).
10. Samyam Rajbhandari, Conglong Li, Zhewei Yao, Minjia Zhang, Reza Yazdani Aminabadi, Ammar Ahmad Awan, Jeff Rasley, Yuxiong He. (2022) DeepSpeed-MoE: Advancing Mixture-of-Experts Inference and Training to Power Next-Generation AI Scale [arXiv:2201.05596](https://arxiv.org/abs/2201.05596) and [ICML 2022](https://proceedings.mlr.press/v162/rajbhandari22a.html). [[pdf]](https://arxiv.org/abs/2201.05596) [[slides]](docs/assets/files/ICML-5mins.pdf) [[blog]](https://www.microsoft.com/en-us/research/blog/deepspeed-advancing-moe-inference-and-training-to-power-next-generation-ai-scale/)
11. Shaden Smith, Mostofa Patwary, Brandon Norick, Patrick LeGresley, Samyam Rajbhandari, Jared Casper, Zhun Liu, Shrimai Prabhumoye, George Zerveas, Vijay Korthikanti, Elton Zhang, Rewon Child, Reza Yazdani Aminabadi, Julie Bernauer, Xia Song, Mohammad Shoeybi, Yuxiong He, Michael Houston, Saurabh Tiwary, Bryan Catanzaro. (2022) Using DeepSpeed and Megatron to Train Megatron-Turing NLG 530B, A Large-Scale Generative Language Model [arXiv:2201.11990](https://arxiv.org/abs/2201.11990).
12. Xiaoxia Wu, Zhewei Yao, Minjia Zhang, Conglong Li, Yuxiong He. (2022) Extreme Compression for Pre-trained Transformers Made Simple and Efficient. [arXiv:2206.01859](https://arxiv.org/abs/2206.01859) and [NeurIPS 2022](https://openreview.net/forum?id=xNeAhc2CNAl).
13. Zhewei Yao, Reza Yazdani Aminabadi, Minjia Zhang, Xiaoxia Wu, Conglong Li, Yuxiong He. (2022) ZeroQuant: Efficient and Affordable Post-Training Quantization for Large-Scale Transformers. [arXiv:2206.01861](https://arxiv.org/abs/2206.01861) and [NeurIPS 2022](https://openreview.net/forum?id=f-fVCElZ-G1) [[slides]](docs/assets/files/zeroquant_series.pdf) [[blog]](https://www.microsoft.com/en-us/research/blog/deepspeed-compression-a-composable-library-for-extreme-compression-and-zero-cost-quantization/)
14. Reza Yazdani Aminabadi, Samyam Rajbhandari, Minjia Zhang, Ammar Ahmad Awan, Cheng Li, Du Li, Elton Zheng, Jeff Rasley, Shaden Smith, Olatunji Ruwase, Yuxiong He. (2022) DeepSpeed Inference: Enabling Efficient Inference of Transformer Models at Unprecedented Scale. [arXiv:2207.00032](https://arxiv.org/abs/2207.00032) and [SC 2022](https://dl.acm.org/doi/abs/10.5555/3571885.3571946). [[paper]](https://arxiv.org/abs/2207.00032) [[slides]](docs/assets/files/sc22-ds-inference.pdf) [[blog]](https://www.microsoft.com/en-us/research/blog/deepspeed-accelerating-large-scale-model-inference-and-training-via-system-optimizations-and-compression/)
15. Zhewei Yao, Xiaoxia Wu, Conglong Li, Connor Holmes, Minjia Zhang, Cheng Li, Yuxiong He. (2022) Random-LTD: Random and Layerwise Token Dropping Brings Efficient Training for Large-scale Transformers. [arXiv:2211.11586](https://arxiv.org/abs/2211.11586).
16. Conglong Li, Zhewei Yao, Xiaoxia Wu, Minjia Zhang, Yuxiong He. (2022) DeepSpeed Data Efficiency: Improving Deep Learning Model Quality and Training Efficiency via Efficient Data Sampling and Routing. [arXiv:2212.03597](https://arxiv.org/abs/2212.03597) [ENLSP2023 Workshop at NeurIPS2023](https://neurips2023-enlsp.github.io/)
17. Xiaoxia Wu, Cheng Li, Reza Yazdani Aminabadi, Zhewei Yao, Yuxiong He. (2023) Understanding INT4 Quantization for Transformer Models: Latency Speedup, Composability, and Failure Cases. [arXiv:2301.12017](https://arxiv.org/abs/2301.12017) and [ICML2023](https://icml.cc/Conferences/2023).
18. Syed Zawad, Cheng Li, Zhewei Yao, Elton Zheng, Yuxiong He, Feng Yan. (2023) DySR: Adaptive Super-Resolution via Algorithm and System Co-design. [ICLR:2023](https://openreview.net/forum?id=Pgtn4l6eKjv).
19. Sheng Shen, Zhewei Yao, Chunyuan Li, Trevor Darrell, Kurt Keutzer, Yuxiong He. (2023) Scaling Vision-Language Models with Sparse Mixture of Experts. [arXiv:2303.07226](https://arxiv.org/abs/2303.07226) and [Finding at EMNLP2023](https://2023.emnlp.org/).
20. Quentin Anthony, Ammar Ahmad Awan, Jeff Rasley, Yuxiong He, Aamir Shafi, Mustafa Abduljabbar, Hari Subramoni, Dhabaleswar Panda. (2023) MCR-DL: Mix-and-Match Communication Runtime for Deep Learning [arXiv:2303.08374](https://arxiv.org/abs/2303.08374) and will appear at IPDPS 2023.
21. Siddharth Singh, Olatunji Ruwase, Ammar Ahmad Awan, Samyam Rajbhandari, Yuxiong He, Abhinav Bhatele. (2023) A Hybrid Tensor-Expert-Data Parallelism Approach to Optimize Mixture-of-Experts Training [arXiv:2303.06318](https://arxiv.org/abs/2303.06318) and [ICS 2023](https://dl.acm.org/doi/10.1145/3577193.3593704).
22. Guanhua Wang, Heyang Qin, Sam Ade Jacobs, Xiaoxia Wu, Connor Holmes, Zhewei Yao, Samyam Rajbhandari, Olatunji Ruwase, Feng Yan, Lei Yang, Yuxiong He. (2023) ZeRO++: Extremely Efficient Collective Communication for Giant Model Training [arXiv:2306.10209](https://arxiv.org/abs/2306.10209) and [ML for Sys Workshop at NeurIPS2023](http://mlforsystems.org/) [[blog]](https://www.microsoft.com/en-us/research/blog/deepspeed-zero-a-leap-in-speed-for-llm-and-chat-model-training-with-4x-less-communication/)
23. Zhewei Yao, Xiaoxia Wu, Cheng Li, Stephen Youn, Yuxiong He. (2023) ZeroQuant-V2: Exploring Post-training Quantization in LLMs from Comprehensive Study to Low Rank Compensation [arXiv:2303.08302](https://arxiv.org/abs/2303.08302) and [ENLSP2023 Workshop at NeurIPS2023](https://neurips2023-enlsp.github.io/) [[slides]](docs/assets/files/zeroquant_series.pdf)
24. Pareesa Ameneh Golnari, Zhewei Yao, Yuxiong He. (2023) Selective Guidance: Are All the Denoising Steps of Guided Diffusion Important? [arXiv:2305.09847](https://arxiv.org/abs/2305.09847)
25. Zhewei Yao, Reza Yazdani Aminabadi, Olatunji Ruwase, Samyam Rajbhandari, Xiaoxia Wu, Ammar Ahmad Awan, Jeff Rasley, Minjia Zhang, Conglong Li, Connor Holmes, Zhongzhu Zhou, Michael Wyatt, Molly Smith, Lev Kurilenko, Heyang Qin, Masahiro Tanaka, Shuai Che, Shuaiwen Leon Song, Yuxiong He. (2023) DeepSpeed-Chat: Easy, Fast and Affordable RLHF Training of ChatGPT-like Models at All Scales [arXiv:2308.01320](https://arxiv.org/abs/2308.01320).
26. Xiaoxia Wu, Zhewei Yao, Yuxiong He. (2023) ZeroQuant-FP: A Leap Forward in LLMs Post-Training W4A8 Quantization Using Floating-Point Formats [arXiv:2307.09782](https://arxiv.org/abs/2307.09782) and [ENLSP2023 Workshop at NeurIPS2023](https://neurips2023-enlsp.github.io/) [[slides]](docs/assets/files/zeroquant_series.pdf)
27. Zhewei Yao, Xiaoxia Wu, Conglong Li, Minjia Zhang, Heyang Qin, Olatunji Ruwase, Ammar Ahmad Awan, Samyam Rajbhandari, Yuxiong He. (2023) DeepSpeed-VisualChat: Multi-Round Multi-Image Interleave Chat via Multi-Modal Causal Attention [arXiv:2309.14327](https://arxiv.org/pdf/2309.14327.pdf)
28. Shuaiwen Leon Song, Bonnie Kruft, Minjia Zhang, Conglong Li, Shiyang Chen, Chengming Zhang, Masahiro Tanaka, Xiaoxia Wu, Jeff Rasley, Ammar Ahmad Awan, Connor Holmes, Martin Cai, Adam Ghanem, Zhongzhu Zhou, Yuxiong He, et al. (2023) DeepSpeed4Science Initiative: Enabling Large-Scale Scientific Discovery through Sophisticated AI System Technologies [arXiv:2310.04610](https://arxiv.org/abs/2310.04610) [[blog]](https://www.microsoft.com/en-us/research/blog/announcing-the-deepspeed4science-initiative-enabling-large-scale-scientific-discovery-through-sophisticated-ai-system-technologies/)
29. Zhewei Yao, Reza Yazdani Aminabadi, Stephen Youn, Xiaoxia Wu, Elton Zheng, Yuxiong He. (2023) ZeroQuant-HERO: Hardware-Enhanced Robust Optimized Post-Training Quantization Framework for W8A8 Transformers [arXiv:2310.17723](https://arxiv.org/abs/2310.17723)

30. Xiaoxia Wu, Haojun Xia, Stephen Youn, Zhen Zheng, Shiyang Chen, Arash Bakhtiari, Michael Wyatt, Reza Yazdani Aminabadi, Yuxiong He, Olatunji Ruwase, Leon Song, Zhewei Yao (2023) ZeroQuant(4+2): Redefining LLMs Quantization with a New FP6-Centric Strategy for Diverse Generative Tasks [arXiv:2312.08583](https://arxiv.org/abs/2312.08583)

31. Haojun Xia, Zhen Zheng, Xiaoxia Wu, Shiyang Chen, Zhewei Yao, Stephen Youn, Arash Bakhtiari, Michael Wyatt, Donglin Zhuang, Zhongzhu Zhou, Olatunji Ruwase, Yuxiong He, Shuaiwen Leon Song. (2024) FP6-LLM: Efficiently Serving Large Language Models Through FP6-Centric Algorithm-System Co-Design  [arXiv:2401.14112](https://arxiv.org/abs/2401.14112)
32. Sam Ade Jacobs, Masahiro Tanaka, Chengming Zhang, Minjia Zhang, Reza Yazdani Aminadabi, Shuaiwen Leon Song, Samyam Rajbhandari, Yuxiong He. (2024) [System Optimizations for Enabling Training of Extreme Long Sequence Transformer Models](https://dl.acm.org/doi/10.1145/3662158.3662806)
33. Xinyu Lian, Sam Ade Jacobs, Lev Kurilenko, Masahiro Tanaka, Stas Bekman, Olatunji Ruwase, Minjia Zhang. (2024) Universal Checkpointing: Efficient and Flexible Checkpointing for Large Scale Distributed Training [arXiv:2406.18820](https://arxiv.org/abs/2406.18820)
34. Stas Bekman, Samyam Rajbhandari, Michael Wyatt, Jeff Rasley, Tunji Ruwase, Zhewei Yao, Aurick Qiao, Yuxiong He. (2025) Arctic Long Sequence Training: Scalable And Efficient Training For Multi-Million Token Sequences [arXiv:2506.13996](https://arxiv.org/abs/2506.13996)
35. Tingfeng Lan, Yusen Wu, Bin Ma, Zhaoyuan Su, Rui Yang, Tekin Bicer, Masahiro Tanaka, Olatunji Ruwase, Dong Li, Yue Cheng. (2025) ZenFlow: Enabling Stall-Free Offloading Training via Asynchronous Updates [arXiv:2505.12242](https://arxiv.org/abs/2505.12242)
36. Xinyu Lian, Masahiro Tanaka, Olatunji Ruwase, Minjia Zhang. (2026) SuperOffload: Unleashing the Power of Large-Scale LLM Training on Superchips [arxiv](https://arxiv.org/abs/2509.21271), [ASPLOS 2026](https://www.asplos-conference.org/asplos2026)

# Videos
1. DeepSpeed KDD 2020 Tutorial
    1. [Overview](https://www.youtube.com/watch?v=CaseqC45DNc&list=PLa85ZdUjfWS21mgibJ2vCvLziprjpKoW0&index=29)
    2. [ZeRO + large model training](https://www.youtube.com/watch?v=y4_bCiAsIAk&list=PLa85ZdUjfWS21mgibJ2vCvLziprjpKoW0&index=28)
    3. [17B T-NLG demo](https://www.youtube.com/watch?v=9V-ZbP92drg&list=PLa85ZdUjfWS21mgibJ2vCvLziprjpKoW0&index=27)
    4. [Fastest BERT training + RScan tuning](https://www.youtube.com/watch?v=o1K-ZG9F6u0&list=PLa85ZdUjfWS21mgibJ2vCvLziprjpKoW0&index=26)
    5. DeepSpeed hands on deep dive: [part 1](https://www.youtube.com/watch?v=_NOk-mBwDYg&list=PLa85ZdUjfWS21mgibJ2vCvLziprjpKoW0&index=92), [part 2](https://www.youtube.com/watch?v=sG6_c4VXLww&list=PLa85ZdUjfWS21mgibJ2vCvLziprjpKoW0&index=94), [part 3](https://www.youtube.com/watch?v=k9yPkBTayos&list=PLa85ZdUjfWS21mgibJ2vCvLziprjpKoW0&index=93)
    6. [FAQ](https://www.youtube.com/watch?v=nsHu6vEgPew&list=PLa85ZdUjfWS21mgibJ2vCvLziprjpKoW0&index=24)
2. Microsoft Research Webinar
    * Registration is free and all videos are available on-demand.
    * [ZeRO & Fastest BERT: Increasing the scale and speed of deep learning training in DeepSpeed](https://note.microsoft.com/MSR-Webinar-DeepSpeed-Registration-On-Demand.html).
3. [DeepSpeed on AzureML](https://youtu.be/yBVXR8G8Bg8)
4. [Large Model Training and Inference with DeepSpeed // Samyam Rajbhandari // LLMs in Prod Conference](https://www.youtube.com/watch?v=cntxC3g22oU) [[slides]](docs/assets/files/presentation-mlops.pdf)
5. Community Tutorials
    * [DeepSpeed: All the tricks to scale to gigantic models (Mark Saroufim)](https://www.youtube.com/watch?v=pDGI668pNg0)
    * [Turing-NLG, DeepSpeed and the ZeRO optimizer (Yannic Kilcher)](https://www.youtube.com/watch?v=tC01FRB0M7w)
    * [Ultimate Guide To Scaling ML Models (The AI Epiphany)](https://www.youtube.com/watch?v=hc0u4avAkuM)
