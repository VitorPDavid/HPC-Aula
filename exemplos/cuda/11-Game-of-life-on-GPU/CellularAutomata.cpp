   /*
 *  CellularAutomata.cpp
 *  TCA
 *
 *  Created by Marcelo Zamith on 3/15/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include <CellularAutomata.hpp>
//#include <TModelCA.hpp>
#include <iomanip>
#include <fstream>
#include <cassert>
#include <ctime>
#include <climits>
#include <cstring>
#include <cuda_runtime.h>
#include <cuda.h>
#include <ToolsGPU.cuh>
extern "C"{
  #include <Tools.h>
}
using namespace std;

/*
 *
 */
CellularAutomata::CellularAutomata():
mRunning(false),
mInit(false),
mBuffer(NULL)
{
  cout << "\nStarting application" << endl;
  mLattice.buff0 = NULL;
  mLattice.buff1 = NULL;
  srand (time(NULL));
}

/*
 *
 */
CellularAutomata::~CellularAutomata()
{ cout << "\nFinalizing application" << endl;  }




/*
 * Clear memories
 */
//void CellularAutomata::clear(void) { mRules->getGrid()->allocGrid(mParam.cellX, mRules->getParam()->cellY); };

void CellularAutomata::help(void){
    cout << "HELP" << endl;
}


/**
 *  inicialize
 *  @param fileName: config file name
 */
void CellularAutomata::init(void){
    cout << "Init in init" << endl;
    mInit = true;
    mRunning = false;


     if (mConfig.processor == CPU){
         InitRandness(&mLattice, mConfig.prob);


    }else if (mConfig.processor == GPU){
        InitRandnessGPU(&mLattice, mBuffer,  mConfig.prob);

    }

}

/**
 * Finalize and dealloc all variables.
 * It also saves log file
 */
void CellularAutomata::finalize(void){

    if (mConfig.processor == CPU){
        if (mLattice.buff0 != NULL)
        free(mLattice.buff0);

        if (mLattice.buff1 != NULL)
        free(mLattice.buff1);



    }else if (mConfig.processor == GPU){
        if (mLattice.buff0 != NULL)
            cudaFree(mLattice.buff0);

        if (mLattice.buff1 != NULL)
            cudaFree(mLattice.buff1);

        if (mBuffer != NULL)
            free(mBuffer);

    }




    cout << "finalize " << endl;
};


int CellularAutomata::getLattice(int i, int j){
    int cell = 0;
    if (mConfig.processor == CPU)
        cell = mLattice.buff0[j * mLattice.width  +  i];
    else if (mConfig.processor == GPU)
        cell = mBuffer[j * mLattice.width  +  i];

    return  cell;
}
/*
 * Running the simulation
 */

void CellularAutomata::update(void){
  if (!mRunning)
    return;

    if  (mConfig.processor == GPU){
        GameOfLifeGPU(&mLattice);
        cudaMemcpy((void*)mBuffer,  (const void*) mLattice.buff1,  mLattice.width *   mLattice.height *  sizeof(int), cudaMemcpyDeviceToHost);
    }

    int *ptr = mLattice.buff0;
    mLattice.buff0 = mLattice.buff1;
    mLattice.buff1 = ptr;

/*
    cout << endl;
    for (int i = 0; i < mLattice.width * mLattice.height; i++){
      cout << mLattice.buff0[i];
    }

    cout << endl;
    for (int i = 0; i < mLattice.width * mLattice.height; i++){
      cout << mLattice.buff1[i];
    }
    cout << endl;
    exit(-1);
*/
}

void CellularAutomata::step(void){


    if  (mConfig.processor == GPU){
        GameOfLifeGPU(&mLattice);
        cudaMemcpy((void*)mBuffer,  (const void*) mLattice.buff1,  mLattice.width *   mLattice.height *  sizeof(int), cudaMemcpyDeviceToHost);
    }

    int *ptr = mLattice.buff0;
    mLattice.buff0 = mLattice.buff1;
    mLattice.buff1 = ptr;

/*
    cout << endl;
    for (int i = 0; i < mLattice.width * mLattice.height; i++){
      cout << mLattice.buff0[i];
    }

    cout << endl;
    for (int i = 0; i < mLattice.width * mLattice.height; i++){
      cout << mLattice.buff1[i];
    }
    cout << endl;
    exit(-1);
*/
}

void CellularAutomata::setConfig(tpConfig c){

    mConfig = c;

    mLattice.width = mConfig.width;
    mLattice.height = mConfig.height;

    if (mConfig.processor == CPU){
        if (mLattice.buff0 != NULL)
        free(mLattice.buff0);

        if (mLattice.buff1 != NULL)
        free(mLattice.buff1);

        assert(posix_memalign((void**) &mLattice.buff0, ALIGN,   mLattice.width *   mLattice.height *  sizeof(int)) == 0);
        assert(posix_memalign((void**) &mLattice.buff1, ALIGN,   mLattice.width *   mLattice.height *  sizeof(int)) == 0);

        memset(mLattice.buff0, 0x00,  mLattice.width *   mLattice.height *  sizeof(int));
        memset(mLattice.buff1, 0x00,   mLattice.width *   mLattice.height *  sizeof(int));

    }else if (mConfig.processor == GPU){
        if (mLattice.buff0 != NULL)
            cudaFree(mLattice.buff0);

        if (mLattice.buff1 != NULL)
            cudaFree(mLattice.buff1);

        cudaMalloc((void**) &mLattice.buff0, mLattice.width *   mLattice.height *  sizeof(int));
        cudaMalloc((void**) &mLattice.buff1, mLattice.width *   mLattice.height *  sizeof(int));
        cudaMemset(mLattice.buff0, 0x00,  mLattice.width *   mLattice.height *  sizeof(int));
        cudaMemset(mLattice.buff1, 0x00,   mLattice.width *   mLattice.height *  sizeof(int));

        assert(posix_memalign((void**) &mBuffer, ALIGN,   mLattice.width *   mLattice.height *  sizeof(int)) == 0);
        memset(mBuffer, 0x00,  mLattice.width *   mLattice.height *  sizeof(int));

        assert(mBuffer != NULL);

    }




    assert(mLattice.buff0 != NULL);

    assert(mLattice.buff1 != NULL);

};

void CellularAutomata::saving(const  string filename){
  //char *buff = new char[mLattice.width *   mLattice.height];
  fstream output;
  output.open(filename, std::fstream::out | std::fstream::binary | std::fstream::trunc);
  assert(output.is_open());
  output.write(reinterpret_cast<const char*> (&mLattice.width),  sizeof(mLattice.width));
  output.write(reinterpret_cast<const char*> (&mLattice.height),  sizeof(mLattice.height));

  output.write(reinterpret_cast<const char*> (mLattice.buff0), mLattice.width *   mLattice.height * sizeof(int));
//  delete[] buff;
  output.close();
}
