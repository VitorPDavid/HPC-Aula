#include <stdio.h>
int main (void){
#pragma omp parallel
{
    printf("Hello, World !\n");
}
    return 0;
}
/*
 compilando versão sequencial:
 gcc exemplo-01.c -o exemplo-01-seq

 versão OpenMP
 gcc exemplo-01.c -fopenmp -o exemplo-01-mt



*/
