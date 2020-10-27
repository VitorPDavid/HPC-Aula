#include <stdio.h>
#include <omp.h>
void funcao1(int tid){
    fprintf(stdout, "MIMD -> Func-01 = %d\n", tid);
}

void funcao2(int tid){
    fprintf(stdout, "MIMD -> Func-02 = %d\n", tid);
}

int main (int ac, char **av){
    int tid = -1;

    #pragma omp parallel num_threads(2) private(tid)
    {
        tid = omp_get_thread_num();
        switch (tid){
        case 0:funcao1(tid);break;
        case 1:funcao2(tid);break;

        }




    }//end-#pragma omp parallel shared(a, b, c) private(i)
    return 0;
}
