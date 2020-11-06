#ifndef _TOOLS_CUH_
#define _TOOLS_CUH_
#include <ModelTypes.h>

void GameOfLifeGPU(tpLattice*);
void InitRandnessGPU(tpLattice *mLattice, int *buffer, float p);
//void Wolfram1DCA(void);
#endif
