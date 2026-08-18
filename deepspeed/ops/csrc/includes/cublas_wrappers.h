// Copyright (c) Microsoft Corporation.
// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Hygon Information Technology Co., Ltd.
// DeepSpeed Team

#pragma once

#include <assert.h>
#include <cublas_v2.h>
#include <cuda.h>
#include <cuda_fp16.h>
#include <cuda_runtime.h>
#ifndef __HIP_PLATFORM_AMD__
#include <mma.h>
#endif
#ifdef __HIP_PLATFORM_AMD__
#include <rocblas/rocblas.h>
#endif
#include <stdio.h>
#include <torch/version.h>

int cublas_gemm_ex(
#ifdef __HIP_PLATFORM_AMD__
                   rocblas_handle handle,
                   rocblas_operation transa,
                   rocblas_operation transb,
#else                  
                   cublasHandle_t handle,
                   cublasOperation_t transa,
                   cublasOperation_t transb,
#endif
                   int m,
                   int n,
                   int k,
                   const float* alpha,
                   const float* beta,
                   const float* A,
                   const float* B,
                   float* C,
// TODO HIP: Remove backward compatibility for torch<=2.0 in future
#if defined(__HIP_PLATFORM_AMD__)
    
                   rocblas_gemm_algo algo = rocblas_gemm_algo_standard);
#else
                   cublasGemmAlgo_t algo = CUBLAS_GEMM_DEFAULT);
#endif

int cublas_gemm_ex(
#ifdef __HIP_PLATFORM_AMD__
                   rocblas_handle handle,
                   rocblas_operation transa,
                   rocblas_operation transb,
#else                  
                   cublasHandle_t handle,
                   cublasOperation_t transa,
                   cublasOperation_t transb,
#endif
                   int m,
                   int n,
                   int k,
                   const float* alpha,
                   const float* beta,
                   const __half* A,
                   const __half* B,
                   __half* C,
#if defined(__HIP_PLATFORM_AMD__)
                   rocblas_gemm_algo algo = rocblas_gemm_algo_standard);
#else
                   cublasGemmAlgo_t algo = CUBLAS_GEMM_DEFAULT_TENSOR_OP);
#endif

int cublas_strided_batched_gemm(
#ifdef __HIP_PLATFORM_AMD__
                                rocblas_handle handle,
#else                            
                                cublasHandle_t handle,
#endif
                                int m,
                                int n,
                                int k,
                                const float* alpha,
                                const float* beta,
                                const float* A,
                                const float* B,
                                float* C,
#ifdef __HIP_PLATFORM_AMD__                                 
                                rocblas_operation op_A,
                                rocblas_operation op_B,
#else                                
                                cublasOperation_t op_A,
                                cublasOperation_t op_B,
#endif     
                                int stride_A,
                                int stride_B,
                                int stride_C,
                                int batch,
#if defined(__HIP_PLATFORM_AMD__)
    
                                rocblas_gemm_algo algo = rocblas_gemm_algo_standard);
#else
                                cublasGemmAlgo_t algo = CUBLAS_GEMM_DEFAULT);
#endif

int cublas_strided_batched_gemm(
#ifdef __HIP_PLATFORM_AMD__
                                rocblas_handle handle,
#else                   
                                cublasHandle_t handle,
#endif                                
                                int m,
                                int n,
                                int k,
                                const float* alpha,
                                const float* beta,
                                const __half* A,
                                const __half* B,
                                __half* C,
#ifdef __HIP_PLATFORM_AMD__                                 
                                rocblas_operation op_A,
                                rocblas_operation op_B,
#else                                
                                cublasOperation_t op_A,
                                cublasOperation_t op_B,
#endif  
                                int stride_A,
                                int stride_B,
                                int stride_C,
                                int batch,
#ifdef __HIP_PLATFORM_AMD__
                                rocblas_gemm_algo algo = rocblas_gemm_algo_standard);
#else
                                cublasGemmAlgo_t algo = CUBLAS_GEMM_DEFAULT_TENSOR_OP);
#endif
