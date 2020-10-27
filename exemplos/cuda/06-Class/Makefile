CUDACC    = /usr/local/cuda/bin/nvcc
NVCCFLAGS = -arch=sm_11 -m64  #--compiler-options -fno-strict-aliasing -use_fast_math 
CPUCC     = g++
EXEFILE   = Class.bin
CPPFLAGS  =  -m64 
DEFS      =
INCLUDES  = -I.                             \
            -I/usr/include/cuda             \
            -I/usr/local/cuda/include

LIBDIR   =  -L/usr/lib                      \
            -L/usr/local/cuda/lib

LIBS     =  -lm -lcuda -lcudart 
LINK     =  $(LIBDIR) $(LIBS)

C_COMPILE = $(CPUCC) $(DEFS) $(INCLUDES) $(CPPFLAGS)
G_COMPILE = $(CUDACC) $(DEFS) $(INCLUDES) $(NVCCFLAGS)

all:       veiculos   kernel main
	$(C_COMPILE) $(LINK)    veiculos.o kernel.o  main.o   -o $(EXEFILE)

main:
	$(C_COMPILE) -c main.cpp

kernel:
	$(G_COMPILE) -c kernel.cu

	
veiculos:
	$(G_COMPILE) -c veiculos.cu

clean:
	rm *.o; rm *.bin
