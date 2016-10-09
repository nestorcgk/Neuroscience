#include <stdio.h>
#include <cuda_runtime.h>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>
#include <utility>
#include <boost/tokenizer.hpp>
#include "kCSDAk.h"


using namespace std;
using namespace boost;

	//Kernel parameters: K output matrix, Bj integral matrix (Potoworowski)
__global__ void calculateK(float * d_out, float * d_in,int block, int electrodes, int matdim ){
	int j = block * blockIdx.x + threadIdx.x; //row
    int k = block * blockIdx.y + threadIdx.y; //column

    /*
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
    //d_out[j + MATRIX_DIM*k] = sum;
    */
    if(j < electrodes && k < electrodes) //j <= k &&
    {
    	d_out[j + electrodes*k] = j;
    }
    
}

void readData(string name, float* data){
	ifstream myfile (name);
  	//std::vector<float> data(127*127);
	//cout.precision(17);
	int i = 0;
	std::string line;

	if(myfile.is_open())
	{
		char_separator<char> sep("\t");
	while(getline(myfile, line)) 
	{
		tokenizer<char_separator<char>> tokens(line, sep);
	    for (const auto& t : tokens) 
	    {
	    		data[i] = stod(t);
				i++;
		}	    
	}
	myfile.close();
	}
	}

int main(int argc, char ** argv) {
	const int  BLOCK_SIZE = 8;
	const int ELECTRODES = 128;
	const int MATRIX_DIM = 64;
	//const int ORIGIN = 64;

	// const float* in, float* out
	const int DATA_SIZE_IN = 127*127;
	const int DATA_SIZE_OUT = 4096*4096;
	const int ARRAY_BYTES_DR = DATA_SIZE_IN * sizeof(float);
	const int ARRAY_BYTES_H = DATA_SIZE_OUT * sizeof(float);
	std::vector<float> data(DATA_SIZE_IN);
	std::vector<float> result(DATA_SIZE_OUT);

	// declare GPU memory pointers
	float * d_in;
	float * d_out;

	//Read Data
	readData(argv[1],data.data());
	/* Sí lee correctamente
	for (int i = 0; i < data.size(); ++i)
	{
		cout << data[i] << "\n";
	}
	*/

	// allocate GPU memory
	cudaMalloc((void**) &d_in, ARRAY_BYTES_DR);
	cudaMalloc((void**) &d_out, ARRAY_BYTES_H);

	// transfer the array to the GPU
	cudaMemcpy(d_in, data.data(), ARRAY_BYTES_DR, cudaMemcpyHostToDevice);
	//Set gridSize and BlockSize
	const dim3 blockSize(BLOCK_SIZE, BLOCK_SIZE, 1);  
    const dim3 gridSize(ceil(ELECTRODES/ (double) BLOCK_SIZE), ceil(ELECTRODES/(double) BLOCK_SIZE), 1);

	// launch the kernel
	calculateK<<<gridSize, blockSize>>>(d_out, d_in, BLOCK_SIZE, ELECTRODES, MATRIX_DIM);

	// copy back the result array to the CPU
	cudaMemcpy(result.data(), d_out, ARRAY_BYTES_H, cudaMemcpyDeviceToHost);

	// print out the resulting array
	
	for (int i =0; i < 128*128; i++) {
		cout << i << ": " << result[i] << "\n";
		
	}
	

	cudaFree(d_in);
	cudaFree(d_out);

	return 0;
}