//compute the sum of two arrays in parallel
#include <stdio.h>
#include <omp.h>
#define N 12
int main(int ac, char **av) {
  float a[N], b[N], c[N];
  int i;

  /* Initialize arrays a and b */
  for (i = 0; i < N; i++) {
    a[i] = i * 2.0;
    b[i] = i * 3.0;
  }

 /* Compute values of array c = a+b in parallel. */
  #pragma omp parallel num_threads(2) shared(a, b, c) private(i)
  {
    #pragma omp single
      printf("Eu sou a thread %d ... inicio da região paralela ... número de threads = %d\n", omp_get_thread_num(), omp_get_num_threads());
    //#pragma omp parallel for
    #pragma omp for
    for (i = 0; i < N; i++) {
      c[i] = a[i] + b[i];
      printf("Thread %d executa a iteracao %d do loop\n",omp_get_thread_num(),i);
    }//end-for (i = 0; i < N; i++) {
  }//end-#pragma omp parallel shared(a, b, c) private(i)

  return 0;
}






