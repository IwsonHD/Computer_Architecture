#include <stdio.h>
#include <stdlib.h>

extern float progowanie_sredniej_kroczacej(float* tablica, unsigned int k, unsigned int m);

float diff = 0.6;

int main() {

	unsigned int k = 8, m = 2;


	float arr[8] = {
		1,2,3,0.1,0.2,0.4,4,5
	};

	float out = progowanie_sredniej_kroczacej(arr, k, m);
	printf("%f", out);

	return 0;
}