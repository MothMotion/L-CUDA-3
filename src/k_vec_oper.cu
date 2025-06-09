#ifndef SERIAL



#include "config.h"
#include "timer.h"
#include "vec_oper.h"
#include "k_vec_oper.h"

#include <stdint.h>
#include <stddef.h>

#include <cuda.h>
#include <cuda_runtime.h>



time_s Operation(arr_t* arr1, arr_t* arr2, arr_t* out, const uint32_t& size, const Oper& op) {
  time_s time;
  cudaEvent_t start, end;
  cudaEventCreate(&start);
  cudaEventCreate(&end);

  arr_t *d_arr1, *d_arr2, *d_out;
  uint32_t *d_size;
  cudaMalloc((void**)&d_arr1, size*sizeof(arr_t));
  cudaMalloc((void**)&d_arr2, size*sizeof(arr_t));
  cudaMalloc((void**)&d_out, size*sizeof(arr_t));
  cudaMalloc((void**)&d_size, sizeof(uint32_t));

  cudaStream_t stream;
  cudaStreamCreate(&stream);


  CUDATIME(({
    cudaHostRegister(arr1, size*sizeof(arr_t), cudaHostRegisterDefault);
    cudaHostRegister(arr2, size*sizeof(arr_t), cudaHostRegisterDefault);

    cudaMemcpyAsync(d_arr1, arr1, size*sizeof(arr_t), cudaMemcpyHostToDevice, stream);
    cudaMemcpyAsync(d_arr2, arr2, size*sizeof(arr_t), cudaMemcpyHostToDevice, stream);
    cudaMemcpy(d_size, &size, sizeof(uint32_t), cudaMemcpyHostToDevice);

    cudaHostUnregister(arr1);
    cudaHostUnregister(arr2);
  }), time.memcpy, start, end);

  dim3 blocks(KBLOCKS, 1, 1);
  dim3 threads(KTHREADS, 1, 1);

  CUDATIME(({
    switch(op) {
      case opadd : KAdd<<<blocks,threads>>>(d_arr1, d_arr2, d_out, *d_size); break;
      case opsub : KSub<<<blocks,threads>>>(d_arr1, d_arr2, d_out, *d_size); break;
      case opmul : KMul<<<blocks,threads>>>(d_arr1, d_arr2, d_out, *d_size); break;
      case opdiv : KDiv<<<blocks,threads>>>(d_arr1, d_arr2, d_out, *d_size); break;
      default : break;
    } 
  }), time.run, start, end);

  CUDATIME(({
    cudaHostRegister(out, size*sizeof(arr_t), cudaHostRegisterDefault);

    cudaMemcpyAsync(out, d_out, size*sizeof(arr_t), cudaMemcpyDeviceToHost, stream);

    cudaHostUnregister(out);
  }), time.memret, start, end); 

  time.total = time.memcpy + time.run + time.memret;

  cudaStreamSynchronize(stream);
  cudaStreamDestroy(stream);

  cudaFree(d_arr1);
  cudaFree(d_arr2);
  cudaFree(d_out);
  cudaFree(d_size);

  return time;
}



__global__ void KAdd(arr_t* arr1, arr_t* arr2, arr_t* out, const uint32_t& size) {
  uint32_t idx = blockIdx.x * blockDim.x + threadIdx.x;
  if(idx < size)
    out[idx] = arr1[idx] + arr2[idx];
}

__global__ void KSub(arr_t* arr1, arr_t* arr2, arr_t* out, const uint32_t& size) {
  uint32_t idx = blockIdx.x * blockDim.x + threadIdx.x;
  if(idx < size)
    out[idx] = arr1[idx] - arr2[idx];
}

__global__ void KMul(arr_t* arr1, arr_t* arr2, arr_t* out, const uint32_t& size) {
  uint32_t idx = blockIdx.x * blockDim.x + threadIdx.x;
  if(idx < size)
    out[idx] = arr1[idx] * arr2[idx];
}

__global__ void KDiv(arr_t* arr1, arr_t* arr2, arr_t* out, const uint32_t& size) {
  uint32_t idx = blockIdx.x * blockDim.x + threadIdx.x;
  if(idx < size && arr2[idx])
    out[idx] = arr1[idx] / arr2[idx];
}

#endif
