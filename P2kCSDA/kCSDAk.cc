#include "kCSDAk.h"
#include <fstream>
#include <iostream>
#include <string>
#include <vector>
#include <utility>
#include <boost/tokenizer.hpp>

using namespace std;
using namespace boost;

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

void genCoords(float* jlist, float* klist,int matdim){
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


int main() {
	std::vector<float> jlist(4096);
	std::vector<float> klist(4096);
	genCoords(jlist.data(), klist.data(),64);
	for (int i = 0; i < 4096; ++i)
	{
		cout<<"Coorda["<<i<<"]: "<<jlist[i]<<" "<<klist[i]<<endl;
	}


	

	
	
  
}