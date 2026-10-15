# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: Apache-2.0

# DeepSpeed Team

# Copyright (c) 2026 Hygon Information Technology Co., Ltd.
# Modified by Hygon Information Technology Co., Ltd., 2026.

import torch

from transformers import AutoModelForCausalLM
import deepspeed
import argparse
from deepspeed.accelerator import get_accelerator

deepspeed.runtime.utils.see_memory_usage('pre test', force=True)

model = AutoModelForCausalLM.from_pretrained('facebook/opt-350M').half().to(get_accelerator().device_name())
# Hybrid Engine exercises training/inference mode switching.  KV-cache output
# is not needed here and the legacy DeepSpeed OPT path expects cache objects
# that are incompatible with newer Transformers tuple-based cache handling.
model.config.use_cache = False
parser = argparse.ArgumentParser()
parser = deepspeed.add_config_arguments(parser)
args = parser.parse_args()

deepspeed.runtime.utils.see_memory_usage('post test', force=True)

# Hybrid Engine is enabled through the DeepSpeed configuration, not an
# ``initialize`` keyword argument.  A command-line --deepspeed_config takes
# precedence when one is supplied.
config = None
if getattr(args, "deepspeed_config", None) is None:
    config = {
        "train_batch_size": 1,
        "fp16": {
            "enabled": True
        },
        "hybrid_engine": {
            "enabled": True
        },
    }

m, _, _, _ = deepspeed.initialize(model=model, args=args, config=config)

m.eval()
input = torch.ones(1, 16, device='cuda', dtype=torch.long)
out = m(input)
eval_norm = out['logits'].norm().item()

m.train()
out = m(input)
train_norm = out['logits'].norm().item()
print(f'eval logits norm: {eval_norm}', flush=True)
print(f'train logits norm: {train_norm}', flush=True)
print('HYBRID_ENGINE_TEST_PASS', flush=True)
