#include <ToolsGPU.cuh>
#include <ctime>
#include <cstdio>
#define CHECK_ERROR(call) do {                                            \
    if( cudaSuccess != call) {                                            \
   fprintf(stderr, "Cuda error in file '%s' in line %i .\n",              \
         __FILE__, __LINE__  );                                           \
         exit(0);                                                         \
} } while (0)


__global__
void kernel(int *buff1, int *buff0){
    unsigned int x      = blockDim.x * blockIdx.x + threadIdx.x,
                 y      = blockDim.y * blockIdx.y + threadIdx.y;
    int cell = 0;
    int myCell = buff0[y * blockDim.x * gridDim.x + x] ;
    int newC = 0;
    //buff1[y * blockDim.x * gridDim.x + x] = 1 - buff0[y * blockDim.x * gridDim.x + x];
    
    if ((x > 0) && ( x < ((blockDim.x * gridDim.x) - 1)) && (y > 0) && (y < ((blockDim.y * gridDim.y) - 1))){
        cell = buff0[(y+1) * blockDim.x * gridDim.x + (x-1)] +  \
               buff0[(y+1) * blockDim.x * gridDim.x + (x)]   +  \
               buff0[(y+1) * blockDim.x * gridDim.x + (x+1)] +  \
               buff0[(y-1) * blockDim.x * gridDim.x + (x-1)] +  \
               buff0[(y-1) * blockDim.x * gridDim.x + (x)]   +  \
               buff0[(y-1) * blockDim.x * gridDim.x + (x+1)] +  \
               buff0[y * blockDim.x * gridDim.x + (x-1)] +  \
               buff0[y * blockDim.x * gridDim.x + (x+1)] ;
    
    }


    if ((cell == 3) && (myCell == 0))   
        newC = 1;

    if ((cell >= 2) && (cell <= 3) && (myCell == 1))
        newC = 1;
    
    
    buff1[y  * blockDim.x * gridDim.x  +  x] = newC;
}

void GameOfLifeGPU(tpLattice *mLattice){
    dim3 threads = dim3(32, 32, 1);
    dim3 blocks  = dim3(mLattice->width / threads.x,  mLattice->height / threads.y, 1);
    kernel<<<blocks, threads>>> (mLattice->buff1, mLattice->buff0);
    CHECK_ERROR(cudaDeviceSynchronize());
    
}


void InitRandnessGPU(tpLattice *mLattice, int *buffer, float p){
  memset(buffer, 0x00,  mLattice->width *   mLattice->height *  sizeof(int));
   
  for (int j = 1; j < mLattice->height - 1; j++){
      for (int i = 1; i < mLattice->width - 1; i++){
          int k = j * mLattice->width  +  i;
          float r = (rand() / (float)RAND_MAX);
          if (r <= p)
            buffer[k] = 1;

      }//end-  for (int i = 0; i < mLattice->width; i++){
  }//end-for (int j = 0; j < mLattice->height; j++){
  
  cudaMemcpy((void*)mLattice->buff0,  (const void*) buffer,  mLattice->width *   mLattice->height *  sizeof(int), cudaMemcpyHostToDevice);
}//end-void InitRandness(tpLattice *mLattice, float p){