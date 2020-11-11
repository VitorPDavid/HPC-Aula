#include <math.h>
#include <immintrin.h>
#include <omp.h>
void add_explicitly_optimization_2_cores_d(double * __restrict__ C, double * __restrict__ A, double * __restrict__ B, unsigned int elements){
    unsigned int i = 0;
    __m256d vec_A, vec_B, vec_C;
    int coreElements = elements / 2;
    #pragma omp parallel num_threads(2)
    {
        #pragma omp for
        for ( i = 0; i < coreElements; i+= 4){
            int offset = omp_get_thread_num() * coreElements;
            vec_A = _mm256_load_pd(A + i + offset);
            vec_B = _mm256_load_pd(B + i + offset);
            vec_C = _mm256_add_pd(vec_A, vec_B);
            vec_C = _mm256_mul_pd(vec_C, vec_A);
            vec_C = _mm256_sqrt_pd(vec_C);
            _mm256_store_pd(C + i  + offset, vec_C);
        }

    }
}

void add_explicitly_optimization_4_cores_d(double * __restrict__ C, double * __restrict__ A, double * __restrict__ B, unsigned int elements){
    unsigned int i = 0;
    __m256d vec_A, vec_B, vec_C;
    int coreElements = elements / 4;
#pragma omp parallel num_threads(4)
    {
#pragma omp for
        for ( i = 0; i < coreElements; i+= 4){
            int offset = omp_get_thread_num() * coreElements;
            vec_A = _mm256_load_pd(A + i + offset);
            vec_B = _mm256_load_pd(B + i + offset);
            vec_C = _mm256_add_pd(vec_A, vec_B);
            vec_C = _mm256_mul_pd(vec_C, vec_A);
            vec_C = _mm256_sqrt_pd(vec_C);
            _mm256_store_pd(C + i  + offset, vec_C);
        }

    }
}

void add_explicitly_optimization_8_cores_d(double * __restrict__ C, double * __restrict__ A, double * __restrict__ B, unsigned int elements){
    unsigned int i = 0;
    __m256d vec_A, vec_B, vec_C;
    int coreElements = elements / 8;
#pragma omp parallel num_threads(8)
    {
#pragma omp for
        for ( i = 0; i < coreElements; i+= 4){
            int offset = omp_get_thread_num() * coreElements;
            vec_A = _mm256_load_pd(A + i + offset);
            vec_B = _mm256_load_pd(B + i + offset);
            vec_C = _mm256_add_pd(vec_A, vec_B);
            vec_C = _mm256_mul_pd(vec_C, vec_A);
            vec_C = _mm256_sqrt_pd(vec_C);
            _mm256_store_pd(C + i  + offset, vec_C);
        }

    }
}