// Copyright (c) Microsoft Corporation.
// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Hygon Information Technology Co., Ltd.
// DeepSpeed Team

#ifndef __FEEDFORWARD_H__
#define __FEEDFORWARD_H__

#include <cuda.h>
#include <cuda_fp16.h>
#include <stdio.h>
#include "custom_cuda_layers.h"

template <typename T>
class FeedForward {
public:
    struct Config {
        int batchSize, outputSize;
        int inputSize;
        std::array<int, 3> gemm_algos;
        Config(int batch, int outputs, int inputs, const std::array<int, 3>& algos)
            : batchSize(batch), outputSize(outputs), inputSize(inputs), gemm_algos(algos)
        {
        }
    };

    FeedForward(Config config) : config_(config) {}

    ~FeedForward() {}

    void Forward(int bsz,
                 const T* input_ptr,
                 const T* weights,
                 T* out,
#ifdef __HIP_PLATFORM_AMD__
                 rocblas_handle& _cublasHandle)
#else
                 cublasHandle_t& _cublasHandle)
#endif
    {
        float alpha = T(1.);
        float beta = T(0.);

        cublas_gemm_ex(_cublasHandle,
#ifdef __HIP_PLATFORM_AMD__
                       rocblas_operation_transpose,
                       rocblas_operation_none,
#else
                       CUBLAS_OP_T,
                       CUBLAS_OP_N,
#endif
                       config_.outputSize,
                       bsz,
                       config_.inputSize,
                       &alpha,
                       &beta,
                       weights,
                       input_ptr,
                       out,
// TODO HIP: Remove backward compatibility for torch<=2.0 in future
#if defined(__HIP_PLATFORM_AMD__)
    
                       rocblas_gemm_algo(config_.gemm_algos[0]));
#else
                       cublasGemmAlgo_t(config_.gemm_algos[0]));
#endif
    }
    void Backward(int bsz,
                  const T* out_grad,
                  const T* input_ptr,
                  const T* weights,
                  T* weights_grad,
                  T* bias_grad,
#ifdef __HIP_PLATFORM_AMD__
                  rocblas_handle& _cublasHandle,
#else
                  cublasHandle_t& _cublasHandle,
#endif
                  cudaStream_t& stream,
                  T* inp_grad_out = nullptr,
                  T* out_grad_trans_out = nullptr)
    {
        float alpha = (T)1.0, beta = (T)0.0;
        cublas_gemm_ex(_cublasHandle,
#ifdef __HIP_PLATFORM_AMD__
                       rocblas_operation_none,
                       rocblas_operation_transpose,
#else
                       CUBLAS_OP_N,
                       CUBLAS_OP_T,
#endif
                       config_.inputSize,
                       config_.outputSize,
                       bsz,
                       &alpha,
                       &beta,
                       input_ptr,
                       out_grad,
                       weights_grad,
#if defined(__HIP_PLATFORM_AMD__)
    
                       rocblas_gemm_algo(config_.gemm_algos[1]));
#else
                       cublasGemmAlgo_t(config_.gemm_algos[1]));
#endif

        cublas_gemm_ex(_cublasHandle,
#ifdef __HIP_PLATFORM_AMD__
                       rocblas_operation_none,
                       rocblas_operation_none,
#else
                       CUBLAS_OP_N,
                       CUBLAS_OP_N,
#endif
                       config_.inputSize,
                       bsz,
                       config_.outputSize,
                       &alpha,
                       &beta,
                       weights,
                       out_grad,
                       inp_grad_out,
#if defined(__HIP_PLATFORM_AMD__)
    
                       rocblas_gemm_algo(config_.gemm_algos[2]));
#else
                       cublasGemmAlgo_t(config_.gemm_algos[2]));
#endif

        launch_fuse_transpose_bias_kernel<T>(out_grad, bias_grad, bsz, config_.outputSize, stream);
    }

private:
    Config config_;
};

#endif
