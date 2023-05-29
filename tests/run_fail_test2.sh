#!/bin/bash
pytest unit/inference/test_checkpoint_sharding.py
pytest unit/inference/test_inference.py
pytest unit/inference/test_model_profiling.py
pytest unit/runtime/comm/test_coalesced_collectives.py
