#ifndef _MODELTYPES_H_
#define _MODELTYPES_H_

#define CPU 0
#define GPU 1

struct stLattice{
    int *buff0;
    int *buff1;
    int width;
    int height;
};
typedef struct stLattice tpLattice;


struct stConfig{
  int width;
  int height;
  float prob;
  int processor;
    
};
typedef struct stConfig tpConfig;


#endif
