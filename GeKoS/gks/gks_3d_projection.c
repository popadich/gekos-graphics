//
//  gks_3d_projection.c
//  GeKoS
//
//  Created by Alex Popadich on 12/6/21.
//

#include <math.h>
#include "gks_3d_projection.h"

static GKSmatrix_3         gProjectionMatrix;
static ProjectionType      gProjectionType = kOrthogonalProjection;
static GKSfloat            gPerspectiveDepth;


void gks_projection_init(GKScontext3DPtr context_ptr)
{    
    // Set projection matrix to identity matrix
    for (int i=0; i<4; i++) {
        for (int j=0; j<4; j++) {
            gProjectionMatrix[i][j] = 0.0;
            if (i==j) {
                gProjectionMatrix[i][j] = 1.0;
            }
        }
    }
    
    gks_projection_set_orthogonal();
}

ProjectionType gks_projection_get_type(void)
{
    return gProjectionType;
}

GKSmatrix_3 *gks_projection_get_matrix(void)
{
    return &gProjectionMatrix;
}



void gks_projection_set_matrix(GKSmatrix_3 new_matrix)
{
    for(int i=0; i<4; i++)
        for (int j=0; j<4; j++)
            gProjectionMatrix[i][j] = new_matrix[i][j];
}




/*
    1 0 0 0
    0 1 0 0
    0 0 0 0
    0 0 0 1
*/
void gks_projection_set_orthogonal(void)
{
    gProjectionMatrix[0][0] = 1.0; gProjectionMatrix[0][1] = 0.0; gProjectionMatrix[0][2] = 0.0; gProjectionMatrix[0][3] = 0.0;
    gProjectionMatrix[1][0] = 0.0; gProjectionMatrix[1][1] = 1.0; gProjectionMatrix[1][2] = 0.0; gProjectionMatrix[1][3] = 0.0;
    gProjectionMatrix[2][0] = 0.0; gProjectionMatrix[2][1] = 0.0; gProjectionMatrix[2][2] = 0.0; gProjectionMatrix[2][3] = 0.0;
    gProjectionMatrix[3][0] = 0.0; gProjectionMatrix[3][1] = 0.0; gProjectionMatrix[3][2] = 0.0; gProjectionMatrix[3][3] = 1.0;
    
    gProjectionType = kOrthogonalProjection;
}



/*
    1 0 0 0
    0 1 0 0
    0 0 0 1/d (positive/negative controls left/right handed coordinate system)
    0 0 0 1
*/
void gks_projection_set_simple(GKSfloat d)
{
    gProjectionMatrix[0][0] = 1.0;
    gProjectionMatrix[0][1] = 0.0;
    gProjectionMatrix[0][2] = 0.0;
    gProjectionMatrix[0][3] = 0.0;
    
    gProjectionMatrix[1][0] = 0.0;
    gProjectionMatrix[1][1] = 1.0;
    gProjectionMatrix[1][2] = 0.0;
    gProjectionMatrix[1][3] = 0.0;
    
    gProjectionMatrix[2][0] = 0.0;
    gProjectionMatrix[2][1] = 0.0;
    gProjectionMatrix[2][2] = 0.0;
    
    // !!!: positive according to book?
    gProjectionMatrix[2][3] = 1.0/d;
    
    gProjectionMatrix[3][0] = 0.0;
    gProjectionMatrix[3][1] = 0.0;
    gProjectionMatrix[3][2] = 0.0;
    gProjectionMatrix[3][3] = 1.0;
    
    gProjectionType = kPerspectiveSimpleProjection;
    gPerspectiveDepth = d;

}


/*
    t⍺ = tan(alpha)
 
    1/t⍺ 0    0   0
    0    1/t⍺ 0   0
    0    0    a  -1 (positive/negative controls left/right coordinate system)
    0    0    b   0
*/
void gks_projection_set_perspective(GKSfloat alpha, GKSfloat near, GKSfloat far)
{

    GKSfloat scale = 1 / tan(alpha * 0.5 * M_PI / 180);
    
    // TODO: math check
    GKSfloat n = near;
    GKSfloat f = far;
    
    GKSfloat a = -f / (f - n);
    GKSfloat b = -f * n / (f - n);
    
    gProjectionMatrix[0][0] = scale;
    gProjectionMatrix[0][1] = 0.0;
    gProjectionMatrix[0][2] = 0.0;
    gProjectionMatrix[0][3] = 0.0;
    
    gProjectionMatrix[1][0] = 0.0;
    gProjectionMatrix[1][1] = scale;
    gProjectionMatrix[1][2] = 0.0;
    gProjectionMatrix[1][3] = 0.0;
    
    gProjectionMatrix[2][0] = 0.0;
    gProjectionMatrix[2][1] = 0.0;
    gProjectionMatrix[2][2] = a;
    gProjectionMatrix[2][3] = 1.0;
    
    gProjectionMatrix[3][0] = 0.0;
    gProjectionMatrix[3][1] = 0.0;
    gProjectionMatrix[3][2] = b;
    gProjectionMatrix[3][3] = 0.0;
    
    gProjectionType = kPerspectiveProjection;
}


/*
    t⍺ = tan(alpha)
 
    1/t⍺ 0    0   0
    0    1/t⍺ 0   0
    0    0    a  -1 (positive/negative controls left/right coordinate system)
    0    0    b   0
*/
void gks_projection_set_alternate(GKSfloat alpha, GKSfloat near, GKSfloat far)
{
    GKSfloat n = near;
    GKSfloat f = far;
 
    GKSfloat scale = 1 / tan(alpha * 0.5 * M_PI / 180);
    GKSfloat a = (f + n) / (f - n);
    GKSfloat b = (2 * n * f) / (f - n);
    gProjectionMatrix[0][0] = scale;
    gProjectionMatrix[0][1] = 0.0;
    gProjectionMatrix[0][2] = 0.0;
    gProjectionMatrix[0][3] = 0.0;
    
    gProjectionMatrix[1][0] = 0.0;
    gProjectionMatrix[1][1] = scale;
    gProjectionMatrix[1][2] = 0.0;
    gProjectionMatrix[1][3] = 0.0;
    
    gProjectionMatrix[2][0] = 0.0;
    gProjectionMatrix[2][1] = 0.0;
    gProjectionMatrix[2][2] = a;
    gProjectionMatrix[2][3] = 1.0;
    
    gProjectionMatrix[3][0] = 0.0;
    gProjectionMatrix[3][1] = 0.0;
    gProjectionMatrix[3][2] = b;
    gProjectionMatrix[3][3] = 0.0;
}
