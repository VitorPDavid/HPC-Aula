#include "GPU.h"
#include <cstdlib>
#include <cmath>
#include <vector>
#include <cstdio>
#include <vector_types.h>

std::vector <float4> mTexture2D;
std::vector <float> mResult;
unsigned int mWidth  = 8;
unsigned int mHeight = 4;

float float4_2_float (float4 v)
{
   return (v.x * 1.0f) + (v.y * 2.0f) + (v.z * 3.0f) + (v.w * 4.0f);
}
int main(int argc, char *argv[])
{

   fprintf(stdout, "\nUsing texture memory");
   mTexture2D.resize(mWidth * mHeight);
   mResult.resize(mWidth * mHeight);
   float k = 1.0f;
   for (unsigned int i = 0; i < mTexture2D.size(); i++)
   {
      mTexture2D[i].x = k++;
      mTexture2D[i].y = k++;
      mTexture2D[i].z = k++;
      mTexture2D[i].w = k++;
   }
   
   fprintf(stdout, "Before processing: ");
   for (unsigned int i = 0; i < mHeight; i++)
   {
      fprintf(stdout, "\n");
      for (unsigned int j = 0; j < mWidth; j++)
      {
         unsigned int k = i * mWidth + j;
         fprintf(stdout, "\n (%f, %f, %f, %f)", mTexture2D[k].x, mTexture2D[k].y, mTexture2D[k].z, mTexture2D[k].w);
      }
   }
      
   
   runOnGPU(&(mResult[0]), mResult.size() * sizeof(float), &(mTexture2D[0]), mTexture2D.size() * sizeof(float4), mWidth, mHeight);
   
   fprintf(stdout, "\nBefore processing: ");
   for (unsigned int i = 0; i < mHeight; i++)
   {
      fprintf(stdout, "\n");
      for (unsigned int j = 0; j < mWidth; j++)
      {
         unsigned int k = i * mWidth + j;
         fprintf(stdout, "\n [%d, %d] (%f, %f, %f, %f) = %f", i, j, mTexture2D[k].x, mTexture2D[k].y, mTexture2D[k].z, mTexture2D[k].w, float4_2_float(mTexture2D[k]));
      }
   }
   
   fprintf(stdout, "\nMatrix (%dx%d):", mWidth, mHeight);
   for (unsigned int i = 0; i < mHeight; i++)
   {
      fprintf(stdout, "\n");
      for (unsigned int j = 0; j < mWidth; j++)
      {
         unsigned int k = i * mWidth + j;
         fprintf(stdout, "  %f", mResult[k]);
      }
   }
   
   
   fprintf(stdout, "\n");
   fflush(stdout);
   return EXIT_SUCCESS;
}

