#include <iostream>
#include <cstdlib>
#include <cstring>
#include <cuda_runtime.h>
using namespace std;
__global__ void AddVet(int *c, int *a, int *b){
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    c[idx] = a[idx] + b[idx];
    
}
int main (int argc, char **argv){
    //C = A + B -> Objetivo do código é somar vetores de inteiros
    
    int h_vetS = 16;
    
    int *h_A = NULL;
    int *h_B = NULL;
    int *h_C = NULL;
    
    int *d_A = NULL;
    int *d_B = NULL;
    int *d_C = NULL;
    
    
    h_A = new int [h_vetS];
    h_B = new int [h_vetS];
    h_C = new int [h_vetS]; 
    
    cudaDeviceReset();
    
    cudaMalloc((void**)&d_A, sizeof(int) * h_vetS);
    cudaMalloc((void**)&d_B, sizeof(int) * h_vetS);
    cudaMalloc((void**)&d_C, sizeof(int) * h_vetS);
    
    //Inicializando as variáveis
    for (int  i = 0 ; i < h_vetS; i++){
        h_A[i] = i + 1;
        h_B[i] = (i + 1) * 10;
        h_C[i] = 0;
    }
    
    //Cópia host -> device
    cudaMemcpy(d_A, h_A, sizeof(int) * h_vetS, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, sizeof(int) * h_vetS, cudaMemcpyHostToDevice);
    
    
    
    AddVet<<<2, 8>>>(d_C, d_A, d_B);
    
    //Código sequencial
/*
    for (int  i = 0 ; i < h_vetS; i++){
        h_C[i] = h_A[i] + h_B[i];
        ~
    }
  */  
    //Cópia device -> host
    cudaMemcpy(h_C, d_C, sizeof(int) * h_vetS, cudaMemcpyDeviceToHost);
    
    //Exibir resultado
    for (int  i = 0 ; i < h_vetS; i++){
        cout << "i = " << i << " h_C[i] = " << h_C[i] << endl;
        
    }
    
    delete[] h_A;
    delete[] h_B;
    delete[] h_C;
    
    return EXIT_SUCCESS;
}
