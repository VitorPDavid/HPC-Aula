#include <stdio.h>
#include <stdlib.h>
#include "App.h"

/* Funções declaradas em arquivos externos */
void add_no_optimization_d(double * __restrict__ C, double * __restrict__ A, double * __restrict__ B, unsigned int elements);
void add_implicitly_optimization_d(double * __restrict__ C, double * __restrict__ A, double * __restrict__ B, unsigned int elements);
void add_explicitly_optimization_d(double * __restrict__ C, double * __restrict__ A, double * __restrict__ B, unsigned int elements);
void add_explicitly_optimization_2_cores_d(double * __restrict__ C, double * __restrict__ A, double * __restrict__ B, unsigned int elements);
void add_explicitly_optimization_4_cores_d(double * __restrict__ C, double * __restrict__ A, double * __restrict__ B, unsigned int elements);
void add_explicitly_optimization_8_cores_d(double * __restrict__ C, double * __restrict__ A, double * __restrict__ B, unsigned int elements);

void precision_d(int ac, char **av){
  //char *fileName = "log_d.txt";  
  unsigned int memory = atoi(av[1]) * 1024 * 1024,
                    i = 0,
                    elements = memory / sizeof(double);
    //int save_output = atoi(av[2]);
    double *A = NULL,
             *B = NULL,
             *C = NULL;
    FILE *output = NULL;
    double soTime,
           ioTime,
           eoTime,
           eo2Time,
           eo4Time,
           eo8Time;

    Stopwatch sw;
    
    fprintf(stdout, "\tTamanho do array: [%15u] \n", elements);
    fprintf(stdout, "\t Memoria alocada: [%15u] Mbytes (3 vetores) \n", (3 * memory) /1024/1024);

    posix_memalign((void**)&A, 64, memory);
    posix_memalign((void**)&B, 64, memory);
    posix_memalign((void**)&C, 64, memory);

    for (  i = 0; i < elements; i++){
        B[i] = (float) ((i+256) % 127) / 100.0f;
        A[i] = B[i];
        C[i] = 0.0f;
    }
    
    fprintf(stdout, "\tIniciando processamento sem otimização (SO)     ");
    fflush(stdout);
    START_STOPWATCH(sw);
    add_no_optimization_d(C, A, B, elements);
    STOP_STOPWATCH(sw);
    fprintf(stdout, "\t [OK]\n");
    fflush(stdout);    
    soTime = sw.mElapsedTime;

    fprintf(stdout, "\tIniciando processamento otimização implitica (OI)");
    fflush(stdout);
    START_STOPWATCH(sw);
    add_implicitly_optimization_d(C, A, B, elements/4);
    STOP_STOPWATCH(sw);
    fprintf(stdout, "\t [OK]\n");
    fflush(stdout);    
    ioTime = sw.mElapsedTime;

    fprintf(stdout, "\tIniciando processamento otimização explitica (OE)");
    fflush(stdout);
    START_STOPWATCH(sw);
    add_explicitly_optimization_d(C, A, B, elements/4);
    STOP_STOPWATCH(sw);
    fprintf(stdout, "\t [OK]\n");
    fflush(stdout);    
    eoTime = sw.mElapsedTime;

    fflush(stdout);
    fprintf(stdout, "\tIniciando processamento otimização explitica 2 cores (OE)");
    fflush(stdout);
    START_STOPWATCH(sw);
    add_explicitly_optimization_2_cores_d(C, A, B, elements/4);
    STOP_STOPWATCH(sw);
    fprintf(stdout, "\t [OK]\n");
    fflush(stdout);
    eo2Time = sw.mElapsedTime;

    fflush(stdout);
    fprintf(stdout, "\tIniciando processamento otimização explitica 4 cores (OE)");
    fflush(stdout);
    START_STOPWATCH(sw);
    add_explicitly_optimization_4_cores_d(C, A, B, elements/4);
    STOP_STOPWATCH(sw);
    fprintf(stdout, "\t [OK]\n");
    fflush(stdout);
    eo4Time = sw.mElapsedTime;

    fflush(stdout);
    fprintf(stdout, "\tIniciando processamento otimização explitica 8 cores (OE)");
    fflush(stdout);
    START_STOPWATCH(sw);
    add_explicitly_optimization_8_cores_d(C, A, B, elements/4);
    STOP_STOPWATCH(sw);
    fprintf(stdout, "\t [OK]\n");
    fflush(stdout);
    eo8Time = sw.mElapsedTime;


    fprintf(stdout, "\n");
    fprintf(stdout, " |------|------------|---------| \n");
    fprintf(stdout, " | Func | Tempo (ms) | Speedup | \n");
    fprintf(stdout, " |------|------------|---------| \n");
    fprintf(stdout, " |   SO | %10.3lf |    -    | \n", soTime);
    fprintf(stdout, " |   IO | %10.3lf | %7.3lf | \n", ioTime, (soTime  / ioTime));
    fprintf(stdout, " |   EO | %10.3lf | %7.3lf | \n", eoTime, (soTime  / eoTime));
    fprintf(stdout, " |  E2O | %10.3lf | %7.3lf | \n", eo2Time, (soTime  / eo2Time));
    fprintf(stdout, " |  E4O | %10.3lf | %7.3lf | \n", eo4Time, (soTime  / eo4Time));
    fprintf(stdout, " |  E8O | %10.3lf | %7.3lf | \n", eo8Time, (soTime  / eo8Time));
    fprintf(stdout, " |------|------------|---------| \n\n");

/*
    fprintf(stdout, "\| Func \| Tempo (ms) \|  Speedup \% \| \n");
    fprintf(stdout, "\|   SO \| %6.3lf \|     -       \| \n", soTime);
    fprintf(stdout, "\|   IO \| %6.3lf \|  %6.3lf \% \| \n", ioTime, (soTime / ioTime));
    fprintf(stdout, "\|   EO \| %6.3lf \|  %6.3lf \% \| \n", eoTime, (soTime / eoTime));
*/

/*
    if ( save_output != 0){
        output  = fopen(fileName, "w");
        for (  i = 0; i < elements; i++){
            fprintf(output, "%lf = %lf + %lf \n", C[i], A[i], B[i]);
        }
        fprintf(stdout, "Resultado gravado em [%s]\n\n\n", fileName); 
        fclose(output);
    }
    */
    free(A);
    free(B);
    free(C);
}

int main(int ac, char **av){
    fprintf(stdout, "\nExercicio de vetorizacao\n");
    fprintf(stdout, "Alocacao de memoria alinhada em 16bytes\n");
    precision_d(ac, av);
    
}
