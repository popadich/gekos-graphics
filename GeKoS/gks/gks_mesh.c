//
//  gks_mesh.c
//  GeKoS
//
//  Created by Alex Popadich on 12/5/21.
//

#include <stdlib.h>
#include <math.h>
#include "gks_mesh.h"
#include "gks_3d_matrix.h"

GKSmesh_3 *CubeMesh(bool centered)
{
    static GKSpoint_3 cubevert[GKS_CUBE_VERTEX_COUNT] = {
        {0.0, 0.0, 0.0},
        {1.0, 0.0, 0.0},
        {1.0, 1.0, 0.0},
        {0.0, 1.0, 0.0},
        {0.0, 0.0, 1.0},
        {1.0, 0.0, 1.0},
        {1.0, 1.0, 1.0},
        {0.0, 1.0, 1.0}
    };
    static GKSpolygon_3 cubepoly[GKS_CUBE_POLYGON_COUNT] = {
        {4,4,3,2,1},
        {4,5,6,7,8},
        {4,1,5,8,4},
        {4,2,3,7,6},
        {4,1,2,6,5},
        {4,3,4,8,7}
    };

    GKSpoint_3 *p;
    GKSvector3dPtr q;
    GKSmesh_3 *aCube;

    // clear memory allocation to zeros
    GKSvertexArrPtr vertexList = (GKSvertexArrPtr)calloc(GKS_CUBE_VERTEX_COUNT, sizeof(GKSvector3d));
    GKSpolygonArrPtr polygonList = (GKSpolygonArrPtr)calloc(GKS_CUBE_POLYGON_COUNT, sizeof(GKSpolygon_3));

    // copy vertices using pointer arithmetic
    p = cubevert;
    q = vertexList;
    for(int i=0; i<GKS_CUBE_VERTEX_COUNT; i++) {
        q->crd.x = p->x;
        q->crd.y = p->y;
        q->crd.z = p->z;
        if (centered){
            q->crd.x -= 0.5;
            q->crd.y -= 0.5;
            q->crd.z -= 0.5;
        }
        q->crd.w = 1.0;
        p++; q++;
    }

    // copy polygons
    for(int i=0; i<GKS_CUBE_POLYGON_COUNT; i++) {
        int polygonSize = cubepoly[i][0] + 1; // +1 for polygon count value
        for(int j=0; j<polygonSize; j++) {
            polygonList[i][j] = cubepoly[i][j];
        }
    }

    aCube = (GKSmesh_3 *)calloc(1, sizeof(GKSmesh_3));
    aCube->vertices = vertexList;
    aCube->polygons = polygonList;
    aCube->vertnum = GKS_CUBE_VERTEX_COUNT;
    aCube->polynum = GKS_CUBE_POLYGON_COUNT;
    
    return aCube;
}


GKSmesh_3 *PyramidMesh(bool centered)
{
    // Put some code here to configure a Pyramid.
    static GKSpoint_3 pyrverts[GKS_PYRAMID_VERTEX_COUNT] = {
        {0.0, 0.0, 0.0},
        {1.0, 0.0, 0.0},
        {1.0, 0.0, 1.0},
        {0.0, 0.0, 1.0},
        {0.5, 0.6636661, 0.5}
    };
    static GKSpolygon_3 pyrpolys[GKS_PYRAMID_POLYGON_COUNT] = {
        {4,1,2,3,4},
        {3,1,5,2},
        {3,2,5,3},
        {3,3,5,4},
        {3,4,5,1}
    };

    GKSpoint_3 *p;
    GKSvector3dPtr q;
    GKSmesh_3 *aPyramid = NULL;
    
    // clear memory allocation to zeros
    GKSvertexArrPtr vertexList = (GKSvertexArrPtr)calloc(GKS_PYRAMID_VERTEX_COUNT, sizeof(GKSvector3d));
    GKSpolygonArrPtr polygonList = (GKSpolygonArrPtr)calloc(GKS_PYRAMID_POLYGON_COUNT, sizeof(GKSpolygon_3));


    // copy vertices using pointer arithmetic
    p = pyrverts;
    q = vertexList;
    for(int i=0; i<GKS_PYRAMID_VERTEX_COUNT; i++) {
        q->crd.x = p->x;
        q->crd.y = p->y;
        q->crd.z = p->z;
        if (centered){
            q->crd.x -= 0.5;
            q->crd.y -= 0.5;
            q->crd.z -= 0.5;
        }
        q->crd.w = 1.0;
        p++; q++;
    }

    // copy polygon data using array indexing
    for(int i=0; i<GKS_PYRAMID_POLYGON_COUNT; i++) {
        int polygonSize = pyrpolys[i][0] + 1;
        for(int j=0; j<polygonSize; j++) {
            polygonList[i][j] = pyrpolys[i][j];
        }
    }
    
    aPyramid = (GKSmesh_3 *)calloc(1, sizeof(GKSmesh_3));
    aPyramid->vertices = vertexList;
    aPyramid->vertnum = GKS_PYRAMID_VERTEX_COUNT;
    aPyramid->polygons = polygonList;
    aPyramid->polynum = GKS_PYRAMID_POLYGON_COUNT;
    aPyramid->transverts = NULL;
    
    return aPyramid;
}

GKSmesh_3 *HouseMesh(bool centered)
{
    static GKSpoint_3 objectvert[GKS_HOUSE_VERTEX_COUNT] = {
        {0, 0,30},
        {16, 0,30},
        {16,10,30},
        {8,16,30},
        {0,10,30},
        {0, 0,54},
        {16, 0,54},
        {16,10,54},
        {8,16,54},
        {0,10,54}
    };
    static GKSpolygon_3 objectpoly[GKS_HOUSE_POLYGON_COUNT] = {
        {5, 5, 4, 3, 2, 1},
        {5, 6, 7, 8, 9, 10},
        {4, 1, 2, 7, 6},
        {4, 2, 3, 8, 7},
        {4, 1, 6, 10, 5},
        {4, 3, 4, 9, 8},
        {4, 4, 5, 10, 9}
    };
    
    GKSpoint_3 *p;
    GKSvector3dPtr q;
    GKSmesh_3 *aHouse = NULL;

    // clear memory allocation to zeros
    GKSvertexArrPtr vertexList = (GKSvertexArrPtr)calloc(GKS_HOUSE_VERTEX_COUNT, sizeof(GKSvector3d));
    GKSpolygonArrPtr polygonList = (GKSpolygonArrPtr)calloc(GKS_HOUSE_POLYGON_COUNT, sizeof(GKSpolygon_3));
    GKSvertexArrPtr transList = NULL;

    
    // copy vertices using pointer arithmetic
    p = objectvert;
    q = vertexList;
    for(int i=0; i<GKS_HOUSE_VERTEX_COUNT; i++) {
        q->crd.x = p->x;
        q->crd.y = p->y;
        q->crd.z = p->z;
        if (centered){
            q->crd.x -= 8.0;
            q->crd.y -= 8.0;
            q->crd.z -= 42.0;
        }
        q->crd.w = 1.0;
        p++; q++;
    }

    // copy polygon data using array indexing
    for(int i=0; i<GKS_HOUSE_POLYGON_COUNT; i++) {
        int polygonSize = objectpoly[i][0] + 1;
        for(int j=0; j<polygonSize; j++) {
            polygonList[i][j] = objectpoly[i][j];
        }
    }

    aHouse = (GKSmesh_3 *)calloc(1, sizeof(GKSmesh_3));
    aHouse->vertices = vertexList;
    aHouse->vertnum = GKS_HOUSE_VERTEX_COUNT;
    aHouse->polygons = polygonList;
    aHouse->polynum = GKS_HOUSE_POLYGON_COUNT;
    aHouse->transverts = transList;
    
    return aHouse;
}

GKSmesh_3 *SphereMesh(bool centered)
{
    double          sine_of_i;
    int             vertexCount = 0;
    int             polygonCount = 0;

    // degreeDelta and facetCount
    // parameters describing sphere sampling size this controls
    // the number of total vertices and polygons. It goes without
    // saying that the 'degreeDelta' value needs to be a even
    // denominator of 360.
    int degreeDelta = 10;               // should be a parameter
    int facetCount = 360/degreeDelta;
    int computedVertexCount = (180/degreeDelta + 1) * (360/degreeDelta);
    int computedPolygonCount = computedVertexCount - facetCount;

    // allocate sub arrays and then the container structure object
    // use calloc to clear allocatted memory to zeros
    GKSvertexArrPtr vertexList = (GKSvertexArrPtr)calloc(computedVertexCount, sizeof(GKSvector3d));
    GKSpolygonArrPtr polygonList = (GKSpolygonArrPtr)calloc(computedPolygonCount, sizeof(GKSpolygon_3));
    GKSmesh_3 *aSphere = (GKSmesh_3 *)calloc(1, sizeof(GKSmesh_3));
    
    // construct vertices
   for (int i=0; i<=180; i+=degreeDelta) {
        for (int j=0; j<360; j+=degreeDelta) {
            sine_of_i = sin(i*DEG_TO_RAD);
            int idx = (j+(i*facetCount))/degreeDelta;
            vertexList[idx].crd.x = 0.5 * sine_of_i * cos(j*DEG_TO_RAD);
            vertexList[idx].crd.y = 0.5 * sine_of_i * sin(j*DEG_TO_RAD);
            vertexList[idx].crd.z = 0.5 * cos(i*DEG_TO_RAD);
            vertexList[idx].crd.w = 1.0;
            vertexCount += 1;
        }
    }
    
    // construct polygons
    for (int i=0; i<computedPolygonCount; i+=facetCount) {
        for (int j=0; j<facetCount; j++) {
            polygonList[j+i][0]= 4;
            polygonList[j+i][1]= j+i+1;
            polygonList[j+i][2] = ((j+1) % facetCount) + i + 1;;
            polygonList[j+i][3] = polygonList[j+i][2]+facetCount;
            polygonList[j+i][4] = polygonList[j+i][1]+facetCount;
            polygonCount += 1;
        }
    }

    if (computedPolygonCount != polygonCount) {
        // Should throw something, because this should never happen
        // printf("Something is wrong !!\n");
        return NULL;
    }
    
    if (computedVertexCount != vertexCount) {
        // throw something here, because this should never happen
        // NSLog(@"ERROR: vertex counts do not match.");
        return NULL;
    }
    
    aSphere->vertices = vertexList;
    aSphere->polygons = polygonList;
    aSphere->vertnum = vertexCount;
    aSphere->polynum = polygonCount;

    return aSphere;
}

