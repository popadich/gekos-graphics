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
    kAlternateProjection
} ProjectionType;

void gks_projection_init(GKScontext3DPtr context_ptr);
//ProjectionType gks_projection_get_type(GKScontext3DPtr context_ptr);

void gks_projection_set_orthogonal(GKScontext3DPtr context_ptr);
void gks_projection_set_simple(GKScontext3DPtr context_ptr, GKSfloat focalDistance);
void gks_projection_set_perspective(GKScontext3DPtr context_ptr, GKSfloat alpha, GKSfloat near, GKSfloat far);
void gks_projection_set_alternate(GKScontext3DPtr context_ptr, GKSfloat alpha, GKSfloat near, GKSfloat far);

GKSmatrix_3 *gks_projection_get_matrix(GKScontext3DPtr context_ptr);
void gks_projection_set_matrix(GKScontext3DPtr context_ptr, GKSmatrix_3 new_matrix);

#endif /* gks_3d_projection_h */
