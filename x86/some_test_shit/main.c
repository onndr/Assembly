
int add(int a, int b)
{
    return a + b;
}

int sub(int a, int b) {
    return add(a, -b);
}

int main(int argc, char *argv[])
{
    sub(5, 12);
    return 0;
}
