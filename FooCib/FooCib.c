#include <stdlib.h>
#include <stdio.h>
#include <string.h>

struct Person {
    char * _Nonnull name;
    int age;
};

struct Person * _Nullable create_person(const char * _Nonnull name, int age) {
    struct Person * result = malloc(sizeof(struct Person));
    if (result == NULL) {
        return NULL;
    }

    char * name_copy = strdup(name);
    if (name_copy == NULL) {
        free(result);
        return NULL;
    }

    result->name = name_copy;
    result->age = age;

    return result;
}

void destroy_person(struct Person * _Nonnull person) {
    free(person->name);
    free(person);
}

void greet_person(const struct Person * _Nonnull person) {
    if (person->age < 15) {
        printf("Hello %s\n", person->name);
    } else {
        printf("Hello %s ;)\n", person->name);
    }
}
