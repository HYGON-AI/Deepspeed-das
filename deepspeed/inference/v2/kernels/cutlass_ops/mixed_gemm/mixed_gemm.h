// Copyright (c) Microsoft Corporation.
// SPDX-License-Identifier: Apache-2.0

// DeepSpeed Team

// Copyright (c) 2026 Hygon Information Technology Co., Ltd.
// Modified by Hygon Information Technology Co., Ltd., 2026.

#pragma once
#ifdef BF16_AVAILABLE
#include <cuda_bf16.h>
#endif

#include <torch/extension.h>

void mixed_gemm(at::Tensor& output,
                at::Tensor& hidden_states,
                at::Tensor& weight,
                at::Tensor& scales,
                c10::optional<at::Tensor>& bias,
                int num_bits,
                int activation_raw);
