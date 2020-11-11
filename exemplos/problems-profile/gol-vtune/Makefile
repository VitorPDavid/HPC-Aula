CPUC      = gcc
CFLAGS    = -O3 -std=c11 -m64	 #     -Wunused-variable #-Wno-conversion-null -Wdelete-non-virtual-dtor
DEFS      =
INCLUDES  =
LIBDIR   = -L/usr/lib
LIBS     = -lm
LINK     =  $(LIBDIR) $(LIBS)
CPU_COMPILE_C  = $(CPUC) $(DEFS) $(INCLUDES) $(CFLAGS)

all:
	$(CPU_COMPILE_C) main-gol.c  $(LINK)   -o gol
	$(CPU_COMPILE_C) -fopenmp main-gol-openmp-loop-x.c  $(LINK)   -o gol-openmp-loop-x
	$(CPU_COMPILE_C) -fopenmp main-gol-openmp-loop-y.c  $(LINK)   -o gol-openmp-loop-y
	$(CPU_COMPILE_C) -fopenmp main-gol-openmp-loop-t.c  $(LINK)   -o gol-openmp-loop-t


clean:
	rm gol gol-openmp-loop-x gol-openmp-loop-y gol-openmp-loop-t 
