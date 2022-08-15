#include <iostream>

void decorateAndPrint(const char * _Nonnull input) {
    std::string stdInput = input;
    std::cout << "Hello " << stdInput << std::endl;
}
