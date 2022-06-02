#include <stdio.h>
#include <stdlib.h>
extern char *remnth(char *s, int n);

int main(int argc, char *argv[]) {
    // for(int i = 0; i < argc; i++){
    //     printf("%s", argv[i]);
    //     printf("; ");
    // }
    // printf("%s", argv[1]);
    // printf("\n");
    // printf("%s", argv[2]);
    // printf("\n");
    // printf("%s", argv[3]);
    int n = atoi(argv[2]);
    printf("%s", argv[1]);
    printf("%s", "\nbefore call\n");
    char* ptr = remnth(argv[1], n);
    printf("%s", "\nafter call\n");
    printf("%s", ptr);
    printf("%s", "\nafter printf res\n");
    // removerng(argv[1], *argv[2], *argv[3]);
}