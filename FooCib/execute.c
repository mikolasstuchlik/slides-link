void * create_person(const char *, int);
void greet_person(void *);
void destroy_person(void *);

int main() {
    void * person = create_person("Miki", 26);
    greet_person(person);
    destroy_person(person);

    return 0;
}

/*
 clang -c FooCib.c
 ar -cvq libFooCib.a FooCib.o
 nm libFooCib.a
 clang libFooCib.a execute.c

 clang -c -fPIC FooCib.c
 clang -shared -o libFooCib.dylib FooCib.o
 clang libFooCib.dylib execute.c
 */
// https://stackoverflow.com/questions/32297349/why-does-a-2-stage-command-line-build-with-clang-not-generate-a-dsym-directory
