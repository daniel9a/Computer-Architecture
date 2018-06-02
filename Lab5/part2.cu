#include <chrono>
#include <iostream>
#include <math.h>

typedef std::chrono::high_resolution_clock Clock;
#define NUM_THREADS_IN_BLOCK 256


__global__
//runtime GPU 195.58us
//runtime CPU 3015 microseconds 
void daxpyGPU(int arraySize, float *a, float *b, float *c, float *result)
{
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;
    for (int i = index; i < arraySize; i+=stride) {
        result[i] = a[i] * b[i] + c[i];
    }
  // Insert your code here.
} // daxpyGPU()

//runtime 3015 microseconds 
void daxpyCPU(int arraySize, float *a, float *x, float *y, float *result)
{
  for(int index = 0; index < arraySize; index++)
  {
    result[index] = a[index] * x[index] + y[index];
  }
} // daxpyCPU()

int main(void)
{
  int arraySize = 1 << 20;
  float *a, *x, *y;
  float *cpuResult, *gpuResult;

  cpuResult = new float[arraySize];

  // Allocate unified memory, accessible from CPU or GPU.
  cudaMallocManaged(&a, arraySize * sizeof(float));
  cudaMallocManaged(&x, arraySize * sizeof(float));
  cudaMallocManaged(&y, arraySize * sizeof(float));
  cudaMallocManaged(&gpuResult, arraySize * sizeof(float));

  // Initialize arrays on the host.
  for(int index = 0; index < arraySize; index++)
  {
    a[index] = 5.0f;
    x[index] = 10.0f;
    y[index] = 20.0f;
  }

  int blockSize = NUM_THREADS_IN_BLOCK;
  int numBlocks = (arraySize + blockSize - 1) / blockSize;

  auto start = Clock::now();
  daxpyCPU(arraySize, a, x, y, cpuResult);
  auto end = Clock::now();

  daxpyGPU<<<numBlocks, blockSize>>>(arraySize, a, x, y, gpuResult);

  // Wait for GPU to finish before accessing values on the host.
  cudaDeviceSynchronize();

  // Check for errors. All values should be 70.0f.
  float maxError = 0.0f;

  for (int index = 0; index < arraySize; index++)
  {
    maxError = fmax(maxError, fabs(cpuResult[index] - gpuResult[index]));
  }

  std::cout << "Max error: " << maxError << std::endl
            << "CPU time: "
            << std::chrono::duration_cast<std::chrono::microseconds>(end - start).count()
            << " microseconds." << std::endl;

  // Free memory.
  cudaFree(a);
  cudaFree(x);
  cudaFree(y);
  cudaFree(gpuResult);
  delete(cpuResult);

  return 0;
} // main()
