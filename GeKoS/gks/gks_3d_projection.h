//
//  gks_3d_projection.h
//  GeKoS
//
//  Created by Alex Popadich on 12/6/21.
//

#ifndef gks_3d_projection_h
#define gks_3d_projection_h

#include "gks_types.h"

typedef enum {
    kOrthogonalProjection = 0,
    kPerspectiveSimpleProjection,
    kPerspectiveProjection,
    kAxonometricProjection
} ProjectionType;

void gks_projection_init(void);
ProjectionType gks_projection_get_type(void);

void gks_projection_set_orthogonal(void);
void gks_projection_set_simple(GKSfloat focalDistance);
void gks_projection_set_perspective(GKSfloat alpha, GKSfloat near, GKSfloat far);
void gks_projection_set_alternate(GKSfloat alpha, GKSfloat near, GKSfloat far);

GKSmatrix_3 *gks_projection_get_matrix(void);
void gks_projection_set_matrix(GKSmatrix_3 new_matrix);

#endif /* gks_3d_projection_h */
