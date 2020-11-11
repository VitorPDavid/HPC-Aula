#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <time.h>
#include <math.h>
#include <string.h>
#define EPSILON 1E-9
#define BLOCK_SIZE_F 512 //Work with blocks of 512 threads due to double precision - shared memory
#define BLOCK_SIZE_VP 1024 //Work with blocks of 512 threads due to double precision - shared memory
/*Declarando as structs de particula e forca*/
struct stCoord{
    double x,
          y,
          z;
};
typedef struct stCoord tpCoord;
struct stParticle
{
    tpCoord p,
            v,
            f;

};
typedef struct stParticle tpParticle;
//--------------------------------------------------------------------------------------------------------


__device__ double distance(  double* dx,
                            double* dy,
                            double* dz,
                            const tpParticle A,
                            const tpParticle B){
            double x = A.p.x - B.p.x;
            double y = A.p.y - B.p.y;
            double z = A.p.z - B.p.z;

            *dx = x; *dy = y; *dz = z;
            x *= x; y *= y; z *= z;
            return 1.0 / sqrt((double)x + y + z + EPSILON);

}


__global__ void particleParticleForces_k(tpParticle *particles, const double dt){
    extern __shared__ tpParticle subParticles[];
    int i  = blockDim.x * blockIdx.x + threadIdx.x;
//  __shared__ tpParticle subParticles[BLOCK_SIZE];
  
    for (int blk = 0; blk < gridDim.x; blk++){
        subParticles[threadIdx.x] = particles[ blockDim.x * blk + threadIdx.x];
        __syncthreads();

        for (int j = 0; j < blockDim.x; j++){
            double dx = 0.0f,  dy = 0.0f, dz = 0.0f;
            double d  = distance(&dx, &dy, &dz, particles[i], subParticles[j]);
            particles[i].f.x += dx * d;
            particles[i].f.y += dy * d;
            particles[i].f.z += dz * d;
        }//end-for (int j = 0; j < blockDim.x; j++){

    __syncthreads();
    }//end-for (int blk = 0; blk < gridDim.x; blk++){

    
}

__global__ void particleParticleVelocityPosition_k(tpParticle *particles, const double dt){
    int i  = blockDim.x * blockIdx.x + threadIdx.x;

    particles[i].v.x += dt * particles[i].f.x;
    particles[i].v.y += dt * particles[i].f.y;
    particles[i].v.z += dt * particles[i].f.z;

    particles[i].p.x += dt * particles[i].v.x;
    particles[i].p.y += dt * particles[i].v.y;
    particles[i].p.z += dt * particles[i].v.z;
}


void particleParticle (tpParticle *h_particles, int nParticles, int timesteps, double dt){
    int threadsF = BLOCK_SIZE_F,
        blocksF  = nParticles / BLOCK_SIZE_F,
        threadsVP = BLOCK_SIZE_VP,
        blocksVP  = nParticles / BLOCK_SIZE_VP;

    tpParticle *d_particles;


    if (nParticles < BLOCK_SIZE_F){
      blocksF = 1;
      threadsF = nParticles;
    }

    if (nParticles < BLOCK_SIZE_VP){
        blocksVP = 1;
        threadsVP = nParticles;
      }
  

    assert(cudaDeviceReset()== cudaSuccess);

    assert(cudaMalloc((void**) &d_particles, nParticles * sizeof(tpParticle)) == cudaSuccess);
    assert(cudaMemcpy(d_particles, h_particles, nParticles * sizeof(tpParticle),  cudaMemcpyHostToDevice) == cudaSuccess);


    assert( ((nParticles % threadsF) == 0) && ((nParticles % threadsVP) == 0) );
    //fprintf(stdout, "\n B(%d) T(%d) \n", blocks, threads);
    //fprintf(stdout, "Shared memory allocated %d\n", threads * sizeof(tpParticle));
    

    for (int t = 0; t < timesteps; t++){
      //setup_kernel<<<blocos, threads,0, mStreams[i] >>>(time (NULL) + offset, mStates+offset);

      particleParticleForces_k<<<blocksF, threadsF, threadsF * sizeof(tpParticle)>>>(d_particles, dt);
      //assert( cudaDeviceSynchronize() == cudaSuccess);

      particleParticleVelocityPosition_k<<<blocksVP, threadsVP>>>(d_particles, dt);
      //assert( cudaDeviceSynchronize() == cudaSuccess);
    }//end-for (int t = 0; t < timesteps; t++){
    
    assert(cudaMemcpy(h_particles, d_particles, nParticles * sizeof(tpParticle),  cudaMemcpyDeviceToHost) == cudaSuccess);
    cudaFree(d_particles);
}

//--------------------------------------------------------------------------------------------------------
void printLog(tpParticle *particles, int nParticles, int timestep);
void initialCondition(tpParticle *particles, int nParticles);

int main (int ac, char **av){
    int timesteps  = atoi(av[1]),
        nParticles = atoi(av[2]),
        flagSave = atoi(av[3]);


    double              dt =  0.00001f;
    tpParticle *particles = NULL;


    fprintf(stdout, "\nParcile system particle to particle \n");
    fprintf(stdout, "Memory used %lu bytes \n", nParticles * sizeof(tpParticle));

    particles = (tpParticle *) malloc ( nParticles * sizeof(tpParticle));
    assert(particles != NULL);

    initialCondition(particles, nParticles);

    particleParticle(particles, nParticles, timesteps, dt);

    if (flagSave == 1)
      printLog(particles, nParticles, timesteps);
    free(particles);



}

void printLog(tpParticle *particles, int nParticles, int timestep){
    char fileName[128];
    sprintf(fileName, "%s-%d-log.bin", __FILE__,  timestep);
    fprintf(stdout, "Saving file [%s] ", fileName); fflush(stdout);
    FILE *ptr = fopen(fileName, "wb+");
    //fwrite ((const void*)particles , sizeof(tpParticle), nParticles, ptr);
    for(int i = 0; i < nParticles; i++)
        fprintf(ptr, "%d \t %.10f %.10f %.10f \t %.10f %.10f %.10f \t %.10f %.10f %.10f \n", i,  particles[i].p.x, particles[i].p.y, particles[i].p.z,  particles[i].v.x, particles[i].v.y, particles[i].v.z, particles[i].f.x, particles[i].f.y, particles[i].f.z);


    fclose(ptr);
    fprintf(stdout, "[OK]\n"); fflush(stdout);
}

void initialCondition(tpParticle *particles, int nParticles){

    srand(42);

    memset(particles, 0x00, nParticles * sizeof(tpParticle));

    for (int i = 0; i < nParticles ; i++){
        particles[i].p.x =  2.0 * (rand() / (double)RAND_MAX) - 1.0;
        particles[i].p.y =  2.0 * (rand() / (double)RAND_MAX) - 1.0;
        particles[i].p.z =  2.0 * (rand() / (double)RAND_MAX) - 1.0;
      }




}
