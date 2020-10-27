#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <unistd.h>
#include <string.h>
#define SIZE 1000

void printInfo1(int id){
  fprintf(stdout, "1: I'm %d of %d \n" , id+1, omp_get_num_threads());
  usleep(1000);
}
void printInfo2(int id){
  fprintf(stdout, "2: I'm %d of %d \n" , id+1, omp_get_num_threads());
  usleep(1000);
}

int main (int ac, char **av){
  omp_set_nested(1); //permite que threads criem threads
  omp_set_max_active_levels(8); //limita o número de nested
  omp_set_dynamic(0); //Desabilita o ajuste dinâmico das threads
  omp_set_num_threads(2); //Indica a quantidade e threads
  #pragma omp parallel
  {

    #pragma omp single
    {
      printInfo1(omp_get_thread_num());
      omp_set_num_threads(4); //Indica a quantidade e threads
      #pragma omp parallel
      {
        #pragma omp single
        {
          printInfo1(omp_get_thread_num());
        }
      }//end-#pragma omp parallel
    }//end-#pragma omp single

    #pragma omp barrier
    #pragma omp single
    {
      printInfo2(omp_get_thread_num());
    }//end-#pragma omp single

  }//end-#pragma omp parallel

  return EXIT_SUCCESS;
}

