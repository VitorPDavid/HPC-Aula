#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <unistd.h>
#include <string.h>
void funcaoA(int id){
  fprintf(stdout, "Hello %d at %s \n", id, __func__);
}

void funcaoB(int id){
  fprintf(stdout, "Hello %d at %s \n", id, __func__);
}

void funcaoC(int id){
  fprintf(stdout, "Hello %d at %s \n", id, __func__);
}


int main (int ac, char **av){

  #pragma omp parallel sections
  {
      #pragma omp section
        funcaoA(omp_get_thread_num());

      #pragma omp section
        funcaoB(omp_get_thread_num());

      #pragma omp section
        funcaoC(omp_get_thread_num());


  }//end-#pragma omp parallel
  return EXIT_SUCCESS;
}
