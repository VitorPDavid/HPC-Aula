CPUC      = nvcc
CFLAGS    = -O3	 #     -Wunused-variable #-Wno-conversion-null -Wdelete-non-virtual-dtor
DEFS      =
INCLUDES  =
LIBDIR   = -L/usr/lib
LIBS     = -lm
LINK     =  $(LIBDIR) $(LIBS)
CPU_COMPILE_C  = $(CPUC) $(DEFS) $(INCLUDES) $(CFLAGS)

all:
	$(CPU_COMPILE_C)  -ftz=false --prec-sqrt=true  --prec-div=true main-n-bodies.cu  $(LINK)   -o n-bodies-cuda
	$(CPU_COMPILE_C)  -ftz=false --prec-sqrt=true  --prec-div=true main-n-bodies-streams.cu  $(LINK)   -o n-bodies-cuda-streams
	$(CPU_COMPILE_C)  -ftz=false --prec-sqrt=true  --prec-div=true main-n-bodies-2.0.cu  $(LINK)   -o n-bodies-cuda-2.0

clean:
	rm n-bodies-cuda n-bodies-cuda-streams  n-bodies-cuda-2.0 *.bin
