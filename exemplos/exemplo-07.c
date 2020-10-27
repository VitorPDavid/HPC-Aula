#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <unistd.h>

#define SIZE 1000
int main (int ac, char **av){
    int flag = 0;    
    int vet[SIZE]; //para usar no problema do produtor e consumidor
    bzero(vet, sizeof(int) * SIZE);
    #pragma omp parallel num_threads(3)
    {
        if(omp_get_thread_num()==0){
            /* Set flag to release thread 1 */
            printf("Thread 0 viva\n");
            usleep(1000000);
            #pragma omp atomic update
            flag++;
            /* Flush of flag is implied by the atomic directive */
        } else if(omp_get_thread_num()==1){
            /* Loop until we see that flag reaches 1*/
            #pragma omp flush(flag)
            while(flag < 1){
                printf("-");
                #pragma omp flush(flag)
            }
            printf("\nThread 1 viva\n");
            /* Set flag to release thread 2 */
            #pragma omp atomic update
            flag++;
              /* Flush of flag is implied by the atomic directive */
        }
        else if(omp_get_thread_num()==2){
          /* Loop until we see that flag reaches 2 */
          #pragma omp flush(flag)
          while(flag < 2){
              #pragma omp flush(flag)
          }
          printf("Thread 2 viva\n");
       }
  }
  return EXIT_SUCCESS;
}

