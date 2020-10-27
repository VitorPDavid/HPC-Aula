/**
 * Exemplo hello world em openmpi
 */ 

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <mpi.h>

int main(int ac, char **av){
   int    myrank = 0, 
          nprocess = 0,
          namelen = 0;

   char   processor_name[MPI_MAX_PROCESSOR_NAME];

   MPI_Init(&ac,&av);
   MPI_Comm_size(MPI_COMM_WORLD,&nprocess);
   MPI_Comm_rank(MPI_COMM_WORLD,&myrank);
   MPI_Get_processor_name(processor_name,&namelen);
   fprintf(stdout, "Olá, eu sou o computador: %s - rank %d - total de processos %d \n", processor_name, myrank, nprocess);
   

   MPI_Finalize();
   return EXIT_SUCCESS;
}