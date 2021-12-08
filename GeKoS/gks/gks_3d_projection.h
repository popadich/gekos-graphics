//
//  gks_3d_projection.h
//  GeKoS
//
//  Created by Alex Popadich on 12/6/21.
//

#ifndef gks_3d_projection_h
#define gks_3d_projection_h

#include "gks_types.h"

void gks_init_projection(void);
ProjectionType gks_get_projection_type(void);

void gks_enable_orthogonal_projection(void);
void gks_enable_perspective_projection(void);

Matrix_4 *gks_get_projection_matrix(void);

void gks_set_perspective_depth(Gfloat distance);
Gfloat gks_get_perspective_depth(void);

#endif /* gks_3d_projection_h */
