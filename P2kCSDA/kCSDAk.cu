#include <stdio.h>
#include <cuda_runtime.h>
#define BLOCK_SIZE 8
#define ELECTRODES 4096
#define MATRIX_DIM 64
#define ORIGIN 64
#define BDIM 127 

	//Kernel parameters: K output matrix, Bj integral matrix (Potoworowski)
__global__ void calculateK(float * d_out, float * d_in){
	int j = BLOCK_SIZE * blockIdx.x + threadIdx.x; //row
    int k = BLOCK_SIZE * blockIdx.y + threadIdx.y; //column
    //x=0:4095
    if (j >= ELECTRODES || k > j)
    	return;
    float sum = 0;
    //Ver lo de los indices matriz julia vs c++
    for (int l = 0; l < ELECTRODES; ++l)
    {
    	int xj1 = (int) ceil((double) j/ (double) MATRIX_DIM);
    	int xj2 = j % MATRIX_DIM;
    	int xk1 = (int) ceil((double) k/ (double) MATRIX_DIM);
    	int xk2 = k % MATRIX_DIM;
    	int xl1 = (int) ceil((double) l/ (double) MATRIX_DIM);
    	int xl2 = l % MATRIX_DIM;
    	//Matrix bj is stored as an array: x + nx*y;
    	int idx1 = xk1-xl1+ORIGIN + MATRIX_DIM*(xk2-xl2+ORIGIN);	
    	int idx2 = xj1-xl1+ORIGIN + MATRIX_DIM*(xj2-xl2+ORIGIN);
    	sum +=  d_in[idx1]* d_in[idx2];
    }

    d_out[j + MATRIX_DIM*k] = sum;
}

int main(int argc, char ** argv) {
	// const float* in, float* out
	const int DATA_SIZE_IN = 127*127;
	const int DATA_SIZE_OUT = 4096*4096;
	const int ARRAY_BYTES_DR = DATA_SIZE_IN * sizeof(float);
	const int ARRAY_BYTES_H = DATA_SIZE_OUT * sizeof(float);

	// declare GPU memory pointers
	float * d_in;
	float * d_out;

	// allocate GPU memory
	cudaMalloc((void**) &d_in, ARRAY_BYTES_DR);
	cudaMalloc((void**) &d_out, ARRAY_BYTES_H);

	// transfer the array to the GPU
	cudaMemcpy(d_in, in, ARRAY_BYTES_DR, cudaMemcpyHostToDevice);
	//Set gridSize and BlockSize
	const dim3 blockSize(BLOCK_SIZE, BLOCK_SIZE, 1);  
    const dim3 gridSize(ceil(ELECTRODES/ (double) BLOCK_SIZE), ceil(ELECTRODES/(double) BLOCK_SIZE), 1);

	// launch the kernel
	calculateK<<<gridSize, blockSize>>>(d_out, d_in);

	// copy back the result array to the CPU
	cudaMemcpy(out, d_out, ARRAY_BYTES_H, cudaMemcpyDeviceToHost);

	// print out the resulting array
	for (int i =0; i < DATA_SIZE_OUT; i++) {
		printf("%f", out[i]);
		printf("\n");
	}

	cudaFree(d_in);
	cudaFree(d_out);

	return 0;
}