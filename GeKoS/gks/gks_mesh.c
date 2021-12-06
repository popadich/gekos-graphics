//
//  gks_mesh.c
//  GeKoS
//
//  Created by Alex Popadich on 12/5/21.
//

#include <stdlib.h>
#include "gks_mesh.h"

Object_3 *CubeMesh(void)
{
    static Gpt_3 cubevert[GKS_CUBE_VERTEX_COUNT] = {
        {0.0, 0.0, 0.0},
        {1.0, 0.0, 0.0},
        {1.0, 1.0, 0.0},
        {0.0, 1.0, 0.0},
        {0.0, 0.0, 1.0},
        {1.0, 0.0, 1.0},
        {1.0, 1.0, 1.0},
        {0.0, 1.0, 1.0}
    };
    static Gpoly_3 cubepoly[GKS_CUBE_POLYGON_COUNT] = {
        {4,4,3,2,1},
        {4,5,6,7,8},
        {4,1,5,8,4},
        {4,2,3,7,6},
        {4,1,2,6,5},
        {4,3,4,8,7}
    };

    Gpt_3 *p, *q;
    Object_3 *aCube;

    // clear memory allocation to zeros
    VertexArrayPtr vertexList = (VertexArrayPtr)calloc(GKS_CUBE_VERTEX_COUNT, sizeof(Gpt_3));
    PolygonArrayPtr polygonList = (PolygonArrayPtr)calloc(GKS_CUBE_POLYGON_COUNT, sizeof(Gpoly_3));
    
    // copy vertices using pointer arithmetic
    p = cubevert;
    q = vertexList;
    for(int i=0; i<GKS_CUBE_VERTEX_COUNT; i++) {
        q->x=p->x;
        q->y=p->y;
        q->z=p->z;
        p++; q++;
    }

    // copy polygons
    for(int i=0; i<GKS_CUBE_POLYGON_COUNT; i++) {
        int polygonSize = cubepoly[i][0] + 1; // +1 for polygon count value
        for(int j=0; j<polygonSize; j++) {
            polygonList[i][j] = cubepoly[i][j];
        }
    }

    aCube = (Object_3 *)calloc(1, sizeof(Object_3));
    aCube->vertices = vertexList;
    aCube->polygons = polygonList;
    aCube->vertnum = GKS_CUBE_VERTEX_COUNT;
    aCube->polynum = GKS_CUBE_POLYGON_COUNT;
    
    return aCube;
}


Object_3 *PyramidMesh(void)
{
    // Put some code here to configure a Pyramid.
    static Gpt_3 pyramidVertices[GKS_PYRAMID_VERTEX_COUNT] = {
        {0.0, 0.0, 0.0},
        {1.0, 0.0, 0.0},
        {1.0, 0.0, 1.0},
        {0.0, 0.0, 1.0},
        {0.5, 0.6636661, 0.5}
    };
    static Gpoly_3 pyramidPolys[GKS_PYRAMID_POLYGON_COUNT] = {
        {4,1,2,3,4},
        {3,1,5,2},
        {3,2,5,3},
        {3,3,5,4},
        {3,4,5,1}
    };

    Gpt_3 *p, *q;
    Object_3 *aPyramid = NULL;

    // clear memory allocation to zeros
    VertexArrayPtr vertexList = (VertexArrayPtr)calloc(GKS_PYRAMID_VERTEX_COUNT, sizeof(Gpt_3));
    PolygonArrayPtr polygonList = (PolygonArrayPtr)calloc(GKS_PYRAMID_POLYGON_COUNT, sizeof(Gpoly_3));

    // copy vertices using pointer arithmetic
    p = pyramidVertices;
    q = vertexList;
    for(int i=0; i<GKS_PYRAMID_VERTEX_COUNT; i++) {
        q->x=p->x;
        q->y=p->y;
        q->z=p->z;
        p++; q++;
    }

    // copy polygon data using array indexing
    for(int i=0; i<GKS_PYRAMID_POLYGON_COUNT; i++) {
        int polygonSize = pyramidPolys[i][0] + 1;
        for(int j=0; j<polygonSize; j++) {
            polygonList[i][j] = pyramidPolys[i][j];
        }
    }
    
    aPyramid = (Object_3 *)calloc(1, sizeof(Object_3));
    aPyramid->vertices = vertexList;
    aPyramid->vertnum = GKS_PYRAMID_VERTEX_COUNT;
    aPyramid->polygons = polygonList;
    aPyramid->polynum = GKS_PYRAMID_POLYGON_COUNT;
    
    return aPyramid;
}
