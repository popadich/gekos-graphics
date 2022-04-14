#include <stdio.h>
#include <stdlib.h>
#include "gks.h"




void test_identity_matrix(void)
{
    GKSmatrix_3 im;

    gks_create_identity_matrix_3(im);
    
    for (GKSint i=0; i<4; i++) {
        printf("im : %lf %lf %lf %lf \n", im[i][0], im[i][1], im[i][2], im[i][3]);
    }
}





int main(int argc, char *argv[]) {
	printf("Hello 3D Identity\n");
	gks_init();
    test_identity_matrix();
}
