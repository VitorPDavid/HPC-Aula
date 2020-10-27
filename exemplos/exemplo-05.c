#include <stdio.h>
#include <omp.h>
int main (void){
  int th_id = -1, flag_f = -1, flag_l = -1;
#pragma omp parallel private(th_id) firstprivate(flag_f)
{
   th_id = omp_get_thread_num();

  #pragma omp for  lastprivate(flag_l)
  for (int i = 0; i < 16; i++){
    printf("Hello: %d -> %d\n", i, th_id * flag_f);
    flag_l = th_id;
  }
}
  printf("firstprivate %d\n", flag_f);
  printf("lastprivate %d\n", flag_l);
  return 0;
}
/*
Atenção para o escopo. firstprivate(flag_f) cria a variável privada com o valor
inicializando antes de entrar no #pragma omp parallel. Observe que se colocar
dentro do #pragma omp parallel, então variável é inicializada com 0
lastprivate -> inicializa com o último valor produzido pela última thread.
Não é a variável i e sim o valor produzido pela i-ésima iteração da última thread
*/
