#ifndef _GPU_H_
#define _GPU_H_
#include <cuda.h>
#include <vector_types.h>


#define BLOCK_SIZE        2
#define CHECK_ERROR(call) do {                                            \
    if( cudaSuccess != call) {                                            \
   fprintf(stderr, "Cuda error in file '%s' in line %i .\n",              \
         __FILE__, __LINE__  );                                           \
         exit(0);                                                         \
} } while (0)


extern "C" void runOnGPU(float*, unsigned int, float4 *, unsigned int, unsigned int, unsigned int);

#endif