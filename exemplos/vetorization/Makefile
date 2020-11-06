################################################################################
#
#
#  Universidade Federal Rural do Rio de Janeiro
#  por: Marcelo Zamith - zamith.marcelo@gmail.com
#  Uso de registradores vetoriais 
#  Disciplina: TM 405
################################################################################
EXEFILE     = vectorization
CPUCC       = gcc #/opt/intel/bin/icc
CPPFLAGS  = 
DEFS          = 
CFLAGS      =  -std=c99  -Ofast
INCLUDES  =	-I. 

LIBDIR   = -L/usr/lib/
         
LIBS     = -lm

LINK     =  $(LIBDIR) $(LIBS) 


all:		loop-explicitly-optimization-2cores loop-explicitly-optimization loop-implicitly-optimization loop-no-optimization main
	$(CPUCC)	$(DEFS) $(INCLUDES) $(CFLAGS)  -fopenmp loop-explicitly-optimization-2cores.o loop-explicitly-optimization.o loop-implicitly-optimization.o loop-no-optimization.o main.o $(LINK) -o $(EXEFILE)

main:
	$(CPUCC) $(DEFS) $(INCLUDES) $(CFLAGS)  -c main.c
	
loop-no-optimization:
	$(CPUCC) $(DEFS) $(INCLUDES) $(CFLAGS) -c loop-no-optimization.c
	$(CPUCC) $(DEFS) $(INCLUDES) $(CFLAGS) -S loop-no-optimization.c

loop-implicitly-optimization:
	$(CPUCC) $(DEFS) $(INCLUDES) $(CFLAGS)  -c loop-implicitly-optimization.c
	$(CPUCC) $(DEFS) $(INCLUDES) $(CFLAGS)  -S loop-implicitly-optimization.c

loop-explicitly-optimization:
	$(CPUCC) $(DEFS) $(INCLUDES) $(CFLAGS) -mavx -c loop-explicitly-optimization.c
	$(CPUCC) $(DEFS) $(INCLUDES) $(CFLAGS) -mavx -S loop-explicitly-optimization.c

loop-explicitly-optimization-2cores:
	$(CPUCC) $(DEFS) $(INCLUDES) $(CFLAGS) -mavx -c loop-explicitly-optimization-2cores.c
	$(CPUCC) $(DEFS) $(INCLUDES) $(CFLAGS) -fopenmp -mavx -S loop-explicitly-optimization-2cores.c

clean:
	rm *.o; rm $(EXEFILE)

files:
	rm *.txt; rm *.dat; rm *.o

