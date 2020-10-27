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
#include <GPU.h>
#include <App.h>

#include <vector_types.h>
#include <cuda.h>
#include <cuda_runtime_api.h>
#include <cuda_gl_interop.h>



__global__ 
void kernelRun (float4 *vertex,
             float *gpu_U1,             //Tempo 1
             float *gpu_U0,
             float *gpu_V)              //Tempo 0)
{
    __shared__ float sharedMem[BSIZE_Y+(2*NPOP)][BSIZE_X+(2*NPOP)];

    int tx     = threadIdx.x,
        ty     = threadIdx.y,
        width  = gridDim.x * blockDim.x,
        height = gridDim.y * blockDim.y,
        x      = blockDim.x * blockIdx.x + threadIdx.x,
        y      = blockDim.y * blockIdx.y + threadIdx.y,
        kn     = y * width + x,
        sX     = tx + NPOP,
        sY     = ty + NPOP;

   float v = VELOCITY,
         old =   gpu_U1[kn];
         
   v = v * v;



   __syncthreads();

   sharedMem[sY][sX] =  gpu_U0[kn] ;

   if (threadIdx.x < NPOP)
   {
      if (blockIdx.x > 0)
         sharedMem[sY][sX-NPOP] = gpu_U0[kn - NPOP] ;
      else
         sharedMem[sY][sX-NPOP] = 0.0f;

      if (blockIdx.x  < (gridDim.x - 1))
         sharedMem[sY][sX+blockDim.x] = gpu_U0[kn + blockDim.x] ;
      else
         sharedMem[sY][sX+blockDim.x] = 0.0f;

   }

   if (threadIdx.y < NPOP)
   {
      if (blockIdx.y > 0)
         sharedMem[sY-NPOP][sX] = gpu_U0[kn - (NPOP*width)];
      else
         sharedMem[sY-NPOP][sX] = 0.0f;

      if (blockIdx.y  < (gridDim.y - 1))
         sharedMem[sY+blockDim.y][sX] = gpu_U0[kn +(blockDim.y*width)] ;
      else
         sharedMem[sY+blockDim.y][sX] = 0.0f;

   }
   __syncthreads();
   
   v *=  gpu_V[y * XPOINTS + x];


  float pX = (sharedMem[sY][sX-2]-(16.0f*(sharedMem[sY][sX-1]+sharedMem[sY][sX+1]))+(30.0f*sharedMem[sY][sX])+sharedMem[sY][sX+2]) * ALPHA * v;
  float pY = (sharedMem[sY-2][sX]-(16.0f*(sharedMem[sY-1][sX]+sharedMem[sY+1][sX]))+(30.0f*sharedMem[sY][sX])+sharedMem[sY+2][sX]) * ALPHA * v;

  gpu_U1[kn] = ((CONSTANT * (pX + pY)) + (2.0f * sharedMem[sY][sX]) - old);


    vertex[kn].x =  (x*4.0f);
    vertex[kn].z =  (y*4.0f);

    vertex[kn].y = gpu_U1[kn]; //+ gpu_U0[kn];
    vertex[kn].w = 1.0f;
 
}


__global__
void kernelPause(float4 *vertex,
             float *gpu_U1,             //Tempo 1
             float *gpu_U0)              //Tempo 0)
{
    int tx     = threadIdx.x,
        ty     = threadIdx.y,
        width  = gridDim.x * blockDim.x,
        height = gridDim.y * blockDim.y,
        x      = blockDim.x * blockIdx.x + threadIdx.x,
        y      = blockDim.y * blockIdx.y + threadIdx.y,
        kn     = y * width + x,
        sX     = tx + NPOP,
        sY     = ty + NPOP;

    vertex[kn].x =  (x*4.0f);
    vertex[kn].z =  (y*4.0f);

    vertex[kn].y = gpu_U1[kn]; // * gpu_R[kn] ; //+ gpu_U0[kn];
    vertex[kn].w = 1.0f;


}
//----------------------------------------------------------------------------------------------------
extern "C" void callCUDARun(float4 *ptrVertice,
                         float *gpu_U0,
                         float *gpu_U1,
                         float *gpu_V,
                         int xVertex,
                         int zVertex)
{
    // execute the kernel
    dim3         dGrid,
                 dThreads;

    dGrid.x = 512 / BSIZE_X;       //BLOCK_SIZE;
    dGrid.y = 512 / BSIZE_Y;
    dGrid.z = 1;

    dThreads.x =  BSIZE_X;
    dThreads.y =  BSIZE_Y;
    dThreads.z = 1;

    
    CHECK_ERROR(cudaThreadSynchronize());
    kernelRun<<<dGrid, dThreads>>>(ptrVertice, gpu_U1, gpu_U0, gpu_V);
    CHECK_ERROR(cudaThreadSynchronize()); 
    
}



extern "C" void callCUDAPause(float4 *ptrVertice,
                         float *gpu_U0,
                         float *gpu_U1,
                         int xVertex,
                         int zVertex)
{
    // execute the kernel
    dim3         dGrid,
                 dThreads;

    dGrid.x = 512 / BSIZE_X;       //BLOCK_SIZE;
    dGrid.y = 512 / BSIZE_Y;
    dGrid.z = 1;

    dThreads.x =  BSIZE_X;
    dThreads.y =  BSIZE_Y;
    dThreads.z = 1;


    CHECK_ERROR(cudaThreadSynchronize());
    kernelPause<<<dGrid, dThreads>>>(ptrVertice, gpu_U1, gpu_U0);
    CHECK_ERROR(cudaThreadSynchronize());

}