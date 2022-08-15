void decorateAndPrint(const char *);

int main() {
    decorateAndPrint("Miki");

    return 0;
}

/*
 clang++ -c FooXccib.cpp
 ar -cvq libFooXccib.a FooXccib.o
 nm --demangle libFooXccib.a
 clang libFooXccib.a execute.cpp

 clang++ -c -fPIC FooXccib.cpp
 clang++ -shared -o libFooXccib.dylib FooXccib.o
 clang++ libFooXccib.dylib execute.cpp
 */
