#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <unistd.h>
#include <string.h>
#include <assert.h>
#define SIZE 1000
void produtor (int *vet, int size){
  printf("Produtor\n");
  for (int i = 0; i < SIZE; i++){
    assert(vet[i] == 0);
    vet[i] = 42;
  }
}

void consumidor (int *vet, int size, int tid){
  fprintf(stdout, "Consumidor %d\n", tid); fflush(stdout);
  for (int i = 0; i < SIZE; i++){
    //printf("\tconsumindo %d -> %d \n", i, vet[i]);
    if (vet[i] !=42){
      fprintf(stderr, "ERROR thread(%d) i(%d)\n", tid, i);
      exit(EXIT_FAILURE);
    }
    vet[i] = 0;
  }
}

int main (int ac, char **av){
    int flag = 0, flagc = 0;
    int vet[SIZE];
    bzero(vet, SIZE * sizeof(int));
#ifdef _OPENMP
  printf("Compilado com diretive OpenMP\n");
#endif
    printf("Produtor e consumidor - versão 1\n\n");
    #pragma omp parallel num_threads(8)
    {
        if(omp_get_thread_num()==0){
          while(1){
            produtor(vet, SIZE);
           
            #pragma omp atomic update
            flag++;

            #pragma omp flush(flag)
            while(flag == 1){
              #pragma omp flush(flag)
            }
          }
        }else if(omp_get_thread_num() > 0){
            while(1){

                    #pragma omp critical
                    {
                      if (flagc == 0)
                        flagc = omp_get_thread_num();      
                    }
                    

                    #pragma omp flush(flagc)
                    if (flagc == omp_get_thread_num()){

                        #pragma omp flush(flag)
                        while(flag == 0){
                          #pragma omp flush(flag)
                        }
                        consumidor(vet, SIZE, omp_get_thread_num());
                        usleep(omp_get_thread_num());
                        #pragma omp atomic update
                        flag--;

                        #pragma omp critical
                        flagc = 0;

                    
                    }
                    while(flagc != 0){
                      #pragma omp flush(flagc)
                    }
                    
                    

            }//end-while(1){
        }//end-}else if(omp_get_thread_num() > 0){
  }
  return EXIT_SUCCESS;
}

