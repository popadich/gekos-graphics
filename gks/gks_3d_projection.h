//
//  gks_3d_projection.h
//  GeKoS
//
//  Created by Alex Popadich on 12/6/21.
//

#pragma once

#include "gks_types.h"

typedef enum {
    kOrthogonalProjection = 0,
    kPerspectiveSimpleProjection,
    kPerspectiveProjection,
    kAlternateProjection
} ProjectionType;

void gks_projection_init(GKScontext3DPtr context_ptr);

void gks_projection_set_orthogonal(GKScontext3DPtr context_ptr);
void gks_projection_set_simple(GKScontext3DPtr context_ptr, GKSfloat focalDistance);
void gks_projection_set_perspective(GKScontext3DPtr context_ptr, GKSfloat alpha, GKSfloat near, GKSfloat far);
void gks_projection_set_alternate(GKScontext3DPtr context_ptr, GKSfloat alpha, GKSfloat near, GKSfloat far);

GKSmatrixPtr gks_projection_get_matrix(GKScontext3DPtr context_ptr);

