#ifndef _TOOLS_H_
#define _TOOLS_H_
#include <ModelTypes.h>

#define CONSTANT1 1
#define CONSTANT0 0
#define REFLECTIVE 2
#define PERIODIC   3

void InitRandness(tpLattice *, float);
void GameOfLife(tpLattice*);
void Wolfram_Rules(int *buffer, int t, int width, int (*rules)(int, int, int));
int Rule_90(int w, int c, int l);



#endif
