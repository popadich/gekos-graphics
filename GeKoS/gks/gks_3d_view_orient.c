//
//  gks_3d_view_orient.c
//  GeKoS
//
//  Created by Alex Popadich on 12/16/21.
//

#include "gks_3d_view_orient.h"
#include "gks_3d_matrix.h"

// P R I V A T E    O K
static GKSmatrix_3      gViewMatrix;       // View Plane Orientation Matrix

void gks_init_view_matrix(void)
{
    GKSmatrix_3 viewTransMatrix = {
        {1.0, 0.0, 0.0, 0.0},
        {0.0, 1.0, 0.0, 0.0},
        {0.0, 0.0, -1.0, 0.0},
        {0.0, 0.0, 0.0, 1.0}
    };
    gks_set_view_matrix(viewTransMatrix);

}



// VPN the view plane is like a tv screen in front of your face.
// this vector sets the normal to that "screen". The plane is
// actually an infinite plane.


// VRP the view plane reference point, is where the screen is
// located in the world coordinate system.

// VUP the view plane up vector. The heads up.


void gks_set_view_matrix(GKSmatrix_3 viewMatrix)
{
    for(int i=0; i<4; i++)
        for (int j=0; j<4; j++)
            gViewMatrix[i][j] = viewMatrix[i][j];
}

GKSmatrix_3 *gks_get_view_matrix(void)
{
    return &gViewMatrix;
}


void gks_create_camera_view_matrix(double obsX, double obsY, double obsZ,
                        double dirX, double dirY, double dirZ,
                        double upX, double upY, double upZ, GKSmatrix_3 result) {

    GKSpoint_3 myUp, myDir;
    myUp.x = upX;
    myUp.y = upY;
    myUp.z = upZ;
    myUp.w = 1.0;
    myDir.x = dirX;
    myDir.y = dirY;
    myDir.z = dirZ;
    myDir.w = 1.0;

    GKSvector3d up_vector;
    GKSvector3d w_vector;
    GKSvector3d u_vector;           // u_vector points along uHat
    GKSvector3d v_vector;           // v_vector points along vHat
    up_vector.crd = myUp;
    w_vector.crd = myDir;
    
    
    // normalize view direction vector
    vectornormal(w_vector, &w_vector);
    
    // cross product to find uHat
    vectorcrossproduct(w_vector, up_vector, &u_vector);
    vectornormal(u_vector, &u_vector);  //uHat
    
    // cross product to find vHat
    vectorcrossproduct(w_vector, u_vector, &v_vector); //vHat

    result[0][0] = u_vector.crd.x;
    result[0][1] = u_vector.crd.y;
    result[0][2] = u_vector.crd.z;
    result[0][3] = -obsX;
    
    result[1][0] = v_vector.crd.x;
    result[1][1] = v_vector.crd.y;
    result[1][2] = v_vector.crd.z;
    result[1][3] = -obsY;
    
    result[2][0] = w_vector.crd.x;
    result[2][1] = w_vector.crd.y;
    result[2][2] = w_vector.crd.z;
    result[2][3] = -obsZ;
    
    result[3][0] = 0.0;
    result[3][1] = 0.0;
    result[3][2] = 0.0;
    result[3][3] = 1.0;

}

void gks_compute_look_at_view_matrix(GKSvector3d obs, GKSvector3d look, GKSvector3d up, GKSmatrix_3 result)
{
    GKSvector3d w_vector;
    GKSvector3d u_vector;           // u_vector points along uHat
    GKSvector3d v_vector;           // v_vector points along vHat
    
    vectorsubtract(obs, look, &w_vector);
    vectornormal(w_vector, &w_vector);
    
    vectorcrossproduct(w_vector, up, &u_vector);
    vectornormal(u_vector, &u_vector);
    
    vectorcrossproduct(w_vector, u_vector, &v_vector);
    
    result[0][0] = u_vector.crd.x;
    result[0][1] = u_vector.crd.y;
    result[0][2] = u_vector.crd.z;
    result[0][3] = -obs.crd.x;
    result[1][0] = v_vector.crd.x;
    result[1][1] = v_vector.crd.y;
    result[1][2] = v_vector.crd.z;
    result[1][3] = -obs.crd.y;
    result[2][0] = w_vector.crd.x;
    result[2][1] = w_vector.crd.y;
    result[2][2] = w_vector.crd.z;
    result[2][3] = -obs.crd.z;
    result[3][0] = 0.0;
    result[3][1] = 0.0;
    result[3][2] = 0.0;
    result[3][3] = 1.0;
}


void gks_compute_dir_vector(GKSvector3d location, GKSvector3d look, GKSvector3dPtr dir)
{
    
    vectorsubtract(look, location, dir);
    vectornormal(*dir, dir);
}

void gks_compute_camera_look_at_matrix(double obsX, double obsY, double obsZ,
                                       double lookX, double lookY, double lookZ,
                                       double upX, double upY, double upZ, GKSmatrix_3 result)
{
    GKSvector3d dir_vector, look_vector, location_vector;
    
    location_vector.crd.x = obsX;
    location_vector.crd.y = obsY;
    location_vector.crd.z = obsZ;
    location_vector.crd.w = 1.0;

    look_vector.crd.x = lookX;
    look_vector.crd.y = lookY;
    look_vector.crd.z = lookZ;
    look_vector.crd.w = 1.0;
    
    gks_compute_dir_vector(location_vector, look_vector, &dir_vector);
    gks_create_camera_view_matrix(obsX, obsY, obsZ, dir_vector.crd.x, dir_vector.crd.y, dir_vector.crd.z, upX, upY, upZ, result);

}

void gks_compute_camera_look_view_matrix(GKSvector3d obs, GKSvector3d look, GKSvector3d up, GKSmatrix_3 result)
{
    gks_compute_look_at_view_matrix(obs, look, up, result);
}
