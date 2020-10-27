#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <unistd.h>
#include <string.h>
#define SIZE 1000

int main (int ac, char **av){
    int flag = 0;
    int vet[SIZE];
    bzero(vet, SIZE * sizeof(int));
#ifdef _OPENMP
  printf("Compilado com diretive OpenMP\n");
#endif
    printf("Produtor e consumidor - versão 1");
    #pragma omp parallel num_threads(2)
    {
        if(omp_get_thread_num()==0){
            while(1){
              printf("Produtor\n");
              for (int i = 0; i < SIZE; i++){
                if (vet[i] != 0){
                  fprintf(stderr, "Error\n");
                  exit(EXIT_FAILURE);
                }
                vet[i] = 42;
              }


              usleep(1000000);
              #pragma omp atomic update
              flag++;

              #pragma omp flush(flag)
              while(flag == 1){
                  #pragma omp flush(flag)
              }
            }

            /* Flush of flag is implied by the atomic directive */
        }else if(omp_get_thread_num()==1){
            while(1){
              #pragma omp flush(flag)
              while(flag == 0){
                  #pragma omp flush(flag)
              }
              printf("Consumidor\n");
              for (int i = 0; i < SIZE; i++){
                //printf("\tconsumindo %d -> %d \n", i, vet[i]);
                vet[i] = 0;
              }
              usleep(1000000);
              #pragma omp atomic update
              flag--;
            }

              /* Flush of flag is implied by the atomic directive */
        }
  }
  return EXIT_SUCCESS;
}

