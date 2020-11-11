#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <time.h>
#include <math.h>
#include <string.h>
#define EPSILON 1E-9
#define BLOCK_SIZE 1024
#define ALING 64


__device__ double distance( double* dx, double* dy, double* dz,
                             const double Ax,  const  double Ay, const  double Az,
                             const double Bx,  const  double By,  const  double Bz){
  
      double x = Ax - Bx;
      double y = Ay - By;
      double z = Az - Bz;

      *dx = x; *dy = y; *dz = z;
      x *= x; y *= y; z *= z;
      return 1.0 / sqrt((double)x + y + z + EPSILON);

}



__global__ void particleParticleForces_k (  double *px, double *py, double *pz,
                                            double *fx, double *fy, double *fz, double dt){
  extern __shared__  double buff[];
  double *sub_px = &buff[0],
          *sub_py = &buff[gridDim.x],
          *sub_pz = &buff[gridDim.x * 2];

  int i  = blockDim.x * blockIdx.x + threadIdx.x;
  double pX = px[i];
  double pY = py[i];
  double pZ = pz[i];

  double fX = fx[i];
  double fY = fy[i];
  double fZ = fz[i];
  
  for (int blk = 0; blk < gridDim.x; blk++){
      sub_px[threadIdx.x] = px[ blockDim.x * blk + threadIdx.x];
      sub_py[threadIdx.x] = py[ blockDim.x * blk + threadIdx.x];
      sub_pz[threadIdx.x] = pz[ blockDim.x * blk + threadIdx.x];
      __syncthreads();

    for (int j = 0; j < blockDim.x; j++){
      double dx = 0.0f,  dy = 0.0f, dz = 0.0f;
      double d  = distance(&dx, &dy, &dz, pX, pY, pZ, sub_px[j], sub_py[j], sub_pz[j]);

      fX += dx * d;
      fY += dy * d;
      fZ += dz * d;
    }
    __syncthreads();
  }

  fx[i] = fX;
  fy[i] = fY;
  fz[i] = fZ;
  
  
}

__global__ void particleParticleVelocityPosition_k (  double *px, double *py, double *pz,
                                                      double *vx, double *vy, double *vz,
                                                      double *fx, double *fy, double *fz, double dt){
  int i  = blockDim.x * blockIdx.x + threadIdx.x;
  vx[i] += dt * fx[i];
  vy[i] += dt * fy[i];
  vz[i] += dt * fz[i];

  px[i] += dt * vx[i];
  py[i] += dt * vy[i];
  pz[i] += dt * vz[i];

  
}

void particleParticle (double *px, double *py, double *pz,
                       double *vx, double *vy, double *vz,
                       double *fx, double *fy, double *fz,
                       int nParticles, int timesteps, double dt){
    int threads = BLOCK_SIZE,
    blocks  = nParticles / BLOCK_SIZE;
    if (nParticles < 1024){
      blocks = 1;
      threads = nParticles;
    }

    fprintf(stdout, "\n B(%d) T(%d) shared memory %d \n", blocks, threads, 3 * threads * sizeof(double));

    for (int t = 0; t < timesteps; t++){
      particleParticleForces_k<<<blocks, threads, 3 * threads * sizeof(double) >>>(px, py, pz, fx, fy, fz, dt);
      particleParticleVelocityPosition_k<<<blocks, threads  >>>(px, py, pz, vx, vy, vz, fx, fy, fz, dt);
      assert( cudaDeviceSynchronize() == cudaSuccess);
    }//end-for (int t = 0; t < timesteps; t++){

}//end-void particleParticle


//-----------------------------------------------------------------------------------------------------
void printLog(double *px, double *py, double *pz,
  double *vx, double *vy, double *vz,
  double *fx, double *fy, double *fz, int nParticles, int timestep);
void initialCondition(double *px, double *py, double *pz,
          double *vx, double *vy, double *vz,
          double *fx, double *fy, double *fz, int nParticles);
//-----------------------------------------------------------------------------------------------------
int main (int ac, char **av){
  int timesteps  = atoi(av[1]),
      nParticles = atoi(av[2]),
      flagSave = atoi(av[3]);

  double  dt =  0.00001f,
          *h_px = NULL, *h_py = NULL, *h_pz = NULL,
          *h_vx = NULL, *h_vy = NULL, *h_vz = NULL,
          *h_fx = NULL, *h_fy = NULL, *h_fz = NULL,

          *d_px = NULL, *d_py = NULL, *d_pz = NULL,
          *d_vx = NULL, *d_vy = NULL, *d_vz = NULL,
          *d_fx = NULL, *d_fy = NULL, *d_fz = NULL;


    fprintf(stdout, "\nParcile system particle to particle \n");
    fprintf(stdout, "Memory used %lu bytes \n", nParticles * sizeof(double) * 9);

    h_px = (double *) aligned_alloc(ALING, nParticles * sizeof(double));
    assert(h_px != NULL);
    h_py = (double *) aligned_alloc(ALING, nParticles * sizeof(double));
    assert(h_py != NULL);
    h_pz = (double *) aligned_alloc(ALING, nParticles * sizeof(double));
    assert(h_pz != NULL);
//-------------------------
    h_vx = (double *) aligned_alloc(ALING, nParticles * sizeof(double));
    assert(h_vx != NULL);
    h_vy = (double *) aligned_alloc(ALING, nParticles * sizeof(double));
    assert(h_vy != NULL);
    h_vz = (double *) aligned_alloc(ALING, nParticles * sizeof(double));
    assert(h_vz != NULL);

//-------------------------
    h_fx = (double *) aligned_alloc(ALING, nParticles * sizeof(double));
    assert(h_fx != NULL);
    h_fy = (double *) aligned_alloc(ALING, nParticles * sizeof(double));
    assert(h_fy != NULL);
    h_fz = (double *) aligned_alloc(ALING, nParticles * sizeof(double));
    assert(h_fz != NULL);
//-------------------------

    initialCondition(h_px, h_py, h_pz,
                     h_vx, h_vy, h_vz,
                     h_fx, h_fy, h_fz, nParticles);

    assert(cudaMalloc((void**) &d_px, nParticles * sizeof(double)) == cudaSuccess);
    assert(cudaMemcpy(d_px, h_px, nParticles * sizeof(double),  cudaMemcpyHostToDevice) == cudaSuccess);

    assert(cudaMalloc((void**) &d_py, nParticles * sizeof(double)) == cudaSuccess);
    assert(cudaMemcpy(d_py, h_py, nParticles * sizeof(double),  cudaMemcpyHostToDevice) == cudaSuccess);

    assert(cudaMalloc((void**) &d_pz, nParticles * sizeof(double)) == cudaSuccess);
    assert(cudaMemcpy(d_pz, h_pz, nParticles * sizeof(double),  cudaMemcpyHostToDevice) == cudaSuccess);
    //-----
    assert(cudaMalloc((void**) &d_vx, nParticles * sizeof(double)) == cudaSuccess);
    assert(cudaMemcpy(d_vx, h_vx, nParticles * sizeof(double),  cudaMemcpyHostToDevice) == cudaSuccess);

    assert(cudaMalloc((void**) &d_vy, nParticles * sizeof(double)) == cudaSuccess);
    assert(cudaMemcpy(d_vy, h_vy, nParticles * sizeof(double),  cudaMemcpyHostToDevice) == cudaSuccess);

    assert(cudaMalloc((void**) &d_vz, nParticles * sizeof(double)) == cudaSuccess);
    assert(cudaMemcpy(d_vz, h_vz, nParticles * sizeof(double),  cudaMemcpyHostToDevice) == cudaSuccess);
    //-----
    assert(cudaMalloc((void**) &d_fx, nParticles * sizeof(double)) == cudaSuccess);
    assert(cudaMemcpy(d_fx, h_fx, nParticles * sizeof(double),  cudaMemcpyHostToDevice) == cudaSuccess);

    assert(cudaMalloc((void**) &d_fy, nParticles * sizeof(double)) == cudaSuccess);
    assert(cudaMemcpy(d_fy, h_fy, nParticles * sizeof(double),  cudaMemcpyHostToDevice) == cudaSuccess);

    assert(cudaMalloc((void**) &d_fz, nParticles * sizeof(double)) == cudaSuccess);
    assert(cudaMemcpy(d_fz, h_fz, nParticles * sizeof(double),  cudaMemcpyHostToDevice) == cudaSuccess);



    
    particleParticle(d_px, d_py, d_pz, d_vx, d_vy, d_vz, d_fx, d_fy, d_fz, nParticles, timesteps, dt);
    

    assert(cudaMemcpy(h_px, d_px, nParticles * sizeof(double),  cudaMemcpyDeviceToHost) == cudaSuccess); 
    assert(cudaMemcpy(h_py, d_py, nParticles * sizeof(double),  cudaMemcpyDeviceToHost) == cudaSuccess);
    assert(cudaMemcpy(h_pz, d_pz, nParticles * sizeof(double),  cudaMemcpyDeviceToHost) == cudaSuccess);

    assert(cudaMemcpy(h_vx, d_vx, nParticles * sizeof(double),  cudaMemcpyDeviceToHost) == cudaSuccess);
    assert(cudaMemcpy(h_vy, d_vy, nParticles * sizeof(double),  cudaMemcpyDeviceToHost) == cudaSuccess); 
    assert(cudaMemcpy(h_vz, d_vz, nParticles * sizeof(double),  cudaMemcpyDeviceToHost) == cudaSuccess);

    assert(cudaMemcpy(h_fx, d_fx, nParticles * sizeof(double),  cudaMemcpyDeviceToHost) == cudaSuccess);
    assert(cudaMemcpy(h_fy, d_fy, nParticles * sizeof(double),  cudaMemcpyDeviceToHost) == cudaSuccess);
    assert(cudaMemcpy(h_fz, d_fz, nParticles * sizeof(double),  cudaMemcpyDeviceToHost) == cudaSuccess);

//    printLog(h_px, h_py, h_pz, h_vx, h_vy, h_vz, h_fx, h_fy, h_fz,  nParticles, timesteps);

    if (flagSave == 1)
      printLog(h_px, h_py, h_pz, h_vx, h_vy, h_vz, h_fx, h_fy, h_fz, nParticles, timesteps);

    free(h_px);free(h_py); free(h_pz);
    free(h_vx);free(h_vy); free(h_vz);
    free(h_fx);free(h_fy); free(h_fz);


    cudaFree(d_px);cudaFree(d_py); cudaFree(d_pz);
    cudaFree(d_vx);cudaFree(d_vy); cudaFree(d_vz);
    cudaFree(d_fx);cudaFree(d_fy); cudaFree(d_fz);



}


/*Declarando as structs de particula e forca*/
void printLog(double *px, double *py, double *pz,
  double *vx, double *vy, double *vz,
  double *fx, double *fy, double *fz, int nParticles, int timestep){
  char fileName[128];
  sprintf(fileName, "%s-%d-log.bin", __FILE__,  timestep);
  fprintf(stdout, "Saving file [%s] ", fileName); fflush(stdout);
  FILE *ptr = fopen(fileName, "w+");
  for(int i = 0; i < nParticles; i++){
    fprintf(ptr, "%d \t %.10f %.10f %.10f \t %.10f %.10f %.10f \t %.10f %.10f %.10f \n", i,  px[i], py[i], pz[i], vx[i], vy[i], vz[i], fx[i], fy[i], fz[i]);

  }
  fclose(ptr);
  fprintf(stdout, "[OK]\n"); fflush(stdout);
}
void initialCondition(double *px, double *py, double *pz,
          double *vx, double *vy, double *vz,
          double *fx, double *fy, double *fz, int nParticles){

    srand(42);
    memset(vx, 0x00, nParticles * sizeof(double));
    memset(vy, 0x00, nParticles * sizeof(double));
    memset(vz, 0x00, nParticles * sizeof(double));

    memset(fx, 0x00, nParticles * sizeof(double));
    memset(fy, 0x00, nParticles * sizeof(double));
    memset(fz, 0x00, nParticles * sizeof(double));

    for (int i = 0; i < nParticles ; i++){
        px[i] =  2.0 * (rand() / (double)RAND_MAX) - 1.0;
        py[i] =  2.0 * (rand() / (double)RAND_MAX) - 1.0;
        pz[i] =  2.0 * (rand() / (double)RAND_MAX) - 1.0;
    }//end-for (int i = 0; i < nParticles ; i++){

}