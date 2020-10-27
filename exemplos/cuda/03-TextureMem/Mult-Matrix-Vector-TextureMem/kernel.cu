/*
 *************************************************************************
   unsigned int width = gridDim.x * blockDim.x;
   unsigned int height = gridDim.y * blockDim.y;
   unsigned int x = blockDim.x * blockIdx.x + threadIdx.x;
   unsigned int y = blockDim.y * blockIdx.y + threadIdx.y;
   unsigned int kn = y * width + x;
 *************************************************************************
*/

#include <stdio.h>
#include <GPU.h>
#include <App.h>

//Essas variáveis só podem ser globais!!!!
texture<float, 2>     mTexRef; 
cudaChannelFormatDesc mChannelDesc = cudaCreateChannelDesc<float>();
cudaArray            *mCUMatrizA = NULL;

__global__ 
void kernel (float *vetorB,
             float *vetorA,
             const int colunas,
             const int linhas)
{
    //unsigned int m  = blockDim.x * blockIdx.x + threadIdx.x;
    unsigned int n  = blockDim.y * blockIdx.y + threadIdx.y;
    unsigned int m = 0;

   // float4 fx = tex2D(mTexRef, x, y );
    //unsigned int n  = blockDim.y * blockIdx.y + threadIdx.y;
    //unsigned int mn = n * width + m;
    vetorB[n] = 0.0f ; //tex2D(mTexRef, 6, 1 ) ;

    for (m = 0; m < colunas; m++)
        vetorB[n] += tex2D(mTexRef, m, n ) * vetorA[m];

    
}
//----------------------------------------------------------------------------------------------------

extern "C" void multiplicaMatrizVetor(float *vetorB,
                                      float *MatrizA,
                                      float *vetorA,
                                      int colunas,
                                      int linhas)
{
    dim3         dGrid,
                 dThreads;

    unsigned int uMemMatrizA  = sizeof(float) * colunas * linhas,
                 uMemVetorA   = sizeof(float) * colunas,
                 uMemVetorB   = sizeof(float) * linhas;

    float        *fGPUVetorB  = NULL,
                 *fGPUVetorA  = NULL;

    Stopwatch sMemoria,
              sGPU;

    dGrid.x = 1;       //BLOCK_SIZE;
    dGrid.y = BLOCK_SIZE;
    dGrid.z = 1;

    dThreads.x = 1;   //colunas / BLOCK_SIZE;
    dThreads.y = linhas  / BLOCK_SIZE;
    dThreads.z = 1;

    FREQUENCY(sMemoria);
    FREQUENCY(sGPU);

    START_STOPWATCH(sMemoria);
    //Aloca memória na GPU
    CHECK_ERROR(cudaMallocArray(&mCUMatrizA, &mChannelDesc, colunas, linhas));

    CHECK_ERROR(cudaMalloc((void**) &fGPUVetorA, uMemVetorA));
    CHECK_ERROR(cudaMalloc((void**) &fGPUVetorB, uMemVetorB));

    //Copiando dados CPU --> GPU
    CHECK_ERROR(cudaMemcpyToArray(mCUMatrizA, 0, 0, MatrizA, uMemMatrizA, cudaMemcpyHostToDevice));

    CHECK_ERROR(cudaMemcpy( fGPUVetorA,  vetorA,  uMemVetorA, cudaMemcpyHostToDevice));

    CHECK_ERROR(cudaBindTextureToArray(mTexRef, mCUMatrizA));   //Bind da textura

    START_STOPWATCH(sGPU)
    kernel<<<dGrid, dThreads>>>
                            (fGPUVetorB,  fGPUVetorA, colunas, linhas);
    CHECK_ERROR(cudaThreadSynchronize());
    STOP_STOPWATCH(sGPU);

    CHECK_ERROR(cudaUnbindTexture(mTexRef));                    //Unbind da textura

    CHECK_ERROR(cudaMemcpy(vetorB, fGPUVetorB, uMemVetorB, cudaMemcpyDeviceToHost));



    //Desaloca a memória
    CHECK_ERROR(cudaFreeArray(mCUMatrizA));
    CHECK_ERROR(cudaFree(fGPUVetorA));
    CHECK_ERROR(cudaFree(fGPUVetorB));
    STOP_STOPWATCH(sMemoria);

    sMemoria.mElapsedTime -= sGPU.mElapsedTime;

    fprintf(stdout, "\n");
    fprintf(stdout, "\nTotal de memoria alocada na GPU: %u bytes", uMemMatrizA + uMemVetorA +  uMemVetorB);
    fprintf(stdout, "\n            Tempo gasto no processamento: %.4lf (ms) ", sGPU.mElapsedTime);
    fprintf(stdout, "\nTempo gasto com alocacao / copia de mem.: %.4lf (ms) ", sMemoria.mElapsedTime);
    fprintf(stdout, "\n                    Total de tempo gasto: %.4lf (ms) ", sMemoria.mElapsedTime + sGPU.mElapsedTime);
    fprintf(stdout, "\n");


    

}

