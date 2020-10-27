EXEFILE   = Demo_x64.bin
CPUCC     = g++
CPPFLAGS  = -g #-m64 -O3 
CUDACC    = nvcc
NVCCFLAGS = -g -m64 #-arch=sm_11 -m64 -O3  --compiler-options -fno-strict-aliasing -use_fast_math
DEFS      =

INCLUDES  = -I.                           \
            -I/opt/local/include \
            -I/usr/local/include/opencv \
            -I/usr/local/cuda/include

LIBDIR   =  -L/usr/lib                          \
            -L/opt/local/lib   \
            -L/usr/local/cuda/lib

LIBS     =  -lm  -lopencv_core -lopencv_highgui -lopencv_imgproc -lcuda -lcudart 

LINK     =  $(LIBDIR) $(LIBS)

C_COMPILE = $(CPUCC) $(DEFS) $(INCLUDES) $(CPPFLAGS)
G_COMPILE = $(CUDACC) $(DEFS) $(INCLUDES) $(NVCCFLAGS)


all:    main kernel
	$(C_COMPILE) main.o kernel.o  $(LINK) -o $(EXEFILE)

main:
	$(C_COMPILE) -c main.cpp

kernel:
	$(G_COMPILE)  -c kernel.cu

clean:
	rm *.o; rm $(EXEFILE)
