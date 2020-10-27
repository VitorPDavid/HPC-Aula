#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <assert.h>
#define ERROR 1E-16
#define EPSILON 1E-17
#define MAXTHREADS 1024

struct stMatrix{
    double *A;
    double *B;
    double *X1;
    double *X0;
    int mn;
};
typedef struct stMatrix tpMatrix;
//------------------------------------------------------------------------------------------
/*
 * Kernel sem memória compartilhada para resolver sistema linear de jacobi
 */
 __global__ void JacobiMethodKernel_B( double *__restrict__ A,
                                       double *__restrict__ X1,
                                       double *__restrict__ X0,
                                       double *__restrict__ B,
                                       double *__restrict__ err,
                                       const unsigned int mn){
  
  extern __shared__ double buffer[];                                     
  unsigned int idx  =  (blockIdx.x * blockDim.x) + threadIdx.x;
  double  aux    = 0.0, 
          div    = 0.0f;

  for (unsigned b = 0; b < gridDim.x; b++){
    buffer[threadIdx.x] = X0[(b * blockDim.x) + threadIdx.x];
    __syncthreads();
    
    for (unsigned int i = 0; i < blockDim.x; i++){  
        
      unsigned int j = (b * blockDim.x) + i;
        
        if (idx != j)
          aux += (A[mn*idx + j] * buffer[i]);
        else
          div =  A[mn*idx + j];
    }//end-for (unsigned int i = 0; i < blockDim.x; i++){  

    __syncthreads();
  }//end-for (unsigned b = 0; b < gridDim.x; b++){
  


  X1[idx] =  ((B[idx] - aux) / div );
  err[idx] =  fabs((X1[idx] - X0[idx]) / (X1[idx] + EPSILON));
}
//------------------------------------------------------------------------------------------
/*
 * Kernel sem memória compartilhada para resolver sistema linear de jacobi
 */
__global__ void JacobiMethodKernel_A( double *__restrict__ A,
                                      double *__restrict__ X1,
                                      double *__restrict__ X0,
                                      double *__restrict__ B,
                                      double *__restrict__ err,
                                      const unsigned int mn){
  unsigned int idx  =  (blockIdx.x * blockDim.x) + threadIdx.x;
  double aux = 0.0, 
  valueX = 0.0, 
  div = 0.0f;
  for (unsigned int i = 0; i < mn; i++){
    valueX = X0[i];
    if (idx != i)
      aux += (A[mn*idx + i] * valueX);
    else
      div =  A[mn*idx + i];
  }
  X1[idx] =  ((B[idx] - aux) / div );
  err[idx] =  fabs((X1[idx] - X0[idx]) / (X1[idx] + EPSILON));
}


//------------------------------------------------------------------------------------------
/*
 * Kernel que acha a max do conjunto - usa apenas 1 bloco
 */

__global__  void findMax(double *X, const unsigned int blocks){
  extern __shared__ double buffer[];
  unsigned int i = threadIdx.x;
  buffer[threadIdx.x] = X[i];

  for (unsigned int j = 0; j < blocks; j++){
    buffer[threadIdx.x] = max(buffer[threadIdx.x], X[threadIdx.x + j * blockDim.x]);
  }
//Se deslocar para os outros blocosk

  
  for (int k = (blockDim.x >> 1); k >= 1; k >>= 1){
      __syncthreads();
      if (threadIdx.x < k){
        buffer[threadIdx.x] = max(buffer[threadIdx.x], buffer[threadIdx.x + k]);
      }
  }
  
  __syncthreads();
  if (threadIdx.x == 0)
    X[threadIdx.x] = buffer[threadIdx.x];


}


//------------------------------------------------------------------------------------------
void LoadMatrixAndVector(char *matrixFile, char *vectorFile, tpMatrix *matrix);
void PrintMatrixAndVector(const tpMatrix *matrix);
void JacobiMethodGPU(tpMatrix *matrix);
void JacobiMethodCPU(tpMatrix *matrix);
void PrintX(double *X, const int size);
int main(int ac, char**av) {
  tpMatrix matrix;
  
  int      flagSave = atoi(av[4]);
  fprintf(stdout, "\nMétodo iterativo de solução de sistema linear - Jacobi\n");
  
  matrix.mn = atoi(av[3]);
  matrix.A = (double*) malloc (matrix.mn * matrix.mn *  sizeof(double));
  matrix.B = (double*) malloc (matrix.mn * sizeof(double));
  matrix.X0 = (double*) malloc (matrix.mn *  sizeof(double));
  matrix.X1 = (double*) malloc (matrix.mn *  sizeof(double));
  memset(matrix.X0, 0x00, matrix.mn *  sizeof(double));
  memset(matrix.X1, 0x00, matrix.mn *  sizeof(double));

  LoadMatrixAndVector(av[1], av[2], &matrix);
//    PrintMatrixAndVector(&matrix);
  //JacobiMethod(&matrix, iter);
  JacobiMethodGPU(&matrix);

  if (flagSave == 1)
    PrintX(matrix.X0, matrix.mn);



  free(matrix.A);
  free(matrix.B);
  free(matrix.X0);

  return EXIT_SUCCESS;
}

/*
 * Carrega a matrix e o vetor B do arquivo
 */
void LoadMatrixAndVector(char *matrixFile, char *vectorFile, tpMatrix *matrix){
  FILE *ptr = fopen(matrixFile, "rb+");
  assert(ptr != NULL);
  fread (matrix->A,sizeof(double), matrix->mn * matrix->mn, ptr);
  fclose(ptr);

  ptr = fopen(vectorFile, "rb+");
  assert(ptr != NULL);
  fread (matrix->B,sizeof(double), matrix->mn , ptr);
    
  fclose(ptr);
}

void PrintMatrixAndVector(const tpMatrix *matrix){

  fprintf(stdout, "Matrix (%d, %d)\n", matrix->mn, matrix->mn);
  for (int j = 0; j < matrix->mn; j++){
    for (int i = 0; i < matrix->mn; i++){
      int k = j * matrix->mn + i;
      fprintf(stdout, "%.7f ", matrix->A[k]);
    }
   fprintf(stdout, " \t %.7f \n", matrix->B[j]);
  }
}

void JacobiMethodGPU(tpMatrix *matrix){
  unsigned int blocks = 0,
               threads = MAXTHREADS;

  double *d_A  = NULL, 
         *d_B  = NULL, 
         *d_X0 = NULL, 
         *d_X1 = NULL, 
         *d_Err = NULL,
         h_err = 0.0;

  int inter = 0;       

  unsigned int memCudaDataMatrixSize = sizeof(double) * (matrix->mn * matrix->mn);
  unsigned int memCudaDataVectorSize = sizeof(double) * (matrix->mn);
  assert(cudaMalloc((void**) &d_A, memCudaDataMatrixSize) == cudaSuccess);
  assert(cudaMalloc((void**) &d_X0, memCudaDataVectorSize) == cudaSuccess);
  assert(cudaMalloc((void**) &d_X1, memCudaDataVectorSize) == cudaSuccess);
  assert(cudaMalloc((void**) &d_B, memCudaDataVectorSize) == cudaSuccess);         
  assert(cudaMalloc((void**) &d_Err, memCudaDataVectorSize) == cudaSuccess);         

  assert(cudaMemcpy(d_A, matrix->A, memCudaDataMatrixSize, cudaMemcpyHostToDevice) == cudaSuccess);
  assert(cudaMemcpy(d_B, matrix->B, memCudaDataVectorSize, cudaMemcpyHostToDevice) == cudaSuccess);

  assert(cudaMemset(d_X0, 0x00, memCudaDataVectorSize) == cudaSuccess);
  assert(cudaMemset(d_X1, 0x00, memCudaDataVectorSize) == cudaSuccess);

  if (matrix->mn < MAXTHREADS){
    blocks = 1;
    threads = matrix->mn;
  }else{
    blocks = matrix->mn / MAXTHREADS;
  }

  do{
        
        //JacobiMethodKernel_A<<<blocks, threads >>> (d_A, d_X1, d_X0, d_B, d_Err, matrix->mn);       //Here, the kernel is called  by the main program!
        JacobiMethodKernel_B<<<blocks, threads, threads * sizeof(double) >>> (d_A, d_X1, d_X0, d_B, d_Err, matrix->mn);       //Here, the kernel is called  by the main program!
        assert(cudaDeviceSynchronize() == cudaSuccess);

        findMax<<<1, threads, threads * sizeof(double)>>> (d_Err, blocks);       //Here, the kernel is called  by the main program!
        assert(cudaDeviceSynchronize() == cudaSuccess);

        assert(cudaMemcpy(&h_err, d_Err, sizeof(double), cudaMemcpyDeviceToHost) == cudaSuccess);

        double *swap = d_X0;
        d_X0 = d_X1;
        d_X1 = swap; 
        inter++;

  }while (h_err > ERROR);
  printf("\n%18.16lf %d\n", h_err, inter);

  assert(cudaMemcpy(matrix->X0, d_X0, memCudaDataVectorSize, cudaMemcpyDeviceToHost) == cudaSuccess);

  cudaFree(d_A);
  cudaFree(d_X1);
  cudaFree(d_X0);
  cudaFree(d_B);
  cudaFree(d_Err);



}

/*
 *
 */
void JacobiMethodCPU(tpMatrix *matrix){

   double aux, 
         div, 
         err = 0.0;
   int inter = 0;
   
   do{
         for (int j = 0; j < matrix->mn; j++){
            aux    = 0.0;
            div    = 0.0;
            
            for (int i = 0; i < matrix->mn; i++){
              if (j != i)
//                  aux += ((matrix->A[matrix->mn * j + i] * matrix->X0[i]) * -1.0);
                  aux += (matrix->A[matrix->mn * j + i] * matrix->X0[i]);
               else
                  div =  matrix->A[matrix->mn * j + i];
            }
            matrix->X1[j] = ((matrix->B[j] - aux) / div );
         }

         err = fabs((matrix->X1[0] - matrix->X0[0]) / (matrix->X1[0] + EPSILON));
         for (int j = 1; j < matrix->mn; j++){
            double b = fabs((matrix->X1[j] - matrix->X0[j]) / (matrix->X1[j] + EPSILON));
             err = max(err, b);   
         }

         double *swap = matrix->X0;
         matrix->X0 = matrix->X1;
         matrix->X1 = swap; 
         inter++;
   
       
   }while (err > ERROR);
   printf("\n%18.16lf %d\n", err, inter);

}
/*
 *
 */
void PrintX(double *X, const int size){
  FILE *ptr = fopen("solucao.txt", "w+");
  assert(ptr != NULL);
  for (int i = 0; i < size; i++){
    fprintf(ptr, "%20.15lf ", X[i]);
  }
  fprintf(ptr, "\n");
  fclose(ptr);
}


