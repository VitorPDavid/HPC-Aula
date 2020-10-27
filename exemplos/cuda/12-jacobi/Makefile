CPUC      = /usr/local/cuda/bin/nvcc
CFLAGS    = -O3 	 #     -Wunused-variable #-Wno-conversion-null -Wdelete-non-virtual-dtor
DEFS      =
INCLUDES  =
LIBDIR   = -L/usr/lib
LIBS     = -lm
LINK     =  $(LIBDIR) $(LIBS)
CPU_COMPILE_C  = $(CPUC) $(DEFS) $(INCLUDES) $(CFLAGS)

all:
	$(CPU_COMPILE_C) main-jacobi.cu  $(LINK)   -o jacobi-cuda

clean:
	rm jacobi-cuda
