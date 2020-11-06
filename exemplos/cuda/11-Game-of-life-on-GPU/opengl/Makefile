#CPUCPP     = /opt/intel/bin/icpc
#CPUCPP     = /usr/bin/g++-7
MPICPP    = mpic++
CPUCPP    = g++
CPUC      = gcc
GPUC      = /usr/local/cuda/bin/nvcc
CPPFLAGS  = --std=c++11 -m64 -Wno-reorder #     -Wunused-variable #-Wno-conversion-null -Wdelete-non-virtual-dtor
CFLAGS    = --std=c11 -m64	 #     -Wunused-variable #-Wno-conversion-null -Wdelete-non-virtual-dtor
GPUFLAGS  = --std=c++11 -m64
DEFS      = $(APPLICATION)  $(VERSION) -DALIGN=64
INCLUDES  =	-I. -I/usr/local/cuda/include
LIBDIR   = -L/usr/lib -L/usr/lib/x86_64-linux-gnu -L/usr/local/cuda/lib64 
LIBS     =    -lm
LINK     =  $(LIBDIR) $(LIBS)

ifeq ($(target), release)
  DEFS      +=
  CPPFLAGS  +=      -Ofast
  GPUFLAGS  +=      -Ofast
else
  DEFS     += -D_DEBUG
  CPPFLAGS += -g -Wall -O0
  GPUFLAGS  += -g  -O0
endif

CPU_COMPILE_CPP = $(CPUCPP) $(DEFS) $(INCLUDES) $(CPPFLAGS)
MPI_COMPILE_CPP = $(MPICPP) $(DEFS) $(INCLUDES) $(CPPFLAGS)
CPU_COMPILE_C  = $(CPUC) $(DEFS) $(INCLUDES) $(CFLAGS)
GPU_COMPILE_C  = $(GPUC) $(DEFS) $(INCLUDES) $(GPUFLAGS)
all:	ToolsGPU Tools CellularAutomata	main-glut
	$(CPU_COMPILE_CPP)  ToolsGPU.o Tools.o CellularAutomata.o main-glut.o  $(LINK)  -lcuda -lcudart -lGLEW -lGLU -lglut -lGL -o CA-GL

main-glut:
	$(CPU_COMPILE_CPP) -c main-glut.cpp

CellularAutomata:
	$(CPU_COMPILE_CPP) -c CellularAutomata.cpp

Tools:
	$(CPU_COMPILE_C) -c Tools.c

ToolsGPU:
	$(GPU_COMPILE_C) -c ToolsGPU.cu

clean:
	rm *.o

files:
	rm *.txt; rm *.dat; rm *.o
