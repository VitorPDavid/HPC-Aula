#include <stdio.h>
#define SIZE 10000
int main (void){
  int a[SIZE];
  for (int i = 0 ; i < SIZE; i++)
    a[i] = (i + 1);

#pragma open parallel for
  for (int i = 0 ; i < SIZE; i++)
    a[i] = 2 * a[i];

printf("%d\n",a[SIZE-1]);
    return 0;
}

// gcc exemplo-02.c -fopenmp -o exemplo
