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
static GKSfloat            gNear;
static GKSfloat            gFar;


void gks_init_projection(void)
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
    
    gks_set_orthogonal_projection();
}

ProjectionType gks_get_projection_type(void)
{
    return gProjectionType;
}

GKSmatrix_3 *gks_get_projection_matrix(void)
{
    return &gProjectionMatrix;
}



/*
    1 0 0 0
    0 1 0 0
    0 0 0 0
    0 0 0 1
*/
void gks_set_orthogonal_projection(void)
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
    0 0 0 1/d
    0 0 0 1
*/
void gks_set_perspective_simple(GKSfloat d)
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
    gProjectionMatrix[2][3] = 1.0/d; //TODO: positive according to book?
    gProjectionMatrix[3][0] = 0.0;
    gProjectionMatrix[3][1] = 0.0;
    gProjectionMatrix[3][2] = 0.0;
    gProjectionMatrix[3][3] = 1.0;
    
    gProjectionType = kPerspectiveProjection;
    gPerspectiveDepth = d;

}


/*
void gks_set_perspective_projection(void)
{
    gNear = 4.0;
    gFar = 10.0;
    
    
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
    gProjectionMatrix[2][2] = -gFar/(gFar - gNear);
    gProjectionMatrix[2][3] = -1.0;
    gProjectionMatrix[3][0] = 0.0;
    gProjectionMatrix[3][1] = 0.0;
    gProjectionMatrix[3][2] = -1.0*(gFar * gNear)/(gFar - gNear);
    gProjectionMatrix[3][3] = 0;
    
    gProjectionType = kPerspectiveProjection;
}
*/



GKSfloat gks_get_perspective_depth(void)
{
    return gPerspectiveDepth;
}



/*
    t⍺ = tan(alpha)
 
    1/t⍺ 0    0   0
    0    1/t⍺ 0   0
    0    0    a  -1
    0    0    b   0
*/
void gks_set_camera_perspective(GKSfloat near, GKSfloat far, GKSfloat alpha)
{
    GKSfloat n = near;
    GKSfloat f = far;
    
    GKSfloat a = (f + n) / (f - n);
    GKSfloat b = (2 * n * f) / (f - n);
    gProjectionMatrix[0][0] = 1.0/tan(alpha); gProjectionMatrix[0][1] = 0.0; gProjectionMatrix[0][2] = 0.0; gProjectionMatrix[0][3] = 0.0;
    gProjectionMatrix[1][0] = 0.0; gProjectionMatrix[1][1] = 1.0/tan(alpha); gProjectionMatrix[1][2] = 0.0; gProjectionMatrix[1][3] = 0.0;
    gProjectionMatrix[2][0] = 0.0; gProjectionMatrix[2][1] = 0.0; gProjectionMatrix[2][2] = a; gProjectionMatrix[2][3] = -1.0;
    gProjectionMatrix[3][0] = 0.0; gProjectionMatrix[3][1] = 0.0; gProjectionMatrix[3][2] = b; gProjectionMatrix[3][3] = 0.0;
}
