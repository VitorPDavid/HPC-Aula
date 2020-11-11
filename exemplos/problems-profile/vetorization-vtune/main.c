#include <stdio.h>
#include <stdlib.h>
#include "App.h"

/* Funções declaradas em arquivos externos */
void add_no_optimization_d(double * __restrict__ C, double * __restrict__ A, double * __restrict__ B, unsigned int elements);
void add_implicitly_optimization_d(double * __restrict__ C, double * __restrict__ A, double * __restrict__ B, unsigned int elements);
void add_explicitly_optimization_d(double * __restrict__ C, double * __restrict__ A, double * __restrict__ B, unsigned int elements);
void add_explicitly_optimization_2_cores_d(double * __restrict__ C, double * __restrict__ A, double * __restrict__ B, unsigned int elements);
void add_explicitly_optimization_4_cores_d(double * __restrict__ C, double * __restrict__ A, double * __restrict__ B, unsigned int elements);
void add_explicitly_optimization_8_cores_d(double * __restrict__ C, double * __restrict__ A, double * __restrict__ B, unsigned int elements);


void teste(int ac, char **av){
  //char *fileName = "log_d.txt";  
  unsigned int memory = atoi(av[1]) * 1024 * 1024,
                    i = 0,
                    elements = memory / sizeof(double);
    //int save_output = atoi(av[2]);
    double *A = NULL,
           *B = NULL,
           *C = NULL;
    
    fprintf(stdout, "\tTamanho do array: [%15u] \n", elements);
    fprintf(stdout, "\t Memoria alocada: [%15u] Mbytes (3 vetores) \n", (3 * memory) /1024/1024);

    posix_memalign((void**)&A, 64, memory);
    posix_memalign((void**)&B, 64, memory);
    posix_memalign((void**)&C, 64, memory);

    for (  i = 0; i < elements; i++){
        B[i] = (float) ((i+256) % 127) / 100.0f;
        A[i] = B[i];
        C[i] = 0.0f;
    }
    
    
    add_explicitly_optimization_4_cores_d(C, A, B, elements/4);
    
    
    free(A);
    free(B);
    free(C);
}

int main(int ac, char **av){
    fprintf(stdout, "\nExercicio de vetorizacao\n");
    fprintf(stdout, "Alocacao de memoria alinhada em 16bytes\n");
    teste(ac, av);
    
}
