#include "kCSDAk.h"
#include <fstream>
#include <iostream>
#include <string>
#include <vector>
#include <utility>
#include <boost/tokenizer.hpp>

using namespace std;
using namespace boost;

int main() {
  ifstream myfile ("BceroDura.dat");
  std::vector<float> data(127*127);
  std::vector<float> result(4096 * 4096);
  cout.precision(17);
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