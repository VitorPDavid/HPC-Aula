/*
 *************************************************************************
   unsigned int width = gridDim.x * blockDim.x;
   unsigned int height = gridDim.y * blockDim.y;
   unsigned int x = blockDim.x * blockIdx.x + threadIdx.x;
   unsigned int y = blockDim.y * blockIdx.y + threadIdx.y;
   unsigned int kn = y * width + x;
 *************************************************************************
*/

#include <stdio.h>
#include <math.h>
#include <vector_types.h>
#include "GPU.h"
texture<float4, 2> texRef; //Must be global....
cudaChannelFormatDesc channelDesc = cudaCreateChannelDesc<float4>();
cudaArray* cuArray = NULL;

__global__ 
void kernel(float* V)
{
   unsigned int bx = blockIdx.x;
   unsigned int by = blockIdx.y;
   
   unsigned int tx = threadIdx.x;
   unsigned int ty = threadIdx.y;
   
   unsigned int width = gridDim.x * blockDim.x;
   unsigned int height = gridDim.y * blockDim.y;
   unsigned int x = blockDim.x * blockIdx.x + threadIdx.x;
   unsigned int y = blockDim.y * blockIdx.y + threadIdx.y;
   unsigned int kn = y * width + x;
   
   unsigned int k  = ty * blockDim.x + tx;
   
   float4 fx = tex2D(texRef, x, y );
   V[kn] = (fx.x * 1.0f) + (fx.y * 2.0f) + (fx.z * 3.0f) + (fx.w * 4.0f);
   
    
}
//----------------------------------------------------------------------------------------------------
dim3         dGrid,
             dThreads;
unsigned int uTexMemSize  = 0,
             uGloMemSize  = 0;

float        *fGPUMem  = NULL;  

extern "C" void runOnGPU(float *output, unsigned int s1, float4 *input, unsigned int s2, unsigned int w, unsigned int h)
{

  

   dGrid.x = BLOCK_SIZE;
   dGrid.y = BLOCK_SIZE;
   dGrid.z = 1;
   
   dThreads.x = w / BLOCK_SIZE;
   dThreads.y = h / BLOCK_SIZE;
   dThreads.z = 1;
   
   
   uTexMemSize  = s2;
   uGloMemSize  = s1;
         
   fprintf(stdout, "\n channelDesc(%d, %d, %d, %d, [%d] )\n\n", channelDesc.x, channelDesc.y, channelDesc.z, channelDesc.w, channelDesc.f);
    
   
   fprintf(stdout, "\nAllocating texture 2D (%d, %d)", w, h);
   CHECK_ERROR(cudaMallocArray(&cuArray, &channelDesc, w, h));
   
   CHECK_ERROR(cudaMemcpyToArray(cuArray, 0, 0, input, uTexMemSize, cudaMemcpyHostToDevice));
   
   // Set texture parameters
   CHECK_ERROR(cudaBindTextureToArray(texRef, cuArray));


   
   CHECK_ERROR(cudaMalloc((void**) &fGPUMem, uGloMemSize));
   CHECK_ERROR(cudaMemset(fGPUMem,  0, uGloMemSize));
   
   fprintf(stdout, "\nMem used: %dbytes", (uGloMemSize+uTexMemSize));
   kernel<<<dGrid, dThreads>>>(fGPUMem);

   CHECK_ERROR(cudaThreadSynchronize()); 
   CHECK_ERROR(cudaMemcpy(output, fGPUMem, uGloMemSize, cudaMemcpyDeviceToHost));
   
   CHECK_ERROR(cudaUnbindTexture(texRef));
   CHECK_ERROR(cudaFreeArray(cuArray));
   CHECK_ERROR(cudaFree(fGPUMem));

}

