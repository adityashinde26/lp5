/*
!nvcc --version
!nvidia-smi
!pip install nvcc4jupyter
%load_ext nvcc4jupyter

*/

// %%writefile FLP5HPC4A.cu
#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <ctime>
#include <cmath>
#include <algorithm>
#include <cuda_runtime.h>

using namespace std;

void cpuSum(int* A, int* B, int* C, int N)
{
    for (int i = 0; i < N; i++)
    {
        C[i] = A[i] + B[i];
    }
}

__global__ void kernel(int* A, int* B, int* C, int N)
{
    int i = blockDim.x * blockIdx.x + threadIdx.x;

    if (i < N)
    {
        C[i] = A[i] + B[i];
    }
}

void gpuSum(int* A, int* B, int* C, int N)
{
    int threadsPerBlock = min(1024, N);
    int blocksPerGrid = (N + threadsPerBlock - 1) / threadsPerBlock;

    kernel<<<blocksPerGrid, threadsPerBlock>>>(A, B, C, N);
}

bool isVectorEqual(int* A, int* B, int N)
{
    for (int i = 0; i < N; i++)
    {
        if (A[i] != B[i])
        {
            return false;
        }
    }

    return true;
}

int main()
{
    int N = 20000000;
    int size = N * sizeof(int);

    int *A, *B, *C, *D;
    int *a, *b, *c;

    A = (int*)malloc(size);
    B = (int*)malloc(size);
    C = (int*)malloc(size);
    D = (int*)malloc(size);

    if (A == NULL || B == NULL || C == NULL || D == NULL)
    {
        cout << "Host memory allocation failed\n";
        return 1;
    }

    srand(time(NULL));

    for (int i = 0; i < N; i++)
    {
        A[i] = rand() % 1000;
        B[i] = rand() % 1000;
    }

    clock_t start, end;

    start = clock();
    cpuSum(A, B, C, N);
    end = clock();

    float timeTakenCPU = ((float)(end - start)) / CLOCKS_PER_SEC;

    cudaMalloc((void**)&a, size);
    cudaMalloc((void**)&b, size);
    cudaMalloc((void**)&c, size);

    cudaMemcpy(a, A, size, cudaMemcpyHostToDevice);
    cudaMemcpy(b, B, size, cudaMemcpyHostToDevice);

    start = clock();

    gpuSum(a, b, c, N);

    cudaDeviceSynchronize();

    cudaMemcpy(D, c, size, cudaMemcpyDeviceToHost);

    end = clock();

    float timeTakenGPU = ((float)(end - start)) / CLOCKS_PER_SEC;

    bool success = isVectorEqual(C, D, N);

    printf("Vector Addition\n");
    printf("--------------------\n");
    printf("CPU Time: %f seconds\n", timeTakenCPU);
    printf("GPU Time: %f seconds\n", timeTakenGPU);
    printf("Speed Up: %f\n", timeTakenCPU / timeTakenGPU);
    printf("Verification: %s\n", success ? "true" : "false");

    cudaFree(a);
    cudaFree(b);
    cudaFree(c);

    free(A);
    free(B);
    free(C);
    free(D);

    return 0;
}

// !nvcc FLP5HPC4A.cu -o FLP5HPC4A
// !./FLP5HPC4A