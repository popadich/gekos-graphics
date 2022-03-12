//
//  gks_3d_view_orient.c
//  GeKoS
//
//  Created by Alex Popadich on 12/16/21.
//

#include "gks_3d_view_orient.h"
#include "gks_3d_matrix.h"

// P R I V A T E    O K
static GKSmatrix_3      gViewMatrix_4;       // View Plane Orientation Matrix

void gks_init_view_plane(void)
{
    GKSmatrix_3 viewTransMatrix = {
        {1.0, 0.0, 0.0, 0.0},
        {0.0, 1.0, 0.0, 0.0},
        {0.0, 0.0, 1.0, 0.0},
        {0.0, 0.0, 0.0, 1.0}
    };

    // Set View Plane properties  (like a TV screen)
    gks_create_view_matrix(0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0, viewTransMatrix);
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
            gViewMatrix_4[i][j] = viewMatrix[i][j];
}

GKSmatrix_3 *gks_get_view_matrix(void)
{
    return &gViewMatrix_4;
}

// @TODO: problems when view plane normal matches up vector
// When (xn,yn,zn) is set to (0,1,0) things blow up
void gks_create_view_matrix(double obsX, double obsY, double obsZ,
                        double dirX, double dirY, double dirZ,
                        double upX, double upY, double upZ, GKSmatrix_3 result) {
    GKSpoint_3 u, v, un, vn, nn;
    GKSpoint_3 x;
    GKSfloat normalization_coeff;
    
    // FIXME: use GKSvector_3d type
    // stuff values into data structures
    GKSpoint_3 myUp, myDir, myObs;
    myUp.x = upX; myUp.y = upY; myUp.z = upZ;
    myDir.x = dirX; myDir.y = dirY; myDir.z = dirZ;
    myObs.x = obsX; myObs.y = obsY; myObs.z = obsZ;
    
    // cast to needed pointer type
    // up vector pointer
    GKSfloat *vup_ptr = (GKSfloat *)(&myUp);
    // direction vector pointer
    GKSfloat *vdir_ptr = (GKSfloat *)(&myDir);
    
    
    // u_ptr points to vector along uHat
    GKSfloat *u_ptr = (GKSfloat *)(&u);
    vecprod(vup_ptr, vdir_ptr, u_ptr);
    
    // not sure how this works, this is  (vup • vdir)/ ||vdir||
    GKSfloat *x_ptr = (GKSfloat *)(&x);
    normalization_coeff = vecdot(vup_ptr, vdir_ptr) / vecdot(vdir_ptr, vdir_ptr);
    vecscale(normalization_coeff, vdir_ptr, x_ptr);
    
    // v_ptr points to vector along vHat
    GKSfloat *v_ptr = (GKSfloat *)(&v);
    vecsub(vup_ptr, x_ptr, v_ptr);
    
    GKSfloat *un_ptr = (GKSfloat *)(&un);
    GKSfloat *vn_ptr = (GKSfloat *)(&vn);
    GKSfloat *nn_ptr = (GKSfloat *)(&nn);
    
    // un = uHat normalized
    vecnormal(u_ptr, un_ptr);
    // vn = vHat normalized
    vecnormal(v_ptr, vn_ptr);
    
    // nn = dirVector normalized
    vecnormal(vdir_ptr, nn_ptr);

    result[0][0] = un.x;
    result[0][1] = un.y;
    result[0][2] = un.z;
    result[0][3] = -myObs.x;
    result[1][0] = vn.x;
    result[1][1] = vn.y;
    result[1][2] = vn.z;
    result[1][3] = -myObs.y;
    result[2][0] = nn.x;
    result[2][1] = nn.y;
    result[2][2] = nn.z;
    result[2][3] = -myObs.z;
    result[3][0] = 0.0;
    result[3][1] = 0.0;
    result[3][2] = 0.0;
    result[3][3] = 1.0;

}


void gks_compute_look_at_matrix(double xo, double yo, double zo,
                            double xa, double ya, double za,
                            double xv, double yv, double zv, GKSmatrix_3 result)
{
    GKSpoint_3 U, V, N, un, vn, nn;

    GKSpoint_3 myUp, myLook, myObs;
    myUp.x = xv; myUp.y = yv; myUp.z = zv;
    myLook.x = xa; myLook.y = ya; myLook.z = za;
    myObs.x = xo; myObs.y = yo; myObs.z = zo;

    // This seems very kludgy. Hacking time!
    // I'm forcing a struct to be a pointer to an array of floats.
    // @TODO: use the vector pointer type.
    GKSfloat *vup_ptr = (GKSfloat *)(&myUp);
    GKSfloat *lap_ptr = (GKSfloat *)(&myLook);
    GKSfloat *vrp_ptr = (GKSfloat *)(&myObs);
    
    GKSfloat *U_ptr = (GKSfloat *)(&U);
    GKSfloat *V_ptr = (GKSfloat *)(&V);
    GKSfloat *N_ptr = (GKSfloat *)(&N);
    GKSfloat *un_ptr = (GKSfloat *)(&un);
    GKSfloat *vn_ptr = (GKSfloat *)(&vn);
    GKSfloat *nn_ptr = (GKSfloat *)(&nn);

    vecsub(vrp_ptr, lap_ptr, N_ptr);
    vecnormal(N_ptr, nn_ptr);
    
    vecprod(vup_ptr, nn_ptr, U_ptr);
    vecnormal(U_ptr, un_ptr);
    
    vecprod(nn_ptr, un_ptr, V_ptr);
    vecnormal(V_ptr, vn_ptr);
    
    result[0][0] = un.x;
    result[0][1] = un.y;
    result[0][2] = un.z;
    result[0][3] = -myObs.x;
    result[1][0] = vn.x;
    result[1][1] = vn.y;
    result[1][2] = vn.z;
    result[1][3] = -myObs.y;
    result[2][0] = nn.x;
    result[2][1] = nn.y;
    result[2][2] = nn.z;
    result[2][3] = -myObs.z;
    result[3][0] = 0.0;
    result[3][1] = 0.0;
    result[3][2] = 0.0;
    result[3][3] = 1.0;
    
//    gks_set_view_plane_normal(nn.x, nn.y, nn.z);

}
