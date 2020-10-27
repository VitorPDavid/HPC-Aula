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
void kernel (unsigned char *out_pixel,
             uchar4 *in_pixel)              //Tempo 0)
{
    
    int tx     = threadIdx.x,
        ty     = threadIdx.y,
        width  = gridDim.x * blockDim.x,
        height = gridDim.y * blockDim.y,
        x      = blockDim.x * blockIdx.x + threadIdx.x,
        y      = blockDim.y * blockIdx.y + threadIdx.y,
        kn     = y * width + x;


    float4 pixelA,
           pixelB;


    pixelA.x = (float) in_pixel[kn].x;
    pixelA.y = (float) in_pixel[kn].y;
    pixelA.z = (float) in_pixel[kn].z;
    pixelA.w = (float) in_pixel[kn].w;

    

    out_pixel[kn] = (unsigned char) (pixelB.x);
    

}
//----------------------------------------------------------------------------------------------------
extern "C" void callCUDA(   unsigned char *out_pixel,
                            uchar4 *in_pixel,
                            int width,
                            int height)
{
    // execute the kernel
    dim3         dGrid,
                 dThreads;

    dGrid.x = width / BSIZE_X;       //BLOCK_SIZE;
    dGrid.y = height / BSIZE_Y;
    dGrid.z = 1;

    dThreads.x =  BSIZE_X;
    dThreads.y =  BSIZE_Y;
    dThreads.z = 1;

  
    CHECK_ERROR(cudaThreadSynchronize());
    kernel<<<dGrid, dThreads>>>(out_pixel, in_pixel);
    CHECK_ERROR(cudaThreadSynchronize());

}



