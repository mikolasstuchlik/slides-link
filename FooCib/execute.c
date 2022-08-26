void * create_person(const char *, int);
void greet_person(void *);
void destroy_person(void *);

int main() {
    void * person = create_person("Miki", 26);
    greet_person(person);
    destroy_person(person);

    return 0;
}
