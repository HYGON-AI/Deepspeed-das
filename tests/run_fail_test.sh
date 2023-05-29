#!/bin/bash
pytest unit/checkpoint/test_lr_scheduler.py::TestLRSchedulerCheckpoint::test_checkpoint_no_lr_scheduler[2-True]
pytest unit/checkpoint/test_lr_scheduler.py::TestLRSchedulerCheckpoint::test_checkpoint_lr_scheduler[3-True]
pytest unit/checkpoint/test_lr_scheduler.py::TestLRSchedulerCheckpoint::test_checkpoint_no_lr_scheduler[3-True]
pytest unit/checkpoint/test_lr_scheduler.py::TestLRSchedulerCheckpoint::test_checkpoint_lr_scheduler[2-True]
pytest unit/ops/adam/test_adamw.py
pytest unit/ops/adam/test_cpu_adam.py
pytest unit/ops/aio/test_aio.py
pytest unit/ops/adagrad/test_cpu_adagrad.py
pytest unit/runtime/half_precision/test_fp16.py
pytest unit/runtime/zero/test_ignore_unused_parameters.py
pytest unit/runtime/zero/test_zero.py
pytest unit/runtime/zero/test_zero_tensor_fragment.py
