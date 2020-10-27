#if !defined(_KERNEL_CU_)
#define _KERNEL_CU_
#include <iostream>
#include <veiculos.cu>


__global__ 
void meuKernel( Veiculo *vet ){

   int indice = blockDim.x * blockIdx.x + threadIdx.x;
   
   if (threadIdx.x == 0)
      vet[indice] = Carro(indice);
   else
      vet[indice] = Onibus(indice);
}



void ExecKernel(int blocos, int threads, Veiculo *vet){
   meuKernel<<<blocos, threads>>> (vet);

}
#endif
