/*
!pip install nvcc4jupyter
%load_ext nvcc4jupyter
*/

// %%writefile FLP5HPC4B.cu

#include <stdio.h>
#include <stdlib.h>
#include<math.h>
#include<time.h>
#include<iostream>
#include <algorithm>
using namespace std;
#include "cuda_runtime.h"

void cpuMatrixMultiply(int* A, int* B, int* C, int N)
{
    for (int i = 0; i < N; ++i)
        for (int j = 0; j < N; ++j)
        {
            C[i * N + j] = 0;
            for (int k = 0; k < N; ++k)
                C[i * N + j] += A[i * N + k] * B[k * N + j];
        }
}

__global__ void gpuMatrixMultiply(int* A, int* B, int* C, int N)
{
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;

    if (row < N && col < N)
    {
        int value = 0;
        for (int k = 0; k < N; ++k)
            value += A[row * N + k] * B[k * N + col];

        C[row * N + col] = value;
    }
}

void gpuMatrixMultiplyLauncher(int* A, int* B, int* C, int N)
{
    int threadsPerBlock = 16;

    dim3 threads(threadsPerBlock, threadsPerBlock);
    dim3 blocks((N + threadsPerBlock - 1) / threadsPerBlock,
                (N + threadsPerBlock - 1) / threadsPerBlock);

    gpuMatrixMultiply<<<blocks, threads>>>(A, B, C, N);
    cudaDeviceSynchronize();
}

bool isMatrixEqual(int* A, int* B, int N)
{
    for (int i = 0; i < N * N; ++i)
        if (A[i] != B[i]) return false;

    return true;
}

int main()
{
    int N = 512;
    int size = N * N * sizeof(int);

    int *A = (int*)malloc(size);
    int *B = (int*)malloc(size);
    int *C = (int*)malloc(size);
    int *D = (int*)malloc(size);

    for (int i = 0; i < N * N; ++i)
    {
        A[i] = rand() % 100;
        B[i] = rand() % 100;
    }

    clock_t start, end;

    start = clock();
    cpuMatrixMultiply(A, B, C, N);
    end = clock();
    float cpuTime = (float)(end - start) / CLOCKS_PER_SEC;

    int *a, *b, *c;
    cudaMalloc(&a, size);
    cudaMalloc(&b, size);
    cudaMalloc(&c, size);

    cudaMemcpy(a, A, size, cudaMemcpyHostToDevice);
    cudaMemcpy(b, B, size, cudaMemcpyHostToDevice);

    start = clock();
    gpuMatrixMultiplyLauncher(a, b, c, N);
    cudaMemcpy(D, c, size, cudaMemcpyDeviceToHost);
    end = clock();
    float gpuTime = (float)(end - start) / CLOCKS_PER_SEC;

    cudaFree(a);

    cudaFree(b);
    cudaFree(c);

    bool ok = isMatrixEqual(C, D, N);

    printf("Matrix Multiplication\n");
    printf("--------------------\n");
    printf("CPU Time: %f\n", cpuTime);
    printf("GPU Time: %f\n", gpuTime);
    printf("Speedup: %f\n", cpuTime / gpuTime);
    printf("Verification: %s\n", ok ? "Correct" : "Wrong");

    free(A); free(B); free(C); free(D);

    return 0;
}
// !nvcc FLP5HPC4B.cu -o FLP5HPC4B
// !./FLP5HPC4B
