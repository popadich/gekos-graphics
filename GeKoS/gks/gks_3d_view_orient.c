//
//  gks_3d_view_orient.c
//  GeKoS
//
//  Created by Alex Popadich on 12/16/21.
//

#include "gks_3d_view_orient.h"
#include "gks_3d_matrix.h"
#include "stdio.h"

// P R I V A T E    O K
static GKSmatrix_3      gViewMatrix;       // View Plane Orientation Matrix

void gks_view_matrix_init(GKScontext3DPtr context)
{
    GKSmatrix_3 viewTransMatrix = {
        {1.0, 0.0, 0.0, 0.0},
        {0.0, 1.0, 0.0, 0.0},
        {0.0, 0.0, -1.0, 0.0},
        {0.0, 0.0, 0.0, 1.0}
    };
    gks_view_matrix_set(context, viewTransMatrix);

}


void gks_view_matrix_set(GKScontext3DPtr context, GKSmatrix_3 viewMatrix)
{
    for(int i=0; i<4; i++)
        for (int j=0; j<4; j++) {
            gViewMatrix[i][j] = viewMatrix[i][j];
            context->view_matrix[i][j] = viewMatrix[i][j];
        }
            
}

GKSmatrix_3 *gks_view_matrix_get(GKScontext3DPtr context_ptr)
{
    return &gViewMatrix;
}

void gks_view_matrix_w_get(GKScontext3DPtr context, GKSvector3dPtr w_dir)
{
    for (int i=0; i<4; i++) {
        GKSfloat a = gViewMatrix[2][i];
        GKSfloat p = context->view_matrix[2][i];
        w_dir->arr[i] = a;
    }
}

void gks_view_matrix_p_get(GKScontext3DPtr context, GKSvector3dPtr p_loc)
{
    for (int i=0; i<4; i++) {
        GKSfloat a = gViewMatrix[i][3];
        GKSfloat p = context->view_matrix[i][3];
       p_loc->arr[i] = a;
    }
}

void gks_view_matrix_compute(GKScontext3DPtr context_ptr, GKSvector3d obs, GKSvector3d w_vector, GKSvector3d up, GKSmatrix_3 result) {

    GKSvector3d u_vector;           // u_vector points along uHat
    GKSvector3d v_vector;           // v_vector points along vHat
    
    
    // normalize view direction vector
    vectornormal(w_vector, &w_vector);
    
    // cross product to find uHat
    vectorcrossproduct(w_vector, up, &u_vector);
    vectornormal(u_vector, &u_vector);  //uHat
    
    // cross product to find vHat
    vectorcrossproduct(u_vector, w_vector, &v_vector); //vHat

    
    // Populating the View Matrix:
    // Normaly the basis vectors would go in the columns of the matrix M
    // but we want the inverse of M, which luckily happens to be the same as
    // the transpose of M and therefore the basis vectors go into the rows
    // of the matrix.
    //
   
    GKSmatrix_3 orientation;
    orientation[0][0] = u_vector.crd.x;
    orientation[0][1] = u_vector.crd.y;
    orientation[0][2] = u_vector.crd.z;
    orientation[0][3] = 0;
    orientation[1][0] = v_vector.crd.x;
    orientation[1][1] = v_vector.crd.y;
    orientation[1][2] = v_vector.crd.z;
    orientation[1][3] = 0;
    orientation[2][0] = w_vector.crd.x;
    orientation[2][1] = w_vector.crd.y;
    orientation[2][2] = w_vector.crd.z;
    orientation[2][3] = 0;
    orientation[3][0] = 0.0;
    orientation[3][1] = 0.0;
    orientation[3][2] = 0.0;
    orientation[3][3] = 1.0;

    // TODO: look at alternative method
    GKSmatrix_3 translation = {
        1,0,0,-obs.crd.x,
        0,1,0,-obs.crd.y,
        0,0,1,-obs.crd.z,
        0, 0, 0, 1
    };

    gks_multiply_matrix_3(orientation, translation, result);
    
}



void gks_view_matrix_lookat_compute(GKScontext3DPtr context_ptr, GKSvector3d obs, GKSvector3d look, GKSvector3d up, GKSmatrix_3 result)
{
    GKSvector3d w_vector;
    GKSvector3d u_vector;           // u_vector points along uHat
    GKSvector3d v_vector;           // v_vector points along vHat
    
    vectorsubtract(look, obs, &w_vector);
    vectornormal(w_vector, &w_vector);
    
    vectorcrossproduct(w_vector, up, &u_vector);
    vectornormal(u_vector, &u_vector);
    
    vectorcrossproduct(u_vector, w_vector, &v_vector);
    
    GKSmatrix_3 orientation;
    orientation[0][0] = u_vector.crd.x;
    orientation[0][1] = u_vector.crd.y;
    orientation[0][2] = u_vector.crd.z;
    orientation[0][3] = 0;
    orientation[1][0] = v_vector.crd.x;
    orientation[1][1] = v_vector.crd.y;
    orientation[1][2] = v_vector.crd.z;
    orientation[1][3] = 0;
    orientation[2][0] = w_vector.crd.x;
    orientation[2][1] = w_vector.crd.y;
    orientation[2][2] = w_vector.crd.z;
    orientation[2][3] = 0;
    orientation[3][0] = 0.0;
    orientation[3][1] = 0.0;
    orientation[3][2] = 0.0;
    orientation[3][3] = 1.0;

    GKSmatrix_3 translation = {
        1,0,0,-obs.crd.x,
        0,1,0,-obs.crd.y,
        0,0,1,-obs.crd.z,
        0, 0, 0, 1
    };

    gks_multiply_matrix_3(orientation, translation, result);

}

