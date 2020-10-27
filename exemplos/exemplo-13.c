#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <unistd.h>
#include <string.h>
#include <assert.h>
#include <time.h>

#define BLOCK_SIZE 32





void printMatrix(float *m, float w, float h){
   int i, j;

   printf("\n");

   for (j = 0; j < h; j++){
      for (i = 0; i < w; i++){
         int k = j * w + i;
         printf("%.2f ", m[k]);
      }
      printf("\n");
   }

}

int main (int argc, char **argv){


   float *h_A, *h_B, *h_C;
   int iC, jC;

	int width      = atoi(argv[1]);
	int height     = width;

   srand (time(NULL));

   printf("\nMultiplicando matriz - GPU\n");
   printf("Tamanho da matriz: %d x %d \n", width, height);

    h_A = (float*) malloc (width * height * sizeof(float));
    h_B = (float*) malloc (width * height * sizeof(float));
    h_C = (float*) malloc (width * height * sizeof(float));



   for (jC = 0; jC < height; jC++){
      for (iC = 0; iC < width; iC++){
         int kC = jC * width + iC;
         h_A[kC] = (float) (rand() % 65536 + 1) / 65536.0f;

         if (jC == iC)
           h_B[kC] = 1.0f;
         else
            h_B[kC] = 0.0f;

      }
   }




   float err = 0.0f;
   for (jC = 0; jC < height; jC++){
        for (iC = 0; iC < width; iC++){
           int kC = jC * width + iC;
           if (fabs(h_A[kC]-h_C[kC]) > 0.000000001f)
        	   err++;
        }
   }
   printf("Error: %f\n", (err / (float)(width*height)));
   //validando



   free(h_A);
   free(h_B);
   free(h_C);

   printf("FIM\n");

   return EXIT_SUCCESS;
}
