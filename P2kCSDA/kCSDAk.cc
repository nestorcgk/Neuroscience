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

int main(int argc, const char** argv) {
	std::vector<float> data(127*127);
	readData(argv[1], data.data());
	for (int i = 0; i < data.size(); ++i)
	{
		cout << data[i] << "\n";
	}
  
}