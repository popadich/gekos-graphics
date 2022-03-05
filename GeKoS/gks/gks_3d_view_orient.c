//
//  gks_3d_view_orient.c
//  GeKoS
//
//  Created by Alex Popadich on 12/16/21.
//

#include "gks_3d_view_orient.h"
#include "gks_3d_matrix.h"

// P R I V A T E    O K
static Matrix_3      gViewMatrix_4;       // View Plane Orientation Matrix

void gks_init_view_plane(void)
{
    Matrix_3 viewTransMatrix = {
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


void gks_set_view_matrix(Matrix_3 viewMatrix)
{
    for(int i=0; i<4; i++)
        for (int j=0; j<4; j++)
            gViewMatrix_4[i][j] = viewMatrix[i][j];
}

Matrix_3 *gks_get_view_matrix(void)
{
    return &gViewMatrix_4;
}

// @TODO: problems when view plane normal matches up vector
// When (xn,yn,zn) is set to (0,1,0) things blow up
void gks_create_view_matrix(double xo, double yo, double zo,
                        double xn, double yn, double zn,
                        double xv, double yv, double zv, Matrix_3 result) {
    Gpt_3 u,v,un,vn,nn;
    Gpt_3 x;
    Gfloat normalization_coeff;
    
    Gpt_3 myUp, myNorm, myObs;
    myUp.x = xv; myUp.y = yv; myUp.z = zv;
    myNorm.x = xn; myNorm.y = yn; myNorm.z = zn;
    myObs.x = xo; myObs.y = yo; myObs.z = zo;
    
    Gfloat *vup_ptr = (Gfloat *)(&myUp);
    Gfloat *vpn_ptr = (Gfloat *)(&myNorm);
    
    Gfloat *u_ptr = (Gfloat *)(&u);
    Gfloat *v_ptr = (Gfloat *)(&v);
    Gfloat *un_ptr = (Gfloat *)(&un);
    Gfloat *vn_ptr = (Gfloat *)(&vn);
    Gfloat *nn_ptr = (Gfloat *)(&nn);
    Gfloat *x_ptr = (Gfloat *)(&x);

    normalization_coeff = vecdot(vup_ptr, vpn_ptr) / vecdot(vpn_ptr, vpn_ptr);
    vecscale(normalization_coeff, vpn_ptr, x_ptr);
    vecsub(vup_ptr, x_ptr, v_ptr);
    vecprod(vup_ptr, vpn_ptr, u_ptr);
    
    vecnormal(u_ptr, un_ptr);
    vecnormal(v_ptr, vn_ptr);
    vecnormal(vpn_ptr, nn_ptr);

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
                            double xv, double yv, double zv, Matrix_3 result)
{
    Gpt_3 U, V, N, un, vn, nn;

    Gpt_3 myUp, myLook, myObs;
    myUp.x = xv; myUp.y = yv; myUp.z = zv;
    myLook.x = xa; myLook.y = ya; myLook.z = za;
    myObs.x = xo; myObs.y = yo; myObs.z = zo;

    // This seems very kludgy. Hacking time!
    // I'm forcing a struct to be a pointer to an array of floats.
    // @TODO: use the vector pointer type.
    Gfloat *vup_ptr = (Gfloat *)(&myUp);
    Gfloat *lap_ptr = (Gfloat *)(&myLook);
    Gfloat *vrp_ptr = (Gfloat *)(&myObs);
    
    Gfloat *U_ptr = (Gfloat *)(&U);
    Gfloat *V_ptr = (Gfloat *)(&V);
    Gfloat *N_ptr = (Gfloat *)(&N);
    Gfloat *un_ptr = (Gfloat *)(&un);
    Gfloat *vn_ptr = (Gfloat *)(&vn);
    Gfloat *nn_ptr = (Gfloat *)(&nn);

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
