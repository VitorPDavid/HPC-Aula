    //nvcc -arch=sm_11 -m64 -O3 main.cu -o stream.bin


#include<iostream>
#include<cstdlib>
#include <cuda_runtime.h>
#include <cassert>
#include <curand_kernel.h>
#include <curand.h>
#include <ctime>


#define DOMINO 4096
#define BLOCOS        8
#define STREAM        4

#define CHECK_ERROR(call) do {                                                    \
   if( cudaSuccess != call) {                                                             \
      std::cerr << std::endl << "CUDA ERRO: " <<                             \
         cudaGetErrorString(call) <<  " in file: " << __FILE__                \
         << " in line: " << __LINE__ << std::endl;                               \
         exit(0);                                                                                 \
   } } while (0)


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
__global__ void setup_kernel(const unsigned long long seed,  curandState *state){
   int x      = blockDim.x * blockIdx.x + threadIdx.x;

   curand_init(seed, x, 0, &state[x]);
}

__global__ void uniform_kernel(curandState *state, float *h_y){
   
   
     int x      = blockDim.x * blockIdx.x + threadIdx.x;


    h_y[x] =  curand_uniform(&state[x]);
    
    

}




using namespace std;
int main (int argc, char **argv){


   cudaEvent_t e_Start,
                      e_Stop;

   cudaEvent_t e_StartS,
                      e_StopS;
 
   curandState       *mStates = NULL;
   
   cudaStream_t     *mStreams = NULL;

   float  *h_Mem    = NULL,
           *d_Mem  = NULL;

   
   float elapsedTime = 0.0f,
          elapsedTimeStream = 0.0f,
          acc = 0.0f;
   
   int dominio = DOMINO,
        subdominio = DOMINO / STREAM;
        
   unsigned int qtdeDados = DOMINO * sizeof(float);

                      
   size_t free = 0,
            total = 0;
   
   cudaDeviceProp deviceProp;                   //Levantar a capacidade do device
   cudaGetDeviceProperties(&deviceProp, 0);
   
   
   cout << "\nStream de numeros aleatorios\n";
   
   CHECK_ERROR(cudaMemGetInfo(&free, &total));
   cout << "Memoria livre: " << (free / 1024 / 1024)   << " MB\n";
   cout << "Memoria total: " << (total / 1024 / 1024)  << " MB\n";
   cout << "Dominio: " << dominio << endl;
   

     //Reset no device
   CHECK_ERROR(cudaDeviceReset());

         //Criando eventos
   CHECK_ERROR(cudaEventCreate(&e_Start));
   CHECK_ERROR(cudaEventCreate(&e_Stop));

   CHECK_ERROR(cudaEventCreate(&e_StartS));
   CHECK_ERROR(cudaEventCreate(&e_StopS));

  mStreams = new cudaStream_t[STREAM];
   
   for (int i = 0; i < STREAM; i++)
      CHECK_ERROR(cudaStreamCreate(&mStreams[i]));

   //Alocando memoria CPU "no-swap"
   CHECK_ERROR(cudaMallocHost(reinterpret_cast<void**> (&h_Mem), qtdeDados));
   
   //alocando memória em GPU
   CHECK_ERROR(cudaMalloc(reinterpret_cast<void**> (&d_Mem), qtdeDados));
   CHECK_ERROR(cudaMalloc(reinterpret_cast<void**> (&mStates), dominio * sizeof(curandState)));
  
   int blocos = BLOCOS,
        threads = subdominio / BLOCOS;
         
   cout << "Blocos: " << blocos << endl;
   cout << "Threads: " << threads << endl;
   
   assert( threads <= deviceProp.maxThreadsDim[0]);
   
   CHECK_ERROR(cudaEventRecord(e_Start, cudaEventDefault));
   
    for (int i = 0; i < STREAM; i++){
      CHECK_ERROR(cudaEventRecord(e_StartS, mStreams[i]));
      int offset = subdominio * i;
      
      
      setup_kernel<<<blocos, threads,0, mStreams[i] >>>(time (NULL) + offset, mStates+offset);
      uniform_kernel<<<blocos, threads,0, mStreams[i]>>>(mStates+offset, d_Mem + offset);
      CHECK_ERROR(cudaMemcpyAsync(h_Mem + offset, d_Mem + offset, subdominio * sizeof(float), cudaMemcpyDeviceToHost, mStreams[i] ));
      
   }

   for (int i = 0; i < STREAM; i++){
      CHECK_ERROR( cudaStreamSynchronize(mStreams[i]) );
      CHECK_ERROR(cudaEventRecord(e_StopS, mStreams[i]));
      CHECK_ERROR(cudaEventSynchronize(e_StopS));
      CHECK_ERROR(cudaEventElapsedTime(&elapsedTimeStream, e_StartS, e_StopS));
      cout << "Stream: " << i << " tempo: " << (elapsedTimeStream / 1000.0f) << " (s) \n";
      acc += elapsedTimeStream;

   }
   cout << "Acumulado: " << acc / 1000.0f << " (s) \n";

   CHECK_ERROR(cudaEventRecord(e_Stop, cudaEventDefault));
   CHECK_ERROR(cudaEventSynchronize(e_Stop));
   CHECK_ERROR(cudaEventElapsedTime(&elapsedTime, e_Start, e_Stop));
   
   cout << "Tempo: " << elapsedTime / 1000.0f << " (s) \n";
   cout <<  endl << "Resultado: "<<  endl;
   for (int i = 0; i < dominio; i++)
         cerr << h_Mem[i]<< endl;
   cerr << endl;
  
   CHECK_ERROR( cudaFree(mStates) ); 
   CHECK_ERROR( cudaFreeHost(h_Mem) );  //Liberando memorias GPU e CPU
   CHECK_ERROR( cudaFree(d_Mem) );  //Liberando memorias GPU e CPU
  //  for (int i = 0; i < STREAM; i++)
    //  CHECK_ERROR( cudaStreamDestroy(mStreams[i]) );
   
   delete mStreams;
   CHECK_ERROR( cudaEventDestroy (e_Start)  );
   CHECK_ERROR( cudaEventDestroy (e_Stop)  );
   CHECK_ERROR( cudaEventDestroy (e_StartS)  );
   CHECK_ERROR( cudaEventDestroy (e_StopS)  );

   cout << "\nFIM\n";
   return EXIT_SUCCESS;
}
