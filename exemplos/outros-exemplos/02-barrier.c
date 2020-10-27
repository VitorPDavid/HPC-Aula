#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
int main(int ac, char**av){

    int tID, nThreads;

    #pragma omp parallel private(tID, nThreads)
    {
        tID = omp_get_thread_num();
        printf("Eu sou a thread: %d.\n", tID);


        #pragma omp barrier
        if (tID == 0){
            nThreads  = omp_get_num_threads();
              printf("Total de threads: %d\n",nThreads);
        }
    }

    return EXIT_SUCCESS;
}
