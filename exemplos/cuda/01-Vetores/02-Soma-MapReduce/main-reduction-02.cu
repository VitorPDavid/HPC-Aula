#include <iostream>
#include <cstdlib>
#include <cstring>
#include <cuda_runtime.h>
#include <cstdio>
#include "App.h"

#define CHECK_ERROR(call) do {                                                    \
   if( cudaSuccess != call) {                                                             \
      std::cerr << std::endl << "CUDA ERRO: " <<                             \
         cudaGetErrorString(call) <<  " in file: " << __FILE__                \
         << " in line: " << __LINE__ << std::endl;                               \
         exit(0);                                                                                 \
   } } while (0)


using namespace std;

__global__ void Soma(float *vet, const int offset){
	int i = blockIdx.x * blockDim.x + threadIdx.x;

	int a = offset*i;
	int b = a+(offset/2);
	float v = vet[a] + vet[b];
	vet[a] = v;



}
__global__  void Soma2(float *b, float *a){

   extern __shared__ float partialSum[];

    int t = threadIdx.x;

   partialSum[t] = a[t];
   __syncthreads();


   for (unsigned int stride = blockDim.x >> 1; stride > 0; stride >>= 1){
      __syncthreads();
      if (t % (2* (stride)) == 0)
        partialSum[t] += partialSum[t+stride];
   }

   __syncthreads();
   if (threadIdx.x  == 0)
      b[t] = partialSum[t];


}

__global__  void Soma1(float *b, float *a){

   extern __shared__ float partialSum[];

   int t = threadIdx.x;

   partialSum[t] = a[t];
   __syncthreads();

   for (unsigned int stride = 1; stride < blockDim.x; stride *=2){
      __syncthreads();
      if (t % (2* (stride)) == 0)
        partialSum[t] += partialSum[t+stride];
   }

   __syncthreads();
   if (threadIdx.x  == 0)
      b[t] = partialSum[t];


}

int main (int argc, char **argv){
   int h_Size = 16;

   float   *h_VetA = NULL,
           *d_VetA = NULL;


   Stopwatch sw;

   size_t free = 0,
          total = 0;
   cout << endl << "CUDA runtime versao: " << CUDART_VERSION << endl;

   //Reset no device
   CHECK_ERROR(cudaDeviceReset());

   //Verificando espaço livre em memória
   CHECK_ERROR(cudaMemGetInfo(&free, &total));
   cout << "Memoria livre: " << (free / 1024 / 1024)   << " MB\n";
   cout << "Memoria total: " << (total / 1024 / 1024)  << " MB\n";




   //Aloca memória GPU
   CHECK_ERROR(cudaMalloc((void**) &d_VetA, h_Size * sizeof(float)));



   //Alocando memória na CPU
   h_VetA = new float [h_Size];


   //Preenchendo vetores
   for (int i = 0; i < h_Size; i++){
      h_VetA[i] = static_cast <float> (i+1);
      cout << h_VetA[i] << " ";
   }
   cout << endl;

   FREQUENCY(sw);

   START_STOPWATCH(sw);
   //Copiando CPU --> GPU
   CHECK_ERROR(cudaMemcpy(d_VetA, h_VetA, h_Size * sizeof(float),  cudaMemcpyHostToDevice));


   int numBlocks = 1;
   int threadsPerBlock = 4;
/*
   h_Size = 131072;
   int j = 1024;
   int i = 2;
   int l = 1;
      for (int k = 32; k > 0; k >>=1){
		   for (int j = 0; j < k; j++)
			   cout << i*j << ", " << i*j+l << endl;
	   i <<=1;
	   l <<= 1;
	   cout << "----" << endl;
	   cin.get();
      }


   exit(-1);
*/


	cout << "Blocos/threads : " << numBlocks << "," << threadsPerBlock << endl;

	int offSet = 2;
	for (int i = h_Size/2; i > 0; i>>=1){
		threadsPerBlock = i;
		Soma <<< numBlocks, threadsPerBlock >>> (d_VetA, offSet);
		offSet <<= 1;
		CHECK_ERROR(cudaDeviceSynchronize());
		printf("\n");


	}



   /*
   //for (int i = 0; i < 2 ; i++){
	  Soma1<<<numBlocks, threadsPerBlock,  threadsPerBlock * sizeof(float) >>> (d_VetB, d_VetA);
	  CHECK_ERROR(cudaDeviceSynchronize());
	 //
  // }
*/

   CHECK_ERROR(cudaMemcpy(h_VetA, d_VetA, h_Size * sizeof(float),  cudaMemcpyDeviceToHost));
   STOP_STOPWATCH(sw);

   cout << endl << "Tempo gasto [GPU+MEM]: " << sw.mElapsedTime << " (ms)" << endl;

   cout <<  endl << "Resultado: "<<  endl;

/*
   for (int i = 0; i < h_Size; i++)
      cout << h_VetA[i] << endl;
*/
      cout << h_VetA[0] << endl;


   CHECK_ERROR(cudaFree(d_VetA));  //Liberando memorias GPU e CPU

   delete[] h_VetA;


   cout << "FIM" << endl;

   return EXIT_SUCCESS;
}
