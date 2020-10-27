#include <stdio.h>
#include <omp.h>
int main (void){
  int th_id, nthreads, flag = -1 ;
#pragma omp parallel private(th_id, nthreads) shared(flag)
{
   th_id = omp_get_thread_num();
   printf("Hello World from thread %d\n", th_id);
#pragma omp barrier
   if ( th_id == 0 ) {
      nthreads = omp_get_num_threads();

   }
#pragma omp barrier
  if ( th_id == 1 ) {
     printf("There are %d threads\n",nthreads);
  }
#pragma omp barrier
#pragma omp single
  flag = th_id;



}//#pragma omp parallel private(th_id) {
  printf("First private: %d \n", flag);
  return 0;
}
/*
Atenção para o escopo. Se dentro do #pragma então é private. Se declarada fora, então
é shared.

*/
