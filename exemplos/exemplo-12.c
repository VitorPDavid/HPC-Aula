#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <unistd.h>
#include <string.h>
#define SIZE 32

void computeVetor(int *vet, int size){
    int nsize = size / omp_get_num_threads();
    int v = omp_get_thread_num();
    int a = v * nsize;
    int b = v * nsize + nsize - 1;
    //fprintf(stdout, "Thread %d vet[%d:%d] %d\n", v, a, b, nsize);


    //#pragma omp barrier

    if (nsize > 4){
      #pragma omp single
      {
        //fprintf(stdout, "------------------------\n");
        omp_set_num_threads(omp_get_num_threads() * 2);
        #pragma omp parallel
        {
          computeVetor(vet, size);
        }//end-#pragma omp parallel
      }//end-#pragma omp single
    }else {
      for (int i = a; i <= b ; i++){
        vet[i] = v;
      }//end-for (int i = a; i <= b ; i++){
    }//end-if (nsize > 4){

}

int main (int ac, char **av){
  int vet[SIZE];
  bzero(vet, sizeof(int) * SIZE);
  omp_set_nested(1); //permite que threads criem threads
  omp_set_max_active_levels(8); // número máximo de criação de threads
  omp_set_dynamic(0); //Desabilita o ajuste dinâmico das threads
  omp_set_num_threads(2); //Indica a quantidade e threads
  #pragma omp parallel
  {
      computeVetor(vet, SIZE);
  }//end-#pragma omp parallel

  fprintf(stdout, "------------------------\n");
  for (int i = 0; i < SIZE; i++){
    fprintf(stdout, "OUT: vet[%.2d] = %d\n", i, vet[i]);
  }
  return EXIT_SUCCESS;
}

