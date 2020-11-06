///usr/local/cuda/bin/nvprof -u s --print-gpu-summary ./gol-cuda 1024 1024 1000 0 0.1
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <string.h>
#include <assert.h>
#include <omp.h>
struct stLattice{
    unsigned char *buff0;
    unsigned char *buff1;
    int width;
    int height;
    int steps;
};
typedef struct stLattice tpLattice;


__global__
void kernel( unsigned char *buff1, unsigned char  *buff0){
    unsigned int x      = blockDim.x * blockIdx.x + threadIdx.x,
                 y      = blockDim.y * blockIdx.y + threadIdx.y;
    unsigned char  cell = 0;
    unsigned char  myCell = buff0[y * blockDim.x * gridDim.x + x] ;
    unsigned char  newC = 0;
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

void GameOfLifeGPU(tpLattice *mLattice);
void InitRandnessGPU(tpLattice *mLattice, float p);
void print2File(tpLattice *mLattice);
int main(int ac, char**av)
{
    tpLattice mLattice;
    int flagSave = atoi(av[4]);
    float prob   = atof(av[5]);
    //Inicializa variável
    mLattice.width  = atoi(av[1]);
    mLattice.height = atoi(av[2]);
    mLattice.steps  = atoi(av[3]);

    fprintf(stdout, "\nGame of life");
    fprintf(stdout, "\nDominio(%d, %d, %d) Prob. %5.3f\n",   mLattice.width,   mLattice.height, mLattice.steps, prob);

    fflush(stdout);

    assert(cudaDeviceReset() == cudaSuccess);

    assert(cudaMalloc((void**) &mLattice.buff0, mLattice.width *   mLattice.height *  sizeof(unsigned char)) == cudaSuccess);
    assert(cudaMalloc((void**) &mLattice.buff1, mLattice.width *   mLattice.height *  sizeof(unsigned char)) == cudaSuccess);

//    mLattice.buff0 = (unsigned char*) malloc (mLattice.width *   mLattice.height *  sizeof(unsigned char));
//    mLattice.buff1 = (unsigned char*) malloc (mLattice.width *   mLattice.height *  sizeof(unsigned char));
    InitRandnessGPU(&mLattice, prob);
    GameOfLifeGPU(&mLattice);

    if (flagSave == 1)
      print2File(&mLattice);

    cudaFree(mLattice.buff0);
    cudaFree(mLattice.buff1);
    return EXIT_SUCCESS;
}

/*
 * Função utilizada para iniciar a matriz. Não mudar o valor constante do seed do rand
 */
void InitRandnessGPU(tpLattice *mLattice, float p){
  cudaMemset(mLattice->buff0, 0x00,  mLattice->width *   mLattice->height *  sizeof(unsigned char));
  cudaMemset(mLattice->buff1, 0x00,  mLattice->width *   mLattice->height *  sizeof(unsigned char));
  unsigned char *buff = (unsigned char *)malloc(mLattice->width *   mLattice->height *  sizeof(unsigned char));
  bzero(buff, mLattice->width *   mLattice->height *  sizeof(unsigned char));
  srand (42);
  for (int j = 1; j < mLattice->height - 1; j++){
      for (int i = 1; i < mLattice->width - 1; i++){
          int k = j * mLattice->width  +  i;
          float r = (rand() / (float)RAND_MAX);
          if (r <= p)
            buff[k] = 1;

      }//end-  for (int i = 0; i < mLattice->width; i++){
  }//end-for (int j = 0; j < mLattice->height; j++){

  assert(cudaMemcpy(mLattice->buff0, buff, mLattice->width *   mLattice->height *  sizeof(unsigned char),  cudaMemcpyHostToDevice) == cudaSuccess);
  free(buff);

}//end-void InitRandness(tpLattice *mLattice, float p){

/*
 * Função que resolve o GOL chamando o kernel da GPU
 */
 void GameOfLifeGPU(tpLattice *mLattice){
     dim3 threads = dim3(32, 32, 1);
     dim3 blocks  = dim3(mLattice->width / threads.x,  mLattice->height / threads.y, 1);

     for (int i = 0; i < mLattice->steps; i++){
       kernel<<<blocks, threads>>> (mLattice->buff1, mLattice->buff0);
       assert(cudaDeviceSynchronize() == cudaSuccess);
       unsigned char *swap = mLattice->buff0;
       mLattice->buff0 = mLattice->buff1;
       mLattice->buff1 = swap;

     }


 }

/*
 * Função para imprimir para arquivo. Formato do arquivo .txt
 */
void print2File(tpLattice *mLattice)
{
  fprintf(stdout, "Save to file: game_of_life.txt");
  FILE *ptr = fopen("game_of_life_gpu.txt", "w+");
  assert(ptr  != NULL);

  unsigned char *buff = (unsigned char *)malloc(mLattice->width *   mLattice->height *  sizeof(unsigned char));
  assert(cudaMemcpy(buff, mLattice->buff0, mLattice->width *   mLattice->height *  sizeof(unsigned char),  cudaMemcpyDeviceToHost) == cudaSuccess);

  for (int j = 1; j < mLattice->height - 1; j++){
      for (int i = 1; i < mLattice->width - 1; i++){
          int k = j * mLattice->width  +  i;
          if (buff[k] == 1)
            fputc('#', ptr);
          else
           fputc(' ', ptr);
      }//end-  for (int i = 0; i < mLattice->width; i++){
      fputc('\n', ptr);
  }//end-for (int j = 0; j < mLattice->height; j++){


  fclose(ptr);
  fprintf(stdout, "\t[OK]\n");
  free(buff);

}
