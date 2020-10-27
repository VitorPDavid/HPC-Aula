/*
 *************************************************************************
   unsigned int width = gridDim.x * blockDim.x;
   unsigned int height = gridDim.y * blockDim.y;
   unsigned int x = blockDim.x * blockIdx.x + threadIdx.x;
   unsigned int y = blockDim.y * blockIdx.y + threadIdx.y;
   unsigned int kn = y * width + x;
 *************************************************************************
 N blocks x M threads  <---- IPC
*/

#include <cstdio>
#include <GPU.h>
#include <cv.h>
#include <highgui.h>
#include <App.h>
#include <cassert>
#include <iostream>
//#define BSIZE_X 24
//#define BSIZE_Y 8

#define BSIZE_X 12
#define BSIZE_Y 4

using namespace std;
__global__
void kernel_Sobel_S2(uchar *output, float *input, const int w, const int h, const float threshold){
//void kernel_Sobel_G(uchar *output, float *input, const int width, const int height, const float threshold){


	__shared__ float sharedMem[BSIZE_Y+(2*1)][BSIZE_X+(2*1)];

	    int tx     = threadIdx.x,
	        ty     = threadIdx.y,
	        width  = gridDim.x * blockDim.x,
	        height = gridDim.y * blockDim.y,
	        x      = blockDim.x * blockIdx.x + threadIdx.x,
	        y      = blockDim.y * blockIdx.y + threadIdx.y,
	        kn     = y * width + x,
	        sX     = tx + 1,
	        sY     = ty + 1;





	   sharedMem[sY][sX] =  input[kn] ;

	   if (threadIdx.x == 0)
	   {
	      if (blockIdx.x == 0){
		       sharedMem[sY][sX-1] = 0.0f;
		       sharedMem[sY-1][sX-1] = 0.0f;
             sharedMem[sY][sX+blockDim.x] = input[kn+blockDim.x] ;

	      }else if (blockIdx.x  == (gridDim.x - 1)){
		       sharedMem[sY][sX-1] = input[kn-1] ;
		       sharedMem[sY][sX+blockDim.x] = 0.0f;


         }else{
		       sharedMem[sY][sX-1] = input[kn-1] ;
		       sharedMem[sY][sX+blockDim.x] = input[kn+blockDim.x] ;

		       sharedMem[sY+1][sX-1] = input[kn-1 + width] ;
		       sharedMem[sY+1][sX+blockDim.x] = input[kn+blockDim.x + width] ;

		       sharedMem[sY-1][sX-1] = input[kn-1-width] ;
		       sharedMem[sY-1][sX+blockDim.x] = input[kn+blockDim.x-width] ;
               

         }

	   }

	   if (threadIdx.y == 0)
	   {
	      if (blockIdx.y == 0){
		       sharedMem[sY-1][sX] = 0.0f;
		       sharedMem[sY+blockDim.y][sX] = input[kn+(blockDim.y*width)] ;
            
	      }else if (blockIdx.y  == (gridDim.y - 1)){
		       sharedMem[sY-1][sX] = input[kn-width] ;
		       sharedMem[sY+blockDim.y][sX] = 0.0f;

         }else{
		       sharedMem[sY-1][sX] = input[kn-width] ;
		       sharedMem[sY+blockDim.y][sX] = input[kn+(blockDim.y * width)] ;
  
         }

	   }


	   __syncthreads();





	float sum_X = sharedMem[sY+1][sX-1] +       \
		        2.0f * sharedMem[sY+1][sX]  +   \
		        sharedMem[sY+1][sX+1]       -   \
		        sharedMem[sY-1][sX-1]       -   \
		        2.0f * sharedMem[sY-1][sX]  -   \
		        sharedMem[sY-1][sX+1];

	float sum_Y = sharedMem[sY-1][sX+1]  +       \
				2.0f * sharedMem[sY][sX+1] +    \
				sharedMem[sY+1][sX+1]  -         \
				sharedMem[sY-1][sX-1] -       \
				2.0f * sharedMem[sY][sX-1] -  \
				sharedMem[sY+1][sX-1];



	float xy = sqrt(fabs(sum_X) + fabs(sum_Y));

	if (xy > threshold)
		output[kn] = 255;// static_cast <uchar> (xy);;
	else
		output[kn] = 0;



}


//-------------
__global__
void kernel_Sobel_S(uchar *output, float *input, const int w, const int h, const float threshold){
//void kernel_Sobel_G(uchar *output, float *input, const int width, const int height, const float threshold){


	__shared__ float sharedMem[BSIZE_Y+(2*1)][BSIZE_X+(2*1)];

	    int tx     = threadIdx.x,
	        ty     = threadIdx.y,
	        width  = gridDim.x * blockDim.x,
	        height = gridDim.y * blockDim.y,
	        x      = blockDim.x * blockIdx.x + threadIdx.x,
	        y      = blockDim.y * blockIdx.y + threadIdx.y,
	        kn     = y * width + x,
	        sX     = tx + 1,
	        sY     = ty + 1;





	   sharedMem[sY][sX] =  input[kn] ;

	   if (threadIdx.x == 0)
	   {
	      if (blockIdx.x == 0){
		       sharedMem[sY][sX-1] = 0.0f;
		       sharedMem[sY-1][sX-1] = 0.0f;
             sharedMem[sY][sX+blockDim.x] = input[kn+blockDim.x] ;

	      }else if (blockIdx.x  == (gridDim.x - 1)){
		       sharedMem[sY][sX-1] = input[kn-1] ;
		       sharedMem[sY][sX+blockDim.x] = 0.0f;


         }else{
		       sharedMem[sY][sX-1] = input[kn-1] ;
		       sharedMem[sY][sX+blockDim.x] = input[kn+blockDim.x] ;

		       sharedMem[sY+1][sX-1] = input[kn-1 + width] ;
		       sharedMem[sY+1][sX+blockDim.x] = input[kn+blockDim.x + width] ;

		       sharedMem[sY-1][sX-1] = input[kn-1-width] ;
		       sharedMem[sY-1][sX+blockDim.x] = input[kn+blockDim.x-width] ;
               

         }

	   }

	   if (threadIdx.y == 0)
	   {
	      if (blockIdx.y == 0){
		       sharedMem[sY-1][sX] = 0.0f;
		       sharedMem[sY+blockDim.y][sX] = input[kn+(blockDim.y*width)] ;
            
	      }else if (blockIdx.y  == (gridDim.y - 1)){
		       sharedMem[sY-1][sX] = input[kn-width] ;
		       sharedMem[sY+blockDim.y][sX] = 0.0f;

         }else{
		       sharedMem[sY-1][sX] = input[kn-width] ;
		       sharedMem[sY+blockDim.y][sX] = input[kn+(blockDim.y * width)] ;
  
         }

	   }


	   __syncthreads();





	float sum_X = sharedMem[sY+1][sX-1] +       \
		        2.0f * sharedMem[sY+1][sX]  +   \
		        sharedMem[sY+1][sX+1]       -   \
		        sharedMem[sY-1][sX-1]       -   \
		        2.0f * sharedMem[sY-1][sX]  -   \
		        sharedMem[sY-1][sX+1];

	float sum_Y = sharedMem[sY-1][sX+1]  +       \
				2.0f * sharedMem[sY][sX+1] +    \
				sharedMem[sY+1][sX+1]  -         \
				sharedMem[sY-1][sX-1] -       \
				2.0f * sharedMem[sY][sX-1] -  \
				sharedMem[sY+1][sX-1];



	float xy = sqrt(fabs(sum_X) + fabs(sum_Y));

	if (xy > threshold)
		output[kn] = 255;// static_cast <uchar> (xy);;
	else
		output[kn] = 0;



}
 

__global__
void kernel_Sobel_G(uchar *output, float *input, const int width, const int height, const float threshold){
	unsigned int x      = blockDim.x * blockIdx.x + threadIdx.x,
			     y      = blockDim.y * blockIdx.y + threadIdx.y;

	float sum_X = 0.0f,
		  sum_Y = 0.0f;

	if (x == 0 || x == width - 1 || y == 0 || y == height - 1)
		output[y * width + x] = 0;
	else{
		sum_X = input[(y+1) * width + (x-1)] +       \
		        2.0f * input[(y+1) * width + (x)] +  \
		        input[(y+1) * width + (x+1)] -       \
		        input[(y-1) * width + (x-1)] -       \
		        2.0f * input[(y-1) * width + (x)] -  \
		        input[(y-1) * width + (x+1)];

	    sum_Y = input[(y-1) * width + (x+1)] +       \
				2.0f * input[(y) * width + (x+1)] +  \
				input[(y+1) * width + (x+1)] -       \
				input[(y-1) * width + (x-1)] -       \
				2.0f * input[(y) * width + (x-1)] -  \
				input[(y+1) * width + (x-1)];
	 }


	float xy = sqrt(fabs(sum_X) + fabs(sum_Y));

	if (xy > threshold)
		output[y * width + x] = 255;// static_cast <uchar> (xy);;
	else
		output[y * width + x] = 0;



}
__global__
void kernel_RGB2YIQ(float *output, uchar *input, const int width){
	unsigned int x      = blockDim.x * blockIdx.x + threadIdx.x;
	unsigned int y      = blockDim.y * blockIdx.y + threadIdx.y;
	unsigned int ptrIn   = (y * width * 3) + (x * 3);
	unsigned int ptrOut  = y * width  + x ;

	float fR = 0.0f, fG = 0.0f, fB = 0.0f,
			fY = 0.0f;//, fI = 0.0f, fQ = 0.0f;

	fR = static_cast<float> (input[ptrIn+0]) / 255.0f;
	fG = static_cast<float> (input[ptrIn+1]) / 255.0f;
	fB = static_cast<float> (input[ptrIn+2]) / 255.0f;

	fY = 0.299f    * fR + 0.587f     * fG +  0.114f    * fB;
	//fI = 0.595716f * fR + -0.274453f * fG + -0.321263f * fB;
	//fQ = 0.211456f * fR + -0.522591f * fG +  0.311135f * fB;
	output[ptrOut] =  fY * 255.0f;

}

IplImage * GPU_RGB2YIQ(IplImage *inputImg, const float threshold, char type) {
// get the image data
  int height    = inputImg->height,
	  width     = inputImg->width,
	  imgSize   =  width * height;

  IplImage *newImg = cvCreateImage(cvSize(width,height),IPL_DEPTH_8U,1); //Apenas tons de cinza

  uchar *srcImg = NULL,
		*sblImg = NULL;

  float *iyqImg = NULL;


  dim3 blocks,  //= dim3(width/BSIZE_X, height/BSIZE_Y, 1),
	   threads;// = dim3(BSIZE_X, BSIZE_Y, 1);

  blocks.x = width/BSIZE_X;
  blocks.y = height/BSIZE_Y;
  blocks.z = 1;

  threads.x = BSIZE_X;
  threads.y = BSIZE_Y;
  threads.z = 1;

  assert(threads.x * threads.y <= 512);

   cout << "Threads (" << threads.x << "," << threads.y << ")" << endl;
   cout << "Blocks  (" << blocks.x << "," << blocks.y << ")" << endl;


  CHECK_ERROR(cudaMalloc((void**) &srcImg, imgSize * 3));
  CHECK_ERROR(cudaMalloc((void**) &iyqImg, imgSize * sizeof(float)));
  CHECK_ERROR(cudaMalloc((void**) &sblImg, imgSize));

  CHECK_ERROR(cudaMemcpy(srcImg, reinterpret_cast <uchar *> (inputImg->imageData), imgSize * 3, cudaMemcpyHostToDevice));

  Stopwatch stopwatch;
  FREQUENCY(stopwatch);

  START_STOPWATCH(stopwatch);
  kernel_RGB2YIQ<<<blocks, threads>>> (iyqImg, srcImg,  width);
  //CHECK_ERROR(cudaDeviceSynchronize());
  if (type == 'G'){
      kernel_Sobel_G<<<blocks, threads>>> (sblImg, iyqImg,  width, height, threshold);
    //  cout << "GLOBAL" << endl;  
   }else{
      kernel_Sobel_S2<<<blocks, threads>>> (sblImg, iyqImg,  width, height, threshold);
  //    cout << "SHARED" << endl;
   }
  CHECK_ERROR(cudaDeviceSynchronize());
  STOP_STOPWATCH(stopwatch);
  cout << "Elapsed time: " << stopwatch.mElapsedTime << "ms" << endl;


  CHECK_ERROR(cudaMemcpy(reinterpret_cast <uchar *> (newImg->imageData), sblImg, imgSize, cudaMemcpyDeviceToHost));

  return newImg;
}



//



