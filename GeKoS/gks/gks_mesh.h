//
//  gks_mesh.h
//  GeKoS
//
//  Created by Alex Popadich on 12/5/21.
//

#ifndef gks_mesh_h
#define gks_mesh_h

#include <stdbool.h>
#include "gks_types.h"


#define GKS_CUBE_VERTEX_COUNT    8
#define GKS_CUBE_POLYGON_COUNT   6

#define GKS_PYRAMID_VERTEX_COUNT    5
#define GKS_PYRAMID_POLYGON_COUNT   5

#define GKS_HOUSE_VERTEX_COUNT 10
#define GKS_HOUSE_POLYGON_COUNT 7

void setMeshCenteredFlag(bool isCentered);
GKSmesh_3 *MeshOfKind(GKSobjectKind kind);

GKSmesh_3 *CubeMesh(void);
GKSmesh_3 *PyramidMesh(void);
GKSmesh_3 *HouseMesh(void);
GKSmesh_3 *SphereMesh(void);

#endif /* gks_mesh_h */
