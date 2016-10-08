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
  ifstream myfile ("BceroDura.csv");
  std::vector<float> data(127*127);
  std::vector<float> result(4096 * 4096);
  int i = 0;
  int tokencount = 0;
  std::string line;
  //std::vector<std::vector<std::string>> data;
  if(myfile.is_open())
  {
  	char_separator<char> sep(",");
	while(getline(myfile, line, ',')) {
			
			tokenizer<char_separator<char>> tokens(line, sep);
			tokencount = 0;
		    for (const auto& t : tokens) {
		    		tokencount++;
	        		data[i] = stof(t);
					i++;
					cout  <<  "TokenCount:" << tokencount << "\n";    	        	
	    	}
	    	 	    
	}
	myfile.close();
  }
  /*
  for (int k = 0; k < data.size(); ++k)
  {
  	cout  <<  k << ": " << data[k] << "\n" ;
  }

 */
  
  

  

	
	

}