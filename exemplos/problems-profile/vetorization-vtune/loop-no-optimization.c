#include <math.h>
void add_no_optimization_d(double * __restrict__ C, double * __restrict__ A, double * __restrict__ B, unsigned int elements){
    unsigned int i = 0;
    for ( i  = 0; i < elements; i++){
        C[i] = A[i] + B[i];
        C[i] = C[i] * A[i];
        C[i] = sqrt(C[i]);
    }

}