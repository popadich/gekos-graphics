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

void gks_init_projection(void);
ProjectionType gks_get_projection_type(void);

void gks_set_orthogonal_projection(void);
void gks_set_perspective_simple(GKSfloat focalDistance);
void gks_set_perspective_projection(GKSfloat alpha, GKSfloat near, GKSfloat far);
void gks_set_perspective_alternate(GKSfloat alpha, GKSfloat near, GKSfloat far);


// Getter
GKSmatrix_3 *gks_get_projection_matrix(void);

#endif /* gks_3d_projection_h */
