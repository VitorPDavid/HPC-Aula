//compute the sum of two arrays in parallel
#include <stdio.h>
#include <omp.h>
#define N 100000
int main(void) {
  float a[N], b[N], c[N];
  float sum = 0.0;
  int i;

  /* Initialize arrays a and b */
  for (i = 0; i < N; i++) {
    a[i] = i * 2.0 + 1;
    b[i] = i * 3.0;
    c[i] =  a[i] * 0.01;
  }


  /* Compute values of array c = a+b in parallel. */
  #pragma omp parallel shared(a, b, c, sum) private(i)
  {
    #pragma omp for reduction(+:sum)
    for (i = 0; i < N; i++) {
      sum += a[i] + b[i] + c[i];
    }
  }

  printf("Sum = %f\n", sum);
}
