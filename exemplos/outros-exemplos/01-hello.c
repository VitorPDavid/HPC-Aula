#include <stdio.h>
#include <stdlib.h>

int main(int ac, char**av){

    #pragma omp parallel
    {
        printf("Hello, world.\n");
    }

    return EXIT_SUCCESS;
}
