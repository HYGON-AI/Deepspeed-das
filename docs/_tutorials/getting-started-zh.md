---
title: 'DeepSpeed 入门'
permalink: /getting-started/zh/
excerpt: '开始使用 DeepSpeed'
tags: getting-started
---

<!--
# SPDX-License-Identifier: Apache-2.0
# DeepSpeed Team
-->

本文翻译自 [Getting Started](getting-started.md)。代码示例保留原文内容，代码注释译为中文。
文中的安装方式、后端说明和镜像来自上游教程；本仓库是海光适配版，实际安装请结合
[仓库说明](../../README.md) 和 [构建说明](../build.md)。

## 安装

* 使用 `pip install deepspeed` 即可安装，详见[高级安装指南](https://www.deepspeed.ai/tutorials/advanced-install/)。
* 要在 AzureML 上开始使用 DeepSpeed，请参阅 [AzureML 示例仓库](https://github.com/Azure/azureml-examples/tree/main/cli/jobs/deepspeed)。
* DeepSpeed 已直接集成到 [HuggingFace Transformers](https://github.com/huggingface/transformers) 和 [PyTorch Lightning](https://github.com/PyTorchLightning/pytorch-lightning)。HuggingFace Transformers 用户只需使用 `--deepspeed` 参数并提供配置文件，即可通过 DeepSpeed 加速模型，详见[集成文档](https://huggingface.co/docs/transformers/deepspeed)。PyTorch Lightning 用户可以通过 Lightning Trainer 使用 DeepSpeed，详见[相关文档](https://pytorch-lightning.readthedocs.io/en/stable/advanced/multi_gpu.html?highlight=deepspeed#deepspeed)。
* 在 AMD 平台上，可以使用我们的 [ROCm 镜像](https://hub.docker.com/r/deepspeed/rocm501/tags)，例如运行 `docker pull deepspeed/rocm501:ds060_pytorch110`。
* DeepSpeed 还支持 Intel Xeon CPU、Intel Data Center Max Series XPU、Intel Gaudi HPU、华为昇腾 NPU 等设备，请参阅[加速器配置指南](https://www.deepspeed.ai/tutorials/accelerator-setup-guide/)。

## 编写使用 DeepSpeed 的模型

DeepSpeed 通过 DeepSpeed 引擎完成模型训练。引擎可以封装任意 `torch.nn.Module` 类型的模型，
并提供一组精简的 API，用于训练模型以及保存、加载检查点（checkpoint，即训练状态快照）。
详细示例请参阅相关教程。

初始化 DeepSpeed 引擎：

```python
model_engine, optimizer, _, _ = deepspeed.initialize(args=cmd_args,
                                                     model=model,
                                                     model_parameters=params)
```

`deepspeed.initialize` 会在内部完成分布式数据并行训练或混合精度训练所需的设置。
除了封装模型，DeepSpeed 还可以根据传给 `deepspeed.initialize` 的参数和
DeepSpeed [配置文件](#deepspeed-配置)，创建并管理训练所用的优化器、数据加载器和学习率调度器。
请注意，DeepSpeed 会在每个训练更新步骤中自动执行学习率调度。

如果你已经在代码中设置了分布式环境，需要将：

```python
torch.distributed.init_process_group(...)
```

替换为：

```python
deepspeed.init_distributed()
```

原文所述默认后端为 NCCL，DeepSpeed 已对这一后端进行了充分测试。
你也可以[覆盖默认设置](https://deepspeed.readthedocs.io/en/latest/initialize.html#distributed-initialization)。

如果在调用 `deepspeed.initialize()` 之前不需要使用分布式环境，就无需单独调用
`deepspeed.init_distributed()`，因为 DeepSpeed 会在 `initialize` 中自动初始化分布式环境。
无论采用哪种方式，如果代码中已有 `torch.distributed.init_process_group`，都需要移除该调用。

### 训练

初始化引擎后，只需使用三个简单接口就能训练模型：前向传播（直接调用引擎对象）、
反向传播（`backward`）以及权重更新（`step`）。

```python
for step, batch in enumerate(data_loader):
    # 前向计算
    loss = model_engine(batch)

    # 执行反向传播
    model_engine.backward(loss)

    # 更新权重
    model_engine.step()
```

在内部，DeepSpeed 会自动完成分布式数据并行、混合精度训练以及预设学习率调度所需的操作：

- **梯度平均**：在分布式数据并行训练中，`backward` 确保处理完一个 `train_batch_size` 对应的数据后，各数据并行进程之间的梯度完成平均。
- **损失缩放（Loss Scaling）**：在 FP16／混合精度训练中，DeepSpeed 引擎会自动处理损失缩放，避免梯度精度损失。
- **学习率调度器**：使用 DeepSpeed 的学习率调度器（在 `ds_config.json` 中指定）时，DeepSpeed 会在每个训练更新步骤中调用调度器的 `step()` 方法，也就是在执行 `model_engine.step()` 时调用。如果使用其他学习率调度器：
  - 如果需要在每个训练更新步骤中执行调度，可以在初始化引擎时，将调度器传给 `deepspeed.initialize`，让 DeepSpeed 管理它的更新以及状态保存、恢复。
  - 如果需要按其他间隔执行调度，例如每个训练轮次（epoch）执行一次，则不应在初始化时将调度器传给 DeepSpeed，而应自行管理。

### 模型检查点

DeepSpeed 使用 `save_checkpoint` 和 `load_checkpoint` API 保存、加载训练状态。
下面两个参数共同确定一个检查点：

- `ckpt_dir`：保存检查点的目录。
- `ckpt_id`：检查点在该目录中的唯一标识。下面的代码使用损失值作为检查点标识。

```python
# 加载检查点
_, client_sd = model_engine.load_checkpoint(args.load_dir, args.ckpt_id)
step = client_sd['step']

# 将数据加载器推进到检查点对应步骤之后
dataloader_to_step(data_loader, step + 1)

for step, batch in enumerate(data_loader):

    # 前向计算
    loss = model_engine(batch)

    # 执行反向传播
    model_engine.backward(loss)

    # 更新权重
    model_engine.step()

    # 保存检查点
    if step % args.save_interval:
        client_sd['step'] = step
        ckpt_id = loss.item()
        model_engine.save_checkpoint(args.save_dir, ckpt_id, client_sd = client_sd)
```

> 译注：上面保留了原文代码。`if step % args.save_interval:` 在余数不为零时成立；
> 如果你的意图是“每隔 `save_interval` 步保存一次”，通常应写成
> `if (step + 1) % args.save_interval == 0:`。
> `dataloader_to_step` 也是示意性的辅助函数，需要由使用者实现；该片段并非独立可运行脚本。

DeepSpeed 可以自动保存和恢复模型、优化器以及学习率调度器的状态，使用者不必处理其中的细节。
不过，你可能还需要保存某次模型训练特有的额外数据。为此，`save_checkpoint` 接受一个
客户端状态字典 `client_sd`，其中的数据会一起保存，并可以从 `load_checkpoint` 的返回值中取回。
上例将训练步数 `step` 保存在 `client_sd` 中。

**重要**：所有进程都必须调用保存检查点的方法，不能只让 rank 为 0 的进程调用。
这是因为每个进程都需要保存自己的主权重，以及调度器和优化器状态。
如果只有 rank 为 0 的进程调用，该方法会一直等待其他进程同步，导致程序挂起。

## DeepSpeed 配置

DeepSpeed 的功能可以通过 JSON 配置文件启用、禁用或调整。
配置文件路径应通过 `args.deepspeed_config` 指定。下面是一个配置示例，
完整功能请参阅[配置 API 文档](https://www.deepspeed.ai/docs/config-json/)。

```json
{
  "train_batch_size": 8,
  "gradient_accumulation_steps": 1,
  "optimizer": {
    "type": "Adam",
    "params": {
      "lr": 0.00015
    }
  },
  "fp16": {
    "enabled": true
  },
  "zero_optimization": true
}
```

> 译注：以上保留了原文中的旧式 `"zero_optimization": true` 写法。
> 新配置建议显式指定阶段，例如 `"zero_optimization": {"stage": 1}`，便于理解和调整。

## 启动 DeepSpeed 训练

安装 DeepSpeed 后，可以使用 `deepspeed` 命令启动分布式训练。
下面的示例假设：

1. 你已经在模型训练代码中集成了 DeepSpeed。
2. `client_entry.py` 是模型的训练入口脚本。
3. `client args` 表示由 `argparse` 处理的脚本命令行参数。
4. `ds_config.json` 是 DeepSpeed 配置文件。

### 资源配置：多节点

DeepSpeed 使用主机文件（hostfile）配置多节点计算资源，文件格式兼容
[OpenMPI](https://www.open-mpi.org/) 和 [Horovod](https://github.com/horovod/horovod)。
主机文件列出可以通过免密 SSH 访问的主机名（或 SSH 别名），以及每台机器上的可用 GPU 数量
（称为 slot 数量）。例如：

```text
worker-1 slots=4
worker-2 slots=4
```

这表示名为 `worker-1` 和 `worker-2` 的两台机器各有 4 张 GPU 可用于训练。

可以通过 `--hostfile` 命令行参数指定主机文件。如果没有指定，DeepSpeed 会查找 `/job/hostfile`。
如果既没有指定也没有找到主机文件，DeepSpeed 会查询本机的 GPU 数量，以确定本地可用的 slot 数量。

下面的命令会使用 `myhostfile` 中指定的所有可用节点和 GPU，启动 PyTorch 训练任务：

```bash
deepspeed --hostfile=myhostfile <client_entry.py> <client args> \
  --deepspeed --deepspeed_config ds_config.json
```

也可以通过 `--num_nodes` 和 `--num_gpus` 参数，将分布式训练限制在部分可用节点和 GPU 上。
例如，下面的命令只使用两个节点：

```bash
deepspeed --num_nodes=2 \
	<client_entry.py> <client args> \
	--deepspeed --deepspeed_config ds_config.json
```

还可以使用 `--include` 和 `--exclude` 参数指定包含或排除哪些资源。
例如，下面的命令使用所有可用资源，但排除 `worker-2` 上的 GPU 0，以及 `worker-3` 上的 GPU 0 和 1：

```bash
deepspeed --exclude="worker-2:0@worker-3:0,1" \
	<client_entry.py> <client args> \
	--deepspeed --deepspeed_config ds_config.json
```

类似地，下面的命令只使用 `worker-2` 上的 GPU 0 和 1：

```bash
deepspeed --include="worker-2:0,1" \
	<client_entry.py> <client args> \
	--deepspeed --deepspeed_config ds_config.json
```

### 不使用免密 SSH 启动

DeepSpeed 支持在不配置免密 SSH 的情况下启动训练任务。
这一模式尤其适合 Kubernetes 等云环境：这些环境可以灵活编排容器，
额外搭建依赖免密 SSH 的主节点与工作节点架构会增加复杂度。

使用此模式时，需要在所有节点上分别执行 DeepSpeed 命令，格式如下：

```bash
deepspeed --hostfile=myhostfile --no_ssh --node_rank=<n> \
    --master_addr=<addr> --master_port=<port> \
    <client_entry.py> <client args> \
    --deepspeed --deepspeed_config ds_config.json
```

- `--hostfile=myhostfile`：指定包含节点和 GPU 信息的主机文件。
- `--no_ssh`：启用不使用 SSH 的模式。
- `--node_rank=<n>`：指定当前节点编号。如果共有 N 个节点，编号应为 0 到 N − 1 之间的唯一整数。
- `--master_addr=<addr>`：主节点（节点编号为 0）的地址。
- `--master_port=<port>`：主节点使用的端口。

在这种配置下，主机文件中的主机不必能通过免密 SSH 访问。
不过，仍然需要主机文件，以便启动器获取环境信息，例如节点数量和每个节点的 GPU 数量。

每个节点都必须使用唯一的 `node_rank`，并且所有节点都必须指定主节点的地址和端口。
此模式下的启动器行为类似于 `torchrun`，详见 [PyTorch 文档](https://pytorch.org/docs/stable/elastic/run.html)。

### 多节点环境变量

跨多个节点训练时，通常需要将用户自定义的环境变量传递给各个节点。
默认情况下，DeepSpeed 会传递已设置的所有 NCCL 和 PYTHON 相关环境变量。
如果还需要传递其他变量，可以创建一个名为 `.deepspeed_env` 的隐藏文件，
每行写一个 `VAR=VAL` 条目。

DeepSpeed 启动器会在命令执行时的当前目录和用户主目录（`~/`）中查找该文件。
如果希望自定义文件名或完整路径，可以通过环境变量 `DS_ENV_FILE` 指定。
当你要启动多个任务，并且每个任务需要不同的环境变量时，这尤其有用。

例如，有些集群要求在训练前设置特定的 NCCL 变量。
你可以在用户主目录中创建 `.deepspeed_env` 文件，内容如下：

```text
NCCL_IB_DISABLE=1
NCCL_SOCKET_IFNAME=eth0
```

DeepSpeed 会确保在训练任务的每个节点上启动各个进程时，都设置这些环境变量。

### MPI 和 AzureML 兼容性

如前所述，DeepSpeed 提供了自己的并行启动器，用于启动多节点、多 GPU 训练任务。
如果你更希望使用 MPI（例如 `mpirun`）启动训练，DeepSpeed 也支持这种方式。
需要注意的是，原文所述的这种方式仍然使用 PyTorch 分布式的 NCCL 后端，而不是 MPI 后端。

要通过 `mpirun` 配合 DeepSpeed 启动训练，或通过 AzureML（使用 `mpirun` 作为启动器后端）启动，
只需安装 Python 包 [mpi4py](https://pypi.org/project/mpi4py/)。
DeepSpeed 会利用它发现 MPI 环境，并将必要的状态信息，例如进程总数（world size）和进程编号（rank），
传给 PyTorch 分布式后端。

如果使用模型并行、流水线并行，或因其他原因需要在 `deepspeed.initialize(..)` 之前调用
分布式接口，可以额外调用 DeepSpeed 提供的初始化 API，从而获得同样的 MPI 支持。
将原来的 `torch.distributed.init_process_group(..)` 调用替换为：

```python
deepspeed.init_distributed()
```

### 资源配置：单节点

如果只在一台机器上运行（使用一张或多张 GPU），DeepSpeed 不需要上述主机文件。
如果没有检测到主机文件，也没有显式传入主机文件，DeepSpeed 会查询本机 GPU 数量，
以确定可用的 slot 数量。`--include` 和 `--exclude` 参数仍然可用，但主机名应填写 `localhost`。

也可以使用 `CUDA_VISIBLE_DEVICES` 配合 `deepspeed`，控制单节点使用哪些设备。
例如，下面两种方式都可以只使用当前节点上的设备 0 和 1：

```bash
deepspeed --include localhost:0,1 ...
```

```bash
CUDA_VISIBLE_DEVICES=0,1 deepspeed ...
```
