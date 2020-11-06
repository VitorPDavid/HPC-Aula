#ifndef _CELLULARAUTOMATA_HPP_
#define _CELLULARAUTOMATA_HPP_
#include <App.hpp>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <string>
extern "C" {
  #include <ModelTypes.h>
}
using namespace std;

class CellularAutomata{

public:
    CellularAutomata();
    ~CellularAutomata();
    void help(void);
    void init(void);
    void update(void);
    void step(void);
    int getLattice(int, int);
    void finalize(void);
    bool  isRunning (void) {return mRunning; };
    bool isInit(void){ return mInit; };
    void setConfig(tpConfig );
    void offRunning(void){ mRunning = false;};
    void onRunning(void){ mRunning = true;};
    void saving(const  string);



protected:


  bool                               mInit;
  tpLattice                         mLattice;
  int                               *mBuffer;
   bool                             mRunning;
  tpConfig                          mConfig;
};
#endif
