#include <cstdlib>
#include <cmath>
#include <vector>
#include <cstdio>
#include <iostream>
#include <cuda.h>
#include <cuda_runtime.h>
#include <cassert>
#include <veiculos.cu>
using namespace std;
#define CHECK_ERROR(call) do {                                                    \
if( cudaSuccess != call) {                                                             \
std::cerr << std::endl << "CUDA ERRO: " <<                             \
cudaGetErrorString(call) <<  " in file: " << __FILE__                \
<< " in line: " << __LINE__ << std::endl;                               \
exit(0);                                                                                 \
} } while (0)


void ExecKernel(int blocos, int threads, Veiculo *vet);
int main(int argc, char *argv[]){
   
   int dominio = 16,
        blocos    = 4,
        threads  = dominio / blocos;
   
   std::vector <Veiculo> h_vet;
   Veiculo    *d_Vet  = NULL;

   size_t free = 0,
            total = 0;
   
   cudaDeviceProp deviceProp;                   //Levantar a capacidade do device
   cudaGetDeviceProperties(&deviceProp, 0);

   cout << "Trabalhando com classes em CUDA" << endl;
   CHECK_ERROR(cudaDeviceReset());
   
   //Verificando espaço livre em memória
   CHECK_ERROR(cudaMemGetInfo(&free, &total));
   cout << "Memoria livre: " << (free / 1024 / 1024)   << " MB\n";
   cout << "Memoria total: " << (total / 1024 / 1024)  << " MB\n";
   
   //Allocating memories
   h_vet.resize(dominio);
   CHECK_ERROR( cudaMalloc(reinterpret_cast<void**> (&d_Vet), dominio * sizeof(Veiculo)) );
   
   
    
   cout << "Blocos: " << blocos << endl;
   cout << "Threads: " << threads << endl;
   
   assert( threads <= deviceProp.maxThreadsDim[0]);
   ExecKernel(blocos, threads, d_Vet);
   CHECK_ERROR(cudaDeviceSynchronize());
   
   CHECK_ERROR( cudaMemcpy(&(h_vet[0]), d_Vet, dominio * sizeof(Veiculo),  cudaMemcpyDeviceToHost) ); 
   
   for (int i = 0; i < h_vet.size(); i++){
      cout << i << " " << h_vet[i].ID << " " << h_vet[i].x  << " " << h_vet[i].y  << " " << h_vet[i].tam  << " " << h_vet[i].vMax;
      if (h_vet[i].tam == 7)
         cout << " *";
      cout << endl;
   }
   
   cudaFree(d_Vet);

   
   return EXIT_SUCCESS;
}

