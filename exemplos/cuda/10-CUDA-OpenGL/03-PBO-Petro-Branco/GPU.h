#ifndef _GPU_H_
#define _GPU_H_
#include <cuda.h>
#include <vector_types.h>
#include <stdlib.h>



#define	 BSIZE_X                    32
#define	 BSIZE_Y                    16

#define CHECK_ERROR(call) do {                                            \
    if( cudaSuccess != call) {                                            \
   fprintf(stderr, "Cuda error in file '%s' in line %i .\n",              \
         __FILE__, __LINE__  );                                           \
         exit(EXIT_FAILURE);                                              \
} } while (0)

extern "C" void callCUDA(unsigned char *,
                         uchar4 *, //Vertice
                         int,
                         int);



#endif
