//
//  gks_mesh.h
//  GeKoS
//
//  Created by Alex Popadich on 12/5/21.
//

#ifndef gks_mesh_h
#define gks_mesh_h

#include "gks_types.h"

#define GKS_CUBE_VERTEX_COUNT    8
#define GKS_CUBE_POLYGON_COUNT   6

#define GKS_PYRAMID_VERTEX_COUNT    5
#define GKS_PYRAMID_POLYGON_COUNT   5

Object_3 *CubeMesh(void);
Object_3 *PyramidMesh(void);

#endif /* gks_mesh_h */
