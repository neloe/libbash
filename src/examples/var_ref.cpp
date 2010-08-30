#include "../cppbash.h"
#include <iostream>
#include <cstdlib>

int main(int argc, char* argv[])
{
	if (argc<2)
	{
		std::cerr << "Please specify a file\n";
		std::exit(1);
	}
	cppbash test_bash((std::string)argv[1]);
	test_bash.run();
	return 0;
}
