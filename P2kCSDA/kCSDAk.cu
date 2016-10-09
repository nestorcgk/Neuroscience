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
	//out: datos salida; in: datos entrada; block: tamaño del bloque; electrodes:numElectrodos;matdim dimension de la b0; origin:coord origen=y=x
	//Kernel parameters: K output matrix, Bj integral matrix (Potoworowski)
__global__ void calculateK(float * d_out, float * d_in,int block, int electrodes, int matdim, int origin){
	int j = block * blockIdx.x + threadIdx.x; //row
    int k = block * blockIdx.y + threadIdx.y; //column

    if(k <= j && j < electrodes) 
    {
	    float sum = 0;
	    //Ver lo de los indices matriz julia vs c++
	    for (int l = 0; l < electrodes; ++l)
	    {
	    	int xj1 = (int) ceil((double) j/ (double) matdim);
	    	int xj2 = j % matdim;
	    	int xk1 = (int) ceil((double) k/ (double) matdim);
	    	int xk2 = k % matdim;
	    	int xl1 = (int) ceil((double) l/ (double) matdim);
	    	int xl2 = l % matdim;
	    	//Matrix bj is stored as an array: x + nx*y;
	    	int idx1 = xk1-xl1+origin + matdim*(xk2-xl2+origin);	
	    	int idx2 = xj1-xl1+origin + matdim*(xj2-xl2+origin);
	    	sum +=  d_in[idx1]* d_in[idx2];
	    }
	  
    	d_out[j + electrodes*k] = sum;
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

void writeData(float* data, int matdim){
	std::ofstream output("K.dat");
	for (int j = 0; j < matdim; ++j)
	{
		for (int k = 0; k < matdim; ++k)
		{
			output << data[k + j*matdim] << "\t";
		}
		output << endl;
	}
}	

int main(int argc, char ** argv) {
	const int  BLOCK_SIZE = 8;
	const int ELECTRODES = 128;
	const int MATRIX_DIM = 64;
	const int ORIGIN = 64;

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
	calculateK<<<gridSize, blockSize>>>(d_out, d_in, BLOCK_SIZE, ELECTRODES, MATRIX_DIM, ORIGIN);

	// copy back the result array to the CPU
	cudaMemcpy(result.data(), d_out, ARRAY_BYTES_H, cudaMemcpyDeviceToHost);

	// writeData in file
	writeData(result.data(), ELECTRODES);
	
	
	

	cudaFree(d_in);
	cudaFree(d_out);

	return 0;
}