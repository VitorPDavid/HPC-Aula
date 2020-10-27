#ifndef _GPU_H_
#define _GPU_H_
#include <cuda.h>
#include <vector_types.h>
#include <cv.h>
#include <highgui.h>
#define CHECK_ERROR(call) do {                                            \
    if( cudaSuccess != call) {                                            \
   fprintf(stderr, "Cuda error in file '%s' in line %i .\n",              \
         __FILE__, __LINE__  );                                           \
         exit(0);                                                         \
} } while (0)

IplImage * GPU_RGB2YIQ(IplImage *inputImg, const float threshold, char type);


#endif
