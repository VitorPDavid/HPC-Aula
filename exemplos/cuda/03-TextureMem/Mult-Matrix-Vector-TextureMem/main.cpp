#include <GPU.h>
#include <cstdlib>
#include <cmath>
#include <vector>
#include <cstdio>

/*
 *
 *   Problema resolvido: Produto de matriz por vetor
 *                       mVetorB = mMatrizA * mVetorA
 *
 */

std::vector <float> mMatrizA,
                    mVetorA,
                    mVetorB;


int mColunas  = 8,
    mLinhas   = 4;



int main(int argc, char *argv[])
{


   fprintf(stdout, "\nDemo 1 - Multiplicacao de vetor por matriz (%d, %d)", mColunas, mLinhas);

   //Inicializando vetores
   mMatrizA.resize(mColunas * mLinhas);
   mVetorA.resize(mColunas);
   mVetorB.resize(mLinhas);
   for (int i = 0; i < mColunas; i++)
   {
       for (int j = 0; j < mLinhas; j++)
       {
           int k = i * mLinhas + j;
           mMatrizA[k] = static_cast <float> (k + 1) / 100.0f;

       }

       mVetorA[i] = static_cast <float> ((i+1) * -1) / 10.0f;
   }

   multiplicaMatrizVetor(&(mVetorB[0]), &(mMatrizA[0]), &(mVetorA[0]), mColunas, mLinhas);

   //Print resultado
   for (int i = 0; i < mLinhas; i++)
   {
       fprintf(stdout, "\n %.3f \t = ", mVetorB[i]) ;// %.2f \t = ", mVetorB[i]);

       float t = 0;
       for (int j = 0; j < mColunas; j++)
       {
           int k = i * mColunas + j;
           fprintf(stdout, "%.3fx%.3f \t", mMatrizA[k], mVetorA[j]);
           //t += mMatrizA[k] * mVetorA[j];
       }
       fprintf(stdout, "\t [%.3f]", t);

   }

   fprintf(stdout, "\n\nFIM \n");
   return EXIT_SUCCESS;
}

