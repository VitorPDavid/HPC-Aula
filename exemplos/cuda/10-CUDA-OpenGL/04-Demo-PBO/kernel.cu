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
void kernel (uchar4 *out_pixel,
             uchar4 *in_pixel,
             const float ratio)              //Tempo 0)
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

    //RGB --> YIQ

    pixelB.x = pixelA.x * 0.299f    + pixelA.y * 0.587f     + pixelA.z * 0.114f;
    pixelB.y = pixelA.x * 0.595716f + pixelA.y * -0.274453f + pixelA.z * -0.321263f;
    pixelB.z = pixelA.x * 0.211456f + pixelA.y * -0.522591f + pixelA.z *  0.311135f;
    //pixelB.w = pixelB.w;



    out_pixel[kn].x = (float) (pixelB.x * ratio) + (pixelA.x * (1.0f - ratio));
    out_pixel[kn].y = (float) (pixelB.y * ratio) + (pixelA.y * (1.0f - ratio));
    out_pixel[kn].z = (float) (pixelB.z * ratio) + (pixelA.z * (1.0f - ratio));
    out_pixel[kn].w = in_pixel[kn].w; //(float) )pixelB.w * ratio) + (pixelA.w * (1.0f - ratio));;
    //out_pixel.x[kn] = in_pixel.x[kn];
    

}
//----------------------------------------------------------------------------------------------------
extern "C" void callCUDA(   uchar4 *out_pixel,
                            uchar4 *in_pixel,
                            int width,
                            int height,
                            const float ratio)
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
    kernel<<<dGrid, dThreads>>>(out_pixel, in_pixel, ratio);
    CHECK_ERROR(cudaThreadSynchronize());

}



