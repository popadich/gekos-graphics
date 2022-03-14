//
//  gks_3d_view_orient.h
//  GeKoS
//
//  Created by Alex Popadich on 12/16/21.
//

#ifndef gks_3d_view_orient_h
#define gks_3d_view_orient_h

#include "gks_types.h"

void gks_init_view_plane(void);

void gks_create_view_matrix(double obsX, double obsY, double obsZ,
                            double dirX, double dirY, double dirZ,
                            double upX, double upY, double upZ,
                            GKSmatrix_3 result);

void gks_create_camera_view_matrix(double obsX, double obsY, double obsZ,
                                   double dirX, double dirY, double dirZ,
                                   double upX, double upY, double upZ,
                                   GKSmatrix_3 result);

void gks_compute_look_at_matrix(double xo, double yo, double zo,
                                double xa, double ya, double za,
                                double xv, double yv, double zv,
                                GKSmatrix_3 result);

void gks_compute_camera_look_at_matrix(double obsX, double obsY, double obsZ,
                                       double lookX, double lookY, double lookZ,
                                       double upX, double upY, double upZ,
                                       GKSmatrix_3 result);

void gks_compute_dir_vector(GKSvector3d location, GKSvector3d look, GKSvector3dPtr dir);

void gks_set_view_matrix(GKSmatrix_3 matrix);

GKSmatrix_3 *gks_get_view_matrix(void);

#endif /* gks_3d_view_orient_h */
