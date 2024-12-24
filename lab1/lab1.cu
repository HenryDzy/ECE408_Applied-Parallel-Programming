// LAB 1
#include <wb.h>

__global__ void vecAdd(float *in1, float *in2, float *out, int len) {
  //@@ Insert code to implement vector addition here
  int i = threadIdx.x + blockIdx.x * blockDim.x;
  if (i < len) {
    out[i] = in1[i] + in2[i];
  }
}

int main(int argc, char **argv) {
  wbArg_t args;
  int inputLength;
  float *hostInput1;
  float *hostInput2;
  float *hostOutput;

  args = wbArg_read(argc, argv);
  //@@ Importing data and creating memory on host
  hostInput1 =
      (float *)wbImport(wbArg_getInputFile(args, 0), &inputLength);
  hostInput2 =
      (float *)wbImport(wbArg_getInputFile(args, 1), &inputLength);
  hostOutput = (float *)malloc(inputLength * sizeof(float));

  wbLog(TRACE, "The input length is ", inputLength);

  float *deviceInput1, *deviceInput2, *deviceOutput;
  int inputSize = inputLength * sizeof(float);

  //@@ Allocate GPU memory here
  cudaMalloc( (void **) &deviceInput1, inputSize);
  cudaMalloc( (void **) &deviceInput2, inputSize);
  cudaMalloc( (void **) &deviceOutput, inputSize);

  //@@ Copy memory to the GPU here
  cudaMemcpy(deviceInput1, hostInput1, inputSize, cudaMemcpyHostToDevice);
  cudaMemcpy(deviceInput2, hostInput2, inputSize, cudaMemcpyHostToDevice);
  //@@ Initialize the grid and block dimensions here
  dim3 dimGrid(inputLength / 1024, 1, 1);
  if ( (inputLength % 1024) != 0) {
    dimGrid.x++;
  }
  dim3 dimBlock(1024, 1, 1);
  //@@ Launch the GPU Kernel here to perform CUDA computation
  vecAdd<<<dimGrid, dimBlock>>>(deviceInput1, deviceInput2, deviceOutput, inputLength);

  cudaDeviceSynchronize();
  //@@ Copy the GPU memory back to the CPU here
  cudaMemcpy(hostOutput, deviceOutput, inputSize, cudaMemcpyDeviceToHost);

  //@@ Free the GPU memory here
  cudaFree(deviceInput1);
  cudaFree(deviceInput2);
  cudaFree(deviceOutput);

  wbSolution(args, hostOutput, inputLength);

  free(hostInput1);
  free(hostInput2);
  free(hostOutput);

  return 0;
}