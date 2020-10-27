//compute the sum of two arrays in parallel
#include <stdio.h>
#include <omp.h>
#define N 10000
int main(void) {
  float a[N], b[N], c[N];
  int i;

  /* Initialize arrays a and b */
  for (i = 0; i < N; i++) {
    a[i] = i * 2.0;
    b[i] = i * 3.0;
  }

 /* Compute values of array c = a+b in parallel. */
  #pragma omp parallel  shared(a, b, c) private(i)
  {
    #pragma omp for
    for (i = 0; i < N; i++) {
      c[i] = a[i] + b[i];
    }

    #pragma omp for
    for (i = 0; i < n; i++){
        aux_dot += a[i]*b[i];
    }
    #pragma omp critical
        dot += aux_dot;
  }

}


/*
#pragma omp parallel{
    #pragma omp for
    for (i = 0; i < n; i++){
        aux_dot += a[i]*b[i];
    }
    #pragma omp critical
        dot += aux_dot;
    }
}
*/
