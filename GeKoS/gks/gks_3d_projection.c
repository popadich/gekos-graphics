//
//  gks_3d_projection.c
//  GeKoS
//
//  Created by Alex Popadich on 12/6/21.
//

#include "gks_3d_projection.h"


static Matrix_4            gProjectionMatrix_3;
static ProjectionType      gProjectionType = kOrthogonalProjection;

void gks_init_projection(void)
{    
    // Set projection matrix to identity matrix
    for (int i=0; i<4; i++) {
        for (int j=0; j<4; j++) {
            gProjectionMatrix_3[i][j] = 0.0;
            if (i==j) {
                gProjectionMatrix_3[i][j] = 1.0;
            }
        }
    }
    
    gks_enable_orthogonal_projection();
}

ProjectionType gks_get_projection_type(void)
{
    return gProjectionType;
}

void gks_enable_orthogonal_projection(void)
{
    gProjectionMatrix_3[0][0] = 1.0; gProjectionMatrix_3[0][1] = 0.0; gProjectionMatrix_3[0][2] = 0.0; gProjectionMatrix_3[0][3] = 0.0;
    gProjectionMatrix_3[1][0] = 0.0; gProjectionMatrix_3[1][1] = 1.0; gProjectionMatrix_3[1][2] = 0.0; gProjectionMatrix_3[1][3] = 0.0;
    gProjectionMatrix_3[2][0] = 0.0; gProjectionMatrix_3[2][1] = 0.0; gProjectionMatrix_3[2][2] = 0.0; gProjectionMatrix_3[2][3] = 0.0;
    gProjectionMatrix_3[3][0] = 0.0; gProjectionMatrix_3[3][1] = 0.0; gProjectionMatrix_3[3][2] = 0.0; gProjectionMatrix_3[3][3] = 1.0;
    
    gProjectionType = kOrthogonalProjection;
}


Matrix_4 *gks_get_projection_matrix(void)
{
    return &gProjectionMatrix_3;
}


