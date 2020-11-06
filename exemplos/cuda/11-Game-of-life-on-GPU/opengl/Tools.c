#include <Tools.h>
#include <time.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <stdio.h>
#include <string.h>

void InitRandness(tpLattice *mLattice, float p){
  memset(mLattice->buff0, 0x00,  mLattice->width *   mLattice->height *  sizeof(int));
  memset(mLattice->buff1, 0x00,  mLattice->width *   mLattice->height *  sizeof(int));

  for (int j = 1; j < mLattice->height - 1; j++){
      for (int i = 1; i < mLattice->width - 1; i++){
          int k = j * mLattice->width  +  i;
          float r = (rand() / (float)RAND_MAX);
          if (r <= p)
            mLattice->buff0[k] = 1;

      }//end-  for (int i = 0; i < mLattice->width; i++){
  }//end-for (int j = 0; j < mLattice->height; j++){
}//end-void InitRandness(tpLattice *mLattice, float p){


void GameOfLife(tpLattice *mLattice){
    int nw = -1, n = -1, ne = -1, w = -1, e = -1, sw = -1, s = -1, se = -1, c = -1, sum;
    /*
        nw | n | ne
       ----|---|----
        w  | c |  e
       ----|---|----
        sw | s | se
    */
    for (int j = 1; j < mLattice->height - 1; j++){
        for (int i = 1; i < mLattice->width - 1; i++){

          nw = mLattice->buff0[(j - 1) * mLattice->width  +  (i - 1)];
           n = mLattice->buff0[(j - 1) * mLattice->width  +  i];
          ne = mLattice->buff0[(j - 1) * mLattice->width  +  (i + 1)];
          w  = mLattice->buff0[j * mLattice->width  +  (i - 1)];
          c  = mLattice->buff0[j * mLattice->width  +  i];
          e  = mLattice->buff0[j * mLattice->width  +  (i + 1)];
          sw = mLattice->buff0[(j + 1) * mLattice->width  +  (i - 1)];
          s  = mLattice->buff0[(j + 1) * mLattice->width  +  i];
          se = mLattice->buff0[(j + 1) * mLattice->width  +  i+1];

          sum = nw + n + ne + w + e + sw + s + se;

              //mRule
              if ((sum == 3) && (c == 0))
                 mLattice->buff1[j  * mLattice->width  +  i] = 1;
              else if ((sum >= 2) && (sum <= 3) && (c == 1))
                 mLattice->buff1[j  * mLattice->width  +  i] = 1;
              else
                mLattice->buff1[j  * mLattice->width  +  i] = 0;
        }//end-  for (int i = 0; i < mLattice->width; i++){
    }//end-for (int j = 0; j < mLattice->height; j++){
}

void Wolfram_Rules(int *buf, int t, int width, int (*rules)(int, int, int)){
   int *buffer0 = &buf[ (t-1) * width];
   int *buffer1 = &buf[  t    * width];
   int w, c, l;
   for (int i = 1; i < width - 1; i++){
      c = buffer0[i];
      w = buffer0[i - 1];
      l = buffer0[i + 1];

        /*
      if ((i > 0) && (i < width -1)){
          w = buffer0[i - 1];
          l = buffer0[i + 1];
      }else if (i == 0){
        w = 0;
        l =  buffer0[i + 1];
      }else if (i == (width -1)){
        w =  buffer0[i - 1];;
        l =  0;
      }//end-if ((i > 0) && (i < width -1)){
*/
      buffer1[i] = rules(w, c, l);
   }//end-for (int i = 0; i < width; i++){

}

int Rule_90(int w, int c, int l){

    return  ((w & !l) | (!w & l));
}
//---------------------------------------------------------------------------------------------------------------
void prisionerDilemmaCount(tpLattice *mLattice){
    int n = -1, w = -1, e = -1, s = -1, decision = -1;
    /*
           | n | 
       ----|---|----
        w  | c |  e
       ----|---|----
           | s |  
    */
    float defect = 0.0f;
    float cooperate = 0.0f;
    for (int j = 0; j < mLattice->height ; j++){
        for (int i = 0; i < mLattice->width ; i++){
            if (mLattice->buff0[j  * mLattice->width  +  i] == 1){
                cooperate++;
            }else{
                defect++;
            }
                
            
        }//end-  for (int i = 0; i < mLattice->width; i++){
    }//end-for (int j = 0; j < mLattice->height; j++){
    
    cooperate /= (float) (mLattice->height * mLattice->width);
    defect /= (float) (mLattice->height * mLattice->width);
    
    FILE *ptr = fopen("log.txt", "a+");
    fprintf(ptr, "%.4f   %.4f   \n", cooperate, defect);
    fclose(ptr);
    
}

int score(int year){ return 5 - year; }


void yearMatrix(int A, int B, int *yearA, int *yearB){
    //Confessa = 1
    //Nega = 0
    
    if ((A == 1) && (B == 1)){
        *yearA = 2;
        *yearB = 2;
        return;
    }
        
    if ((A == 1) && (B == 0)){
        *yearA = 1;
        *yearB = 4;
        return;
    }
    
    if ((A == 0) && (B == 1)){
        *yearA = 4;
        *yearB = 1;
        return;
    }
    
    if ((A == 0) && (B == 0)){
        *yearA = 0;
        *yearB = 0;
        return;
    }
    
    
}


void ScorePrisionerDilemma(tpLattice *mLattice, int *mScore){
    int n = -1, w = -1, e = -1, s = -1, decision = -1;
    /*
           | n | 
       ----|---|----
        w  | c |  e
       ----|---|----
           | s |  
    */
    for (int j = 0; j < mLattice->height ; j++){
        for (int i = 0; i < mLattice->width ; i++){
            int n, s, w, e;
            
            if (j == 0)
                n = mLattice->buff1[(mLattice->height - 1) * mLattice->width  +  i];
            else
                n = mLattice->buff1[(j - 1) * mLattice->width  +  i];
                    
            if (j == (mLattice->height - 1))
                s = mLattice->buff1[mLattice->width  +  i];
            else
                s = mLattice->buff1[(i + 1) * mLattice->width  +  i];
            
            if (i == 0)
                w  = mLattice->buff1[j * mLattice->width  +  (mLattice->width - 1)];
            else
                w  = mLattice->buff1[j * mLattice->width  +  (i - 1)];

            if (i == (mLattice->width - 1))
                e  = mLattice->buff1[j * mLattice->width];
            else
                e  = mLattice->buff1[j * mLattice->width  +  (mLattice->width + 1)];
            
            int decision = mLattice->buff1[j  * mLattice->width  +  i]; 
            
            int yearA       = -1;
            int yearB       = -1;
           
           
            yearMatrix(decision, n, &yearA, &yearB);
            mScore[j  * mLattice->width  +  i] += score(yearA);
            
            yearMatrix(decision, s, &yearA, &yearB);
            mScore[j  * mLattice->width  +  i] += score(yearA);

            yearMatrix(decision, w, &yearA, &yearB);
            mScore[j  * mLattice->width  +  i] += score(yearA);

            yearMatrix(decision, e, &yearA, &yearB);
            mScore[j  * mLattice->width  +  i] += score(yearA);
            
        }//end-  for (int i = 0; i < mLattice->width; i++){
    }//end-for (int j = 0; j < mLattice->height; j++){
}

void prisionerDilemma(tpLattice *mLattice){
    int n = -1, w = -1, e = -1, s = -1, decision = -1;
    /*
           | n | 
       ----|---|----
        w  | c |  e
       ----|---|----
           | s |  
    */
    for (int j = 0; j < mLattice->height ; j++){
        for (int i = 0; i < mLattice->width ; i++){
            int n, s, w, e;
            
            if (j == 0)
                n = mLattice->buff0[(mLattice->height - 1) * mLattice->width  +  i];
            else
                n = mLattice->buff0[(j - 1) * mLattice->width  +  i];
                    
            if (j == (mLattice->height - 1))
                s = mLattice->buff0[mLattice->width  +  i];
            else
                s = mLattice->buff0[(i + 1) * mLattice->width  +  i];
            
            if (i == 0)
                w  = mLattice->buff0[j * mLattice->width  +  (mLattice->width - 1)];
            else
                w  = mLattice->buff0[j * mLattice->width  +  (i - 1)];

            if (i == (mLattice->width - 1))
                e  = mLattice->buff0[j * mLattice->width];
            else
                e  = mLattice->buff0[j * mLattice->width  +  (mLattice->width + 1)];
            
            
            int yearA1      = -1;
            int yearA2      = -1;
            int yearB       = -1;
           
            //In relate to me
            int denyAcc       =  0;
            int coopareteAcc  =  0;
            
            int scoreA, scoreB;
        
            yearMatrix(1, n, &yearA1, &yearB);scoreA = score(yearA1);           
            yearMatrix(0, 0, &yearA2, &yearB);scoreB = score(yearA2);
            
            if (scoreA > scoreB){
                coopareteAcc++;
            }else{
                denyAcc++;
            }

            yearMatrix(1, s, &yearA1, &yearB);scoreA = score(yearA1);
            
            yearMatrix(0, s, &yearA2, &yearB); scoreB = score(yearA2);
            
            if (scoreA > scoreB){
                coopareteAcc++;
            }else{
                denyAcc++;
            }
    
            yearMatrix(1, w, &yearA1, &yearB);scoreA = score(yearA1);
            yearMatrix(0, w, &yearA2, &yearB); scoreB = score(yearA2);
            
            if (scoreA > scoreB){
                coopareteAcc++;
            }else{
                denyAcc++;
            }
    
            yearMatrix(1, e, &yearA1, &yearB);scoreA = score(yearA1);
            yearMatrix(0, e, &yearA2, &yearB); scoreB = score(yearA2);
            
            if (scoreA > scoreB){
                coopareteAcc++;
            }else{
                denyAcc++;
            }
            
          
            if (coopareteAcc >= denyAcc)
                decision = 1;
            else
                decision = 0;

            /*
             float r = (rand() / (float)RAND_MAX);    
             if (r < 0.25f)
                decision = !decision;
    */        
            
            mLattice->buff1[j  * mLattice->width  +  i] = decision; 
            
        }//end-  for (int i = 0; i < mLattice->width; i++){
    }//end-for (int j = 0; j < mLattice->height; j++){
}
//--------------------------------------------------------------------------------------------------------------
