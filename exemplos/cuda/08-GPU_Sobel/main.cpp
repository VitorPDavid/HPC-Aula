////////////////////////////////////////////////////////////////////////
//
// hello-world.cpp
//
// This is a simple, introductory OpenCV program. The program reads an
// image from a file, inverts it, and displays the result.
//
////////////////////////////////////////////////////////////////////////
#include <cstdlib>
#include <cstdio>
#include <cmath>
#include <cv.h>
#include <highgui.h>
#include <App.h>
#include <iostream>
#include <vector>
#include <GPU.h>
using namespace std;

void CPU_Sobel(IplImage *img, float threshold){
	int height    = img->height,
		width     = img->width;

	uchar *output = new uchar [width * height];
	uchar *input     = reinterpret_cast <uchar *> (img->imageData);
	for (int i = 0; i < height ; i++)
		  for (int j = 0; j < width ; j++){

			  float sum_X = 0.0f, sum_Y = 0.0f;

			  if (i == 0 || i== width - 1 || j == 0 || j == height - 1)
				  output[i * width + j] = 0;
			  else{
				  sum_X = static_cast<float> (input[(i+1) * width + (j-1)]) +       \
						  2.0f * static_cast<float> (input[(i+1) * width + (j)]) +  \
						  static_cast<float> (input[(i+1) * width + (j+1)]) -       \
						  static_cast<float> (input[(i-1) * width + (j-1)]) -       \
						  2.0f * static_cast<float> (input[(i-1) * width + (j)]) -  \
						  static_cast<float> (input[(i-1) * width + (j+1)]);

				  sum_X = static_cast<float> (input[(i-1) * width + (j+1)]) +       \
						  2.0f * static_cast<float> (input[(i) * width + (j+1)]) +  \
						  static_cast<float> (input[(i+1) * width + (j+1)]) -       \
						  static_cast<float> (input[(i-1) * width + (j-1)]) -       \
						  2.0f * static_cast<float> (input[(i) * width + (j-1)]) -  \
						  static_cast<float> (input[(i+1) * width + (j-1)]);

			  }


			  float xy = sqrt(fabs(sum_X) + fabs(sum_Y));

			  if (xy > threshold)
				  output[i * width + j] = 255;// static_cast <uchar> (xy);;
			  else
				  output[i * width + j] = 0;

		  }

	img->imageData = reinterpret_cast<char*>(output);
	//delete filtered_X, filtered_Y;

}



IplImage * CPU_RGB2YIQ(IplImage *inputImg){
// get the image data
  int height    = inputImg->height,
	  width     = inputImg->width;

  IplImage *newImg = cvCreateImage(cvSize(width,height),IPL_DEPTH_8U,1); //Apenas tons de cinza
  uchar *inPtr      = reinterpret_cast <uchar *> (inputImg->imageData);
  uchar *outPtr     = reinterpret_cast <uchar *> (newImg ->imageData);


  float fR = 0.0f, fG = 0.0f, fB = 0.0f,
		fY = 0.0f, fI = 0.0f, fQ = 0.0f;

  for (int i = 0; i < height ; i++)
	  for (int j = 0; j < width ; j++){
		  int ptrIn  = i * width * 3 + j * 3;
		  int ptrOut = i * width + j ;
		  fR = static_cast<float> (inPtr[ptrIn+0]) / 255.0f;
		  fG = static_cast<float> (inPtr[ptrIn+1]) / 255.0f;
		  fB = static_cast<float> (inPtr[ptrIn+2]) / 255.0f;

		  fY = 0.299f    * fR + 0.587f     * fG +  0.114f    * fB;
		  fI = 0.595716f * fR + -0.274453f * fG + -0.321263f * fB;
		  fQ = 0.211456f * fR + -0.522591f * fG +  0.311135f * fB;
		  outPtr[ptrOut] = static_cast<uchar> ( fY * 255.0f);
	  }

  return newImg;
}

int main(int argc, char *argv[])
{
  IplImage *img = 0;


  Stopwatch stopwatch;
  FREQUENCY(stopwatch);

  if(argc < 3){
	cerr << "Usage: main <image-file-name>\n\7" << endl;
    exit(0);
  }

  // load an image
  img = cvLoadImage(argv[1]);
  if(!img){
	cerr <<  "Could not load image file:" << argv[1] << endl;
    exit(0);
  }

  cout << "File: " << argv[1] << " threshold: " << atof(argv[2]) << endl;
  cout << "Type: " << argv[3] << endl;
  cout << "Width: " << img->width << " height: " << img->height << endl;
  // create a window
  //cvNamedWindow("mainWin", CV_WINDOW_KEEPRATIO);
  //cvMoveWindow("mainWin", 100, 100);
  //cvResizeWindow("mainWin", 800, 600);


  START_STOPWATCH(stopwatch);
  IplImage *source = GPU_RGB2YIQ(img, atof(argv[2]), argv[3][0]);
  //IplImage *newImg = CPU_RGB2YIQ(img);
  //CPU_Sobel(newImg, atof(argv[2]));
  STOP_STOPWATCH(stopwatch);
  cout << "Elapsed time: " << stopwatch.mElapsedTime << "ms" << endl;
  
  IplImage *destination = cvCreateImage( cvSize(800 , 600 ),
                                     source->depth, source->nChannels );
  cvResize(src, dest, CV_INTER_LINEAR);
 cvResize(source, destination,  CV_INTER_LINEAR);
 cvShowImage(argv[1], destination );




  cvWaitKey(0);

  cvDestroyWindow("mainWin");
  cvReleaseImage(&img );
  cvReleaseImage(&source );
  cvReleaseImage(&destination );
  return 0;
}
