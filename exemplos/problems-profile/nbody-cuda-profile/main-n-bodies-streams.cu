#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <time.h>
#include <math.h>
#include <string.h>
#define EPSILON 1E-9
#define BLOCK_SIZE_F 512 //Work with blocks of 512 threads due to double precision - shared memory
#define BLOCK_SIZE_VP 1024 //Work with blocks of 512 threads due to double precision - shared memory
//#define STREAMS        4
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


__global__ void particleParticleForces_k(tpParticle *p1, tpParticle *p2, const double dt, const int streams){
    extern __shared__ tpParticle subParticles[];
    int i  = blockDim.x * blockIdx.x + threadIdx.x;
    tpParticle p = p1[i];
//  __shared__ tpParticle subParticles[BLOCK_SIZE];
  
    for (int blk = 0; blk < gridDim.x * streams; blk++){
        subParticles[threadIdx.x] = p2[ blockDim.x * blk + threadIdx.x];
        __syncthreads();

        for (int j = 0; j < blockDim.x; j++){
            double dx = 0.0f,  dy = 0.0f, dz = 0.0f;
            double d  = distance(&dx, &dy, &dz, p, subParticles[j]);
            p.f.x += dx * d;
            p.f.y += dy * d;
            p.f.z += dz * d;
        }//end-for (int j = 0; j < blockDim.x; j++){

    __syncthreads();
    }//end-for (int blk = 0; blk < gridDim.x; blk++){

    p1[i] = p;
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


void particleParticle (cudaStream_t  *streams , int nstreams, tpParticle *h_particles, int nParticles, int timesteps, double dt){
    int threadsF = 0,
        blocksF  = 0,
        threadsVP = 0,
        blocksVP  = 0,
        sPart = 0;

    tpParticle       *d_particles;
    
   

    sPart = nParticles / nstreams;


    threadsF  = BLOCK_SIZE_F;
    blocksF   = sPart / BLOCK_SIZE_F;
    threadsVP = BLOCK_SIZE_VP;
    blocksVP  = sPart / BLOCK_SIZE_VP;
    
    if (sPart < BLOCK_SIZE_F){
      blocksF = 1;
      threadsF = sPart;
    }

    if (sPart < BLOCK_SIZE_VP){
        blocksVP = 1;
        threadsVP = sPart;
      }
  

    
    assert(cudaMalloc((void**) &d_particles, nParticles * sizeof(tpParticle)) == cudaSuccess);
    assert(cudaMemcpy(d_particles, h_particles, nParticles * sizeof(tpParticle),  cudaMemcpyHostToDevice) == cudaSuccess);

    

    assert( ((sPart % threadsF) == 0) && ((sPart % threadsVP) == 0) && ((nParticles % nstreams) == 0) );
    //fprintf(stdout, "\n B(%d) T(%d) \n", blocks, threads);
    //fprintf(stdout, "Shared memory allocated %d\n", threads * sizeof(tpParticle));
    

    for (int t = 0; t < timesteps; t++){
      
        for (int i = 0; i < nstreams; i++){
            int offset = sPart * i;
            particleParticleForces_k<<<blocksF, threadsF, threadsF * sizeof(tpParticle), streams[i]>>>(d_particles+offset, d_particles, dt, nstreams);
            particleParticleVelocityPosition_k<<<blocksVP, threadsVP,  0, streams[i]>>>(d_particles+offset, dt);
        }

/*
        for (int i = 0; i < STREAMS; i++){
            assert( cudaStreamSynchronize(streams[i]) == cudaSuccess );
        }

        for (int i = 0; i < STREAMS; i++){
            int offset = sPart * i;
            
        }
*/
        for (int i = 0; i < nstreams; i++){
            assert( cudaStreamSynchronize(streams[i]) == cudaSuccess );
        }
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
        flagSave = atoi(av[3]),
        nstreams = atoi(av[4]);

    cudaStream_t  *streams       =  (cudaStream_t *) malloc (nstreams * sizeof(cudaStream_t));
    double         dt            =  0.00001f;
    tpParticle    *h_Particles   = NULL;
   

    fprintf(stdout, "\nParcile system particle to particle \n");
    fprintf(stdout, "Memory used %lu bytes \n", nParticles * sizeof(tpParticle));

    assert(cudaDeviceReset()== cudaSuccess);
    assert(cudaMallocHost((void**) (&h_Particles), nParticles * sizeof(tpParticle)) == cudaSuccess);
    assert(h_Particles != NULL);
    
   
    for (int i = 0; i < nstreams; i++)
       assert(cudaStreamCreate(&streams[i]) == cudaSuccess);

    initialCondition(h_Particles, nParticles);

    particleParticle(streams, nstreams, h_Particles, nParticles, timesteps, dt);

    if (flagSave == 1)
      printLog(h_Particles, nParticles, timesteps);

    for (int i = 0; i < nstreams; i++)
      assert(cudaStreamDestroy(streams[i]) == cudaSuccess); 
  
    cudaFreeHost(h_Particles);   
    



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
