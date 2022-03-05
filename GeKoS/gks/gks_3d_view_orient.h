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

void gks_create_view_matrix(double xo, double yo, double zo,
                        double xn, double yn, double zn,
                        double xv, double yv, double zv, Matrix_3 result);

void gks_compute_look_at_matrix(double xo, double yo, double zo,
                            double xa, double ya, double za,
                            double xv, double yv, double zv, Matrix_3 result);

void gks_set_view_matrix(Matrix_3 matrix);
Matrix_3 *gks_get_view_matrix(void);



#endif /* gks_3d_view_orient_h */
