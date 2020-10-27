//compute the sum of two arrays in parallel
#include <stdio.h>
#include <omp.h>
#include <math.h>

double func(double x){
//    return x * x;
    return pow(x, 2.0);
}
int main(void) {
  double h = 0.000000001,
         k = h / 2,
         x = 0.0,
         sum = 0.0;
  int steps = (int) 1.0/h,
      i = 0;
  fprintf(stdout, "Steps: %d\n", steps);

  #pragma omp parallel shared(sum, steps, h, k) private (i, x)
  {
      #pragma omp for reduction(+:sum)
      for (i = 0; i <= steps; i++){
          double offset = h * (double) i;
          double aux = 2.0 * k;
          if ((i == 0) || (i == steps))
              aux = k;
          sum += (func(x + offset) * aux);
      }
  }
  fprintf(stdout, "I = %lf\n", sum);

  return 0;
}
