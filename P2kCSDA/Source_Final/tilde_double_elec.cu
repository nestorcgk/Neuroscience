#include <stdio.h>
#include <cuda_runtime.h>
#include <fstream>
#include <iostream>
#include <string>
#include <sstream>
#include <vector>
#include <utility>
#include <boost/tokenizer.hpp>
#include "kCSDAk.h"


using namespace std;
using namespace boost;
	//out: datos salida; in: datos entrada; block: tamaño del bloque; electrodes:numElectrodos;matdim dimension de la b0; origin:coord origen=y=x
	//Kernel parameters: K output matrix, Bj integral matrix (Potoworowski)
__global__ void calculateKtlower(double * d_out, double * d_in, double * d_inTilde, double * d_jlist, double * d_klist,int block, int electrodes, int matdim, int origin){
	int k = block * blockIdx.x + threadIdx.x; //column
    int j = block * blockIdx.y + threadIdx.y; //row

    if(j >= k && j < electrodes) {
    	
    	double sum = 0;
	    //Ver lo de los indices matriz julia vs c++
	    for (int l = 0; l < electrodes; ++l)
	    {
	    	//Coordenadas funcionan igual con desfase [1]
	    	//CoordenadasTotal[j]
	    	int xj1 = (int) d_jlist[j];//(int) ceil((double) j/ (double) matdim);
	    	int xj2 = (int) d_klist[j];//j % matdim;
	    	//CoordenasTodal[k]
	    	int xk1 = (int) d_jlist[k];//(int) ceil((double) k/ (double) matdim);
	    	int xk2 = (int) d_klist[k];//k % matdim;
	    	//Coordenastotal[l]
	    	int xl1 = (int) d_jlist[l];//(int) ceil((double) l/ (double) matdim);
	    	int xl2 = (int) d_klist[l];//l % matdim;
	    	//Matrix bj is stored as an array: Col + Row*dim;
	    	//xk-xl+const
	    	int idx1 = xk2-xl2+origin + (xk1-xl1+origin)*matdim;
	    	//xj-xl+const	
	    	int idx2 = xj2-xl2+origin + (xj1-xl1+origin)*matdim;
	    	sum += d_in[idx1] * d_inTilde[idx2];//d_in[xj2 + xj1*matdim];  
	    }
	    //Equivalente a d_out[j,k] = sum
    	d_out[k + electrodes*j] = sum;
    	
    }
    
	    
}

__global__ void calculateKtupper(double * d_out, double * d_in, double * d_inTilde, double * d_jlist, double * d_klist,int block, int electrodes, int matdim, int origin){
	int k = block * blockIdx.x + threadIdx.x; //column
    int j = block * blockIdx.y + threadIdx.y; //row

    if(k >= j && k < electrodes) {
    	
    	double sum = 0;
	    //Ver lo de los indices matriz julia vs c++
	    for (int l = 0; l < electrodes; ++l)
	    {
	    	//Coordenadas funcionan igual con desfase [1]
	    	//CoordenadasTotal[j]
	    	int xj1 = (int) d_jlist[j];//(int) ceil((double) j/ (double) matdim);
	    	int xj2 = (int) d_klist[j];//j % matdim;
	    	//CoordenasTodal[k]
	    	int xk1 = (int) d_jlist[k];//(int) ceil((double) k/ (double) matdim);
	    	int xk2 = (int) d_klist[k];//k % matdim;
	    	//Coordenastotal[l]
	    	int xl1 = (int) d_jlist[l];//(int) ceil((double) l/ (double) matdim);
	    	int xl2 = (int) d_klist[l];//l % matdim;
	    	//Matrix bj is stored as an array: Col + Row*dim;
	    	//xk-xl+const
	    	int idx1 = xk2-xl2+origin + (xk1-xl1+origin)*matdim;
	    	//xj-xl+const	
	    	int idx2 = xj2-xl2+origin + (xj1-xl1+origin)*matdim;
	    	sum += d_in[idx1] * d_inTilde[idx2];//d_in[xj2 + xj1*matdim];  
	    }
	    //Equivalente a d_out[j,k] = sum
    	d_out[k + electrodes*j] = sum;
    	
    }
    
	    
}

void readData(string name, double* data){
	ifstream myfile (name);
  	//std::vector<double> data(127*127);
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

void writeData(double* data, int matdim){
	remove( "Ktilde_complete.dat" );
	std::ofstream output("Ktilde_complete.dat");
	for (int j = 0; j < matdim; ++j)
	{
		for (int k = 0; k < matdim; ++k)
		{
			output << data[k + j*matdim] << "\t";
		}
		output << endl;
	}
}	

void genCoords(double* jlist, double* klist,int matdim){
	int i = 0;
	for (int j = 0; j < matdim; ++j)
	{
		for (int k = 0; k < matdim; ++k)
		{
			jlist[i] = j;
			klist[i] = k;
			i++;
		}
	}
}

void readElec(string name, double* jlist, double* klist, int matdim){
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
		bool isj = true;
	    for (const auto& t : tokens) 
	    {		
	    		if(isj)
	    		{
	    			jlist[i] = stod(t);
	    			isj = false;
	    		}else{
	    			klist[i] = stod(t);
	    			i++;
	    			isj = true;
	    		}
		}	    
	}
	myfile.close();
	}
}



int main(int argc, char ** argv) {
	const int BLOCK_SIZE = 8;
	std::istringstream iss( argv[4] );
    int val;
    iss >> val;
	const int ELECTRODES = val;
	const int ORIGIN = 63;

	// const double* in, double* out
	const int DATA_SIZE_IN = 127*127;
	const int DATA_SIZE_OUT = 4096*4096;
	const int ARRAY_BYTES_DR = DATA_SIZE_IN * sizeof(double);
	const int ARRAY_BYTES_H = DATA_SIZE_OUT * sizeof(double);
	const int J_LIST_SIZE_IN = 4096;
	const int K_LIST_SIZE_IN = 4096;
	const int ARRAY_BYTES_J_LIST = J_LIST_SIZE_IN * sizeof(double);
	const int ARRAY_BYTES_K_LIST = K_LIST_SIZE_IN * sizeof(double);

	std::vector<double> data(DATA_SIZE_IN);
	std::vector<double> dataTilde(DATA_SIZE_IN);
	std::vector<double> result(DATA_SIZE_OUT);

	//Generate list of proper electrodes
	std::vector<double> jlist(4096);
	std::vector<double> klist(4096);
	genCoords(jlist.data(), klist.data(),64);

	// declare GPU memory pointers
	double * d_in;
	double * d_inTilde;
	double * d_out;
	double * d_jlist;
	double * d_klist;

	//Read Data
	readData(argv[1],data.data());
	readData(argv[2],dataTilde.data());
	readElec(argv[3],jlist.data(),klist.data(),ELECTRODES);
	

	
	//Sí lee correctamente
	//for (int i = 0; i < data.size(); ++i)
	//{
	//	cout << dataTilde[4095] << "\n";
	//	cout << data[4095] << "\n";
	//}
	

	// allocate GPU memory
	cudaMalloc((void**) &d_in, ARRAY_BYTES_DR);
	cudaMalloc((void**) &d_inTilde, ARRAY_BYTES_DR);
	cudaMalloc((void**) &d_out, ARRAY_BYTES_H);
	cudaMalloc((void**) &d_jlist, ARRAY_BYTES_J_LIST);
	cudaMalloc((void**) &d_klist, ARRAY_BYTES_K_LIST);




	// transfer the array to the GPU
	
	cudaMemcpy(d_in, data.data(), ARRAY_BYTES_DR, cudaMemcpyHostToDevice);
	cudaMemcpy(d_inTilde, dataTilde.data(), ARRAY_BYTES_DR, cudaMemcpyHostToDevice);
	cudaMemcpy(d_jlist, jlist.data(), ARRAY_BYTES_J_LIST, cudaMemcpyHostToDevice);
	cudaMemcpy(d_klist, klist.data(), ARRAY_BYTES_K_LIST, cudaMemcpyHostToDevice);

	//Set gridSize and BlockSize
	const dim3 blockSize(BLOCK_SIZE, BLOCK_SIZE, 1);  
    const dim3 gridSize(ceil(ELECTRODES/ (double) BLOCK_SIZE), ceil(ELECTRODES/(double) BLOCK_SIZE), 1);

	// launch the kernel
	calculateKtlower<<<gridSize, blockSize>>>(d_out, d_in, d_inTilde, d_jlist , d_klist, BLOCK_SIZE, ELECTRODES, 127, ORIGIN);
	calculateKtupper<<<gridSize, blockSize>>>(d_out, d_in, d_inTilde, d_jlist , d_klist, BLOCK_SIZE, ELECTRODES, 127, ORIGIN);
	
	// copy back the result array to the CPU
	cudaMemcpy(result.data(), d_out, ARRAY_BYTES_H, cudaMemcpyDeviceToHost);

	// writeData in file
	writeData(result.data(), ELECTRODES);
	
	cudaFree(d_in);
	cudaFree(d_out);
	
	return 0;
}