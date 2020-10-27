#ifndef _GPU_H_
#define _GPU_H_
#include <cuda.h>
#include <vector_types.h>

////////////////////////////////////////////////////////////////////////////////
//
// Constantes
//
////////////////////////////////////////////////////////////////////////////////
#define  CFL                        1.0f / sqrt(2.0f)
#define  PI                         4.0f*atan(1.0f)
#define  FC                         30.0f
#define  SOURCE_TF                  2.0f * sqrt(PI) / FC
#define	 BSIZE_X                    32
#define	 BSIZE_Y                    16
#define  NPOP                       2
#define  CONSTANT                   (float) (-1.0f / 12.0f)
#define  DELTAT                     1.0f / 400.0f
#define  DELTAX                     2.0f
#define  ALPHA                      (DELTAT * DELTAT) / (DELTAX * DELTAX)
#define  VELOCITY                   300.0f 

#define XPOINTS 256
#define ZPOINTS 256
#define P_DOMAIN  XPOINTS * ZPOINTS


#define BLOCK_SIZE        2

#define CHECK_ERROR(call) do {                                            \
    if( cudaSuccess != call) {                                            \
   fprintf(stderr, "Cuda error in file '%s' in line %i .\n",              \
         __FILE__, __LINE__  );                                           \
         exit(0);                                                         \
} } while (0)

extern "C" void callCUDARun(float4 *, //Vertice
                         float  *,
                         float  *,
                         float  *,
                         int,
                         int);


extern "C" void callCUDAPause(float4 *, //Vertice
                         float  *,
                         float  *,
                         int,
                         int);

#endif
