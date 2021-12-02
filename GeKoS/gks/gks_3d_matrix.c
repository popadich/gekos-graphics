//
//  gks_3d_matrix.c
//  gks-graphics
//
//  Created by Alex Popadich on 12/1/21.
//

#include "gks_3d_matrix.h"



void gks_set_identity_matrix_2(Matrix_3 result)
{
    result[0][0] = result[1][1] = result[2][2] = 1.0;
    result[0][1] = result[1][0] = result[2][0] = 0.0;
    result[0][2] = result[1][2] = result[2][1] = 0.0;
}

void gks_set_identity_matrix_3(Matrix_4 result)
{
    result[0][0] = result[1][1] = result[2][2] = result[3][3] = 1.0;
    result[0][1] = result[0][2] = result[0][3] = 0.0;
    result[1][0] = result[1][2] = result[1][3] = 0.0;
    result[2][0] = result[2][1] = result[2][3] = 0.0;
    result[3][0] = result[3][1] = result[3][2] = 0.0;
}

