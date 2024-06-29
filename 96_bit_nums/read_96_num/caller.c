#include <stdio.h>

extern unsigned long long int read_uni_64(int system_base);
extern unsigned long long int write_uni_64(long long int num, int system_base);

int main() {
	unsigned long long int out;


	out = read_uni_64(16);

	write_uni_64(out, 16);

//	printf("\nWczytana liczba to: %llu", out);

	return 0;
}

