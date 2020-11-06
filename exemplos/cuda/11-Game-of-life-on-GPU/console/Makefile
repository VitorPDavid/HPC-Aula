CPUC      = gcc
GPUC      = /usr/local/cuda/bin/nvcc # atenção o caminho do compilador
CFLAGS    = -O3 --std=c11 -m64	 #     -Wunused-variable #-Wno-conversion-null -Wdelete-non-virtual-dtor
GFLAGS    = -O3  -m64	 #     -Wunused-variable #-Wno-conversion-null -Wdelete-non-virtual-dtor
DEFS      =
INCLUDES  = -I/usr/local/cuda/include
LIBDIR   =  -L/usr/lib -L/usr/local/cuda/lib64/
LIBS     = -lm
LINK     =  $(LIBDIR) $(LIBS)
CPU_COMPILE_C  = $(CPUC) $(DEFS) $(INCLUDES) $(CFLAGS)
GPU_COMPILE_C  = $(GPUC) $(DEFS) $(INCLUDES) $(GFLAGS)

cpu:
	$(CPU_COMPILE_C) main-gol.c  $(LINK)   -o gol

gpu:
	$(GPU_COMPILE_C) main-gol-cuda.cu  $(LINK)   -o gol-cuda
clean:
	rm gol gol-cuda
