#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <assert.h>
#define ERROR 1E-16
#define EPSILON 1E-17
struct stMatrix{
    double *A;
    double *B;
    double *X1;
    double *X0;
    int mn;
};
typedef struct stMatrix tpMatrix;
void LoadMatrixAndVector(char *matrixFile, char *vectorFile, tpMatrix *matrix);
void PrintMatrixAndVector(const tpMatrix *matrix);
void JacobiMethod(tpMatrix *matrix);
void PrintX(double *X, const int size);
double max(double, double);
int main(int ac, char**av) {
  tpMatrix matrix;
  
  int      flagSave = atoi(av[4]);
  fprintf(stdout, "\nMétodo iterativo de solução de sistema linear - Jacobi\n");
  
  matrix.mn = atoi(av[3]);
  matrix.A = (double*) malloc (matrix.mn * matrix.mn *  sizeof(double));
  matrix.B = (double*) malloc (matrix.mn * sizeof(double));
  matrix.X0 = (double*) malloc (matrix.mn *  sizeof(double));
  matrix.X1 = (double*) malloc (matrix.mn *  sizeof(double));
  memset(matrix.X0, 0x00, matrix.mn *  sizeof(double));
  memset(matrix.X1, 0x00, matrix.mn *  sizeof(double));

  LoadMatrixAndVector(av[1], av[2], &matrix);
//    PrintMatrixAndVector(&matrix);
  //JacobiMethod(&matrix, iter);
  JacobiMethod(&matrix);

  if (flagSave == 1)
    PrintX(matrix.X0, matrix.mn);



  free(matrix.A);
  free(matrix.B);
  free(matrix.X0);
  free(matrix.X1);

  return EXIT_SUCCESS;
}

/*
 * Carrega a matrix e o vetor B do arquivo
 */
void LoadMatrixAndVector(char *matrixFile, char *vectorFile, tpMatrix *matrix){
  FILE *ptr = fopen(matrixFile, "rb+");
  assert(ptr != NULL);
  fread (matrix->A,sizeof(double), matrix->mn * matrix->mn, ptr);
  fclose(ptr);

  ptr = fopen(vectorFile, "rb+");
  assert(ptr != NULL);
  fread (matrix->B,sizeof(double), matrix->mn , ptr);
    
  fclose(ptr);
}

void PrintMatrixAndVector(const tpMatrix *matrix){

  fprintf(stdout, "Matrix (%d, %d)\n", matrix->mn, matrix->mn);
  for (int j = 0; j < matrix->mn; j++){
    for (int i = 0; i < matrix->mn; i++){
      int k = j * matrix->mn + i;
      fprintf(stdout, "%.7f ", matrix->A[k]);
    }
   fprintf(stdout, " \t %.7f \n", matrix->B[j]);
  }
}
/*
void JacobiMethod(tpMatrix *matrix, const unsigned int inter){

   double aux, valueX, div;

   for (int s = 1; s <= inter; s++){
      for (int j = 0; j < matrix->mn; j++){
        aux    = 0.0f;
        div    = 0.0f;
        valueX = 0.0f;
        for (int i = 0; i < matrix->mn; i++){
           valueX = matrix->X0[i];
           if (j != i)
              aux += ((matrix->A[matrix->mn * j + i] * valueX) * -1.0f);
           else
              div =  matrix->A[matrix->mn * j + i];
        }
        matrix->X1[j] = ((matrix->B[j] + aux) / div );
      }
      double *swap = matrix->X0;
      matrix->X0 = matrix->X1;
      matrix->X1 = swap;
   }

}
*/
void JacobiMethod(tpMatrix *matrix){

   double aux, 
         div, 
         err = 0.0;
   int inter = 0;
   
   do{
         for (int j = 0; j < matrix->mn; j++){
            aux    = 0.0;
            div    = 0.0;
            
            for (int i = 0; i < matrix->mn; i++){
              if (j != i)
//                  aux += ((matrix->A[matrix->mn * j + i] * matrix->X0[i]) * -1.0);
                  aux += (matrix->A[matrix->mn * j + i] * matrix->X0[i]);
               else
                  div =  matrix->A[matrix->mn * j + i];
            }
            matrix->X1[j] = ((matrix->B[j] - aux) / div );
         }

         err = fabs((matrix->X1[0] - matrix->X0[0]) / (matrix->X1[0] + EPSILON));
         for (int j = 1; j < matrix->mn; j++){
            double b = fabs((matrix->X1[j] - matrix->X0[j]) / (matrix->X1[j] + EPSILON));
             err = max(err, b);   
         }

         double *swap = matrix->X0;
         matrix->X0 = matrix->X1;
         matrix->X1 = swap; 
         inter++;
   
       
   }while (err > ERROR);
   printf("\n%18.16lf %d\n", err, inter);

}

void PrintX(double *X, const int size){
  FILE *ptr = fopen("solucao.txt", "w+");
  assert(ptr != NULL);
  for (int i = 0; i < size; i++){
    fprintf(ptr, "%20.15lf ", X[i]);
  }
  fprintf(ptr, "\n");
  fclose(ptr);
}

double max(double a, double b){
   if (a > b)
      return a;
   return b;
   
}
