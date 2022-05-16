//
//  gks_3d_projection.c
//  GeKoS
//
//  Created by Alex Popadich on 12/6/21.
//

#include <math.h>
#include "gks_3d_projection.h"



void gks_projection_init(GKScontext3DPtr context)
{    
    // Set projection matrix to identity matrix
    for (int i=0; i<4; i++) {
        for (int j=0; j<4; j++) {
            context->proj_matrix[i][j] = 0.0;
            if (i==j) {
                context->proj_matrix[i][j] = 1.0;
            }
        }
    }
    
    gks_projection_set_orthogonal(context);
}


GKSmatrixPtr gks_projection_get_matrix(GKScontext3DPtr context)
{
    return &context->proj_matrix;
}

/*
    1 0 0 0
    0 1 0 0
    0 0 0 0
    0 0 0 1
*/
void gks_projection_set_orthogonal(GKScontext3DPtr context)
{

    
    context->proj_matrix[0][0] = 1.0;
    context->proj_matrix[0][1] = 0.0;
    context->proj_matrix[0][2] = 0.0;
    context->proj_matrix[0][3] = 0.0;

    context->proj_matrix[1][0] = 0.0;
    context->proj_matrix[1][1] = 1.0;
    context->proj_matrix[1][2] = 0.0;
    context->proj_matrix[1][3] = 0.0;

    context->proj_matrix[2][0] = 0.0;
    context->proj_matrix[2][1] = 0.0;
    context->proj_matrix[2][2] = 0.0;
    context->proj_matrix[2][3] = 0.0;
    
    context->proj_matrix[3][0] = 0.0;
    context->proj_matrix[3][1] = 0.0;
    context->proj_matrix[3][2] = 0.0;
    context->proj_matrix[3][3] = 1.0;

    context->projection_type = kOrthogonalProjection;
    context->focus = 1.0;
}



/*
    1 0 0 0
    0 1 0 0
    0 0 0 1/d (positive/negative controls left/right handed coordinate system)
    0 0 0 1
*/
void gks_projection_set_simple(GKScontext3DPtr context, GKSfloat d)
{
    
    context->proj_matrix[0][0] = 1.0;
    context->proj_matrix[0][1] = 0.0;
    context->proj_matrix[0][2] = 0.0;
    context->proj_matrix[0][3] = 0.0;
    
    context->proj_matrix[1][0] = 0.0;
    context->proj_matrix[1][1] = 1.0;
    context->proj_matrix[1][2] = 0.0;
    context->proj_matrix[1][3] = 0.0;
    
    context->proj_matrix[2][0] = 0.0;
    context->proj_matrix[2][1] = 0.0;
    context->proj_matrix[2][2] = 0.0;
    context->proj_matrix[2][3] = 1.0/d;          // !!!: positive according to book?
    
    context->proj_matrix[3][0] = 0.0;
    context->proj_matrix[3][1] = 0.0;
    context->proj_matrix[3][2] = 0.0;
    context->proj_matrix[3][3] = 1.0;
    
    context->projection_type = kPerspectiveSimpleProjection;
    
    context->focus = d;

}


/*
    t⍺ = tan(alpha)
 
    1/t⍺ 0    0   0
    0    1/t⍺ 0   0
    0    0    a  -1 (positive/negative controls left/right coordinate system)
    0    0    b   0
*/
void gks_projection_set_perspective(GKScontext3DPtr context, GKSfloat alpha, GKSfloat near, GKSfloat far)
{

    GKSfloat scale = 1 / tan(alpha * 0.5 * M_PI / 180);
    
    // TODO: math check
    GKSfloat n = near;
    GKSfloat f = far;
    
    GKSfloat a = -f / (f - n);
    GKSfloat b = -f * n / (f - n);
    
    context->proj_matrix[0][0] = scale;
    context->proj_matrix[0][1] = 0.0;
    context->proj_matrix[0][2] = 0.0;
    context->proj_matrix[0][3] = 0.0;
    
    context->proj_matrix[1][0] = 0.0;
    context->proj_matrix[1][1] = scale;
    context->proj_matrix[1][2] = 0.0;
    context->proj_matrix[1][3] = 0.0;
    
    context->proj_matrix[2][0] = 0.0;
    context->proj_matrix[2][1] = 0.0;
    context->proj_matrix[2][2] = a;
    context->proj_matrix[2][3] = 1.0;
    
    context->proj_matrix[3][0] = 0.0;
    context->proj_matrix[3][1] = 0.0;
    context->proj_matrix[3][2] = b;
    context->proj_matrix[3][3] = 0.0;
    
    context->projection_type = kPerspectiveSimpleProjection;
    context->near = near;
    context->far = far;
    context->focus = alpha;
}


/*
    t⍺ = tan(alpha)
 
    1/t⍺ 0    0   0
    0    1/t⍺ 0   0
    0    0    a  -1 (positive/negative controls left/right coordinate system)
    0    0    b   0
 
    alpha needs to be the aspect ratio of the screen
*/
void gks_projection_set_alternate(GKScontext3DPtr context, GKSfloat alpha, GKSfloat near, GKSfloat far)
{
    GKSfloat n = near;
    GKSfloat f = far;
 
    GKSfloat scale = 1 / tan(alpha * 0.5 * M_PI / 180);
    GKSfloat a = (f + n) / (f - n);
    GKSfloat b = (2 * n * f) / (f - n);
    
    context->proj_matrix[0][0] = scale;
    context->proj_matrix[0][1] = 0.0;
    context->proj_matrix[0][2] = 0.0;
    context->proj_matrix[0][3] = 0.0;
    
    context->proj_matrix[1][0] = 0.0;
    context->proj_matrix[1][1] = scale;
    context->proj_matrix[1][2] = 0.0;
    context->proj_matrix[1][3] = 0.0;
    
    context->proj_matrix[2][0] = 0.0;
    context->proj_matrix[2][1] = 0.0;
    context->proj_matrix[2][2] = a;
    context->proj_matrix[2][3] = 1.0;
    
    context->proj_matrix[3][0] = 0.0;
    context->proj_matrix[3][1] = 0.0;
    context->proj_matrix[3][2] = b;
    context->proj_matrix[3][3] = 0.0;
    
    context->projection_type = kAlternateProjection;
    context->near = near;
    context->far = far;
    context->focus = alpha;
    
}
