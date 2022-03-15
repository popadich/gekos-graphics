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

GKSobject_3 *CubeMesh(void)
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
    GKSobject_3 *aCube;
    
    //normal
    GKSpoint_3 p1;
    GKSpoint_3 p2;
    GKSpoint_3 p3;
    GKSvector3d normal;

    // clear memory allocation to zeros
    GKSvertexArrPtr vertexList = (GKSvertexArrPtr)calloc(GKS_CUBE_VERTEX_COUNT, sizeof(GKSpoint_3));
    GKSpolygonArrPtr polygonList = (GKSpolygonArrPtr)calloc(GKS_CUBE_POLYGON_COUNT, sizeof(GKSpolygon_3));
    GKSnormalArrPtr normalList = (GKSnormalArrPtr)calloc(GKS_CUBE_POLYGON_COUNT, sizeof(GKSvector3d));
    GKSvertexArrPtr transVertList = (GKSvertexArrPtr)calloc(GKS_CUBE_VERTEX_COUNT, sizeof(GKSpoint_3));
    GKSDCArrPtr devCoordList = (GKSDCArrPtr)calloc(GKS_CUBE_VERTEX_COUNT, sizeof(GKSpoint_2));

    // copy vertices using pointer arithmetic
    p = cubevert;
    q = vertexList;
    for(int i=0; i<GKS_CUBE_VERTEX_COUNT; i++) {
        q->crd.x = p->x;
        q->crd.y = p->y;
        q->crd.z = p->z;
        q->crd.w = 1.0;
        p++; q++;
    }

    // copy polygons
    for(int i=0; i<GKS_CUBE_POLYGON_COUNT; i++) {
        int polygonSize = cubepoly[i][0] + 1; // +1 for polygon count value
        for(int j=0; j<polygonSize; j++) {
            polygonList[i][j] = cubepoly[i][j];
        }
        
        // compute normals polygon vertices are numbered from 1 vertex array is zero based.
        p1 = cubevert[cubepoly[i][1] - 1];
        p2 = cubevert[cubepoly[i][2] - 1];
        p3 = cubevert[cubepoly[i][3] - 1];
        gks_plane_equation_3(p1, p2, p3, &normal);
        normalList[i] = normal;
        
    }

    aCube = (GKSobject_3 *)calloc(1, sizeof(GKSobject_3));
    aCube->vertices = vertexList;
    aCube->polygons = polygonList;
    aCube->normals = normalList;
    aCube->transverts = transVertList;
    aCube->devcoords = devCoordList;
    aCube->vertnum = GKS_CUBE_VERTEX_COUNT;
    aCube->polynum = GKS_CUBE_POLYGON_COUNT;
    
    return aCube;
}


GKSobject_3 *PyramidMesh(void)
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
    GKSobject_3 *aPyramid = NULL;

    //normal
    GKSpoint_3 p1;
    GKSpoint_3 p2;
    GKSpoint_3 p3;
    GKSvector3d normal;
    
    
    // clear memory allocation to zeros
    GKSvertexArrPtr vertexList = (GKSvertexArrPtr)calloc(GKS_PYRAMID_VERTEX_COUNT, sizeof(GKSpoint_3));
    GKSpolygonArrPtr polygonList = (GKSpolygonArrPtr)calloc(GKS_PYRAMID_POLYGON_COUNT, sizeof(GKSpolygon_3));
    GKSnormalArrPtr normalList = (GKSnormalArrPtr)calloc(GKS_PYRAMID_POLYGON_COUNT, sizeof(GKSpoint_3));
    GKSvertexArrPtr transList = (GKSvertexArrPtr)calloc(GKS_PYRAMID_VERTEX_COUNT, sizeof(GKSpoint_3));
    GKSDCArrPtr devCoordList = (GKSDCArrPtr)calloc(GKS_PYRAMID_VERTEX_COUNT, sizeof(GKSpoint_2));

    // copy vertices using pointer arithmetic
    p = pyrverts;
    q = vertexList;
    for(int i=0; i<GKS_PYRAMID_VERTEX_COUNT; i++) {
        q->crd.x = p->x;
        q->crd.y = p->y;
        q->crd.z = p->z;
        q->crd.w = 1.0;
        p++; q++;
    }

    // copy polygon data using array indexing
    for(int i=0; i<GKS_PYRAMID_POLYGON_COUNT; i++) {
        int polygonSize = pyrpolys[i][0] + 1;
        for(int j=0; j<polygonSize; j++) {
            polygonList[i][j] = pyrpolys[i][j];
        }
        // compute normals polygon vertices are numbered from 1 vertex array is zero based.
        p1 = pyrverts[pyrpolys[i][1] - 1];
        p2 = pyrverts[pyrpolys[i][2] - 1];
        p3 = pyrverts[pyrpolys[i][3] - 1];
        gks_plane_equation_3(p1, p2, p3, &normal);
        normalList[i] = normal;

    }
    
    aPyramid = (GKSobject_3 *)calloc(1, sizeof(GKSobject_3));
    aPyramid->vertices = vertexList;
    aPyramid->vertnum = GKS_PYRAMID_VERTEX_COUNT;
    aPyramid->polygons = polygonList;
    aPyramid->polynum = GKS_PYRAMID_POLYGON_COUNT;
    aPyramid->normals = normalList;
    aPyramid->transverts = transList;
    aPyramid->devcoords = devCoordList;
    
    return aPyramid;
}

GKSobject_3 *HouseMesh(void)
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
    GKSobject_3 *anObject = NULL;

    // clear memory allocation to zeros
    GKSvertexArrPtr vertexList = (GKSvertexArrPtr)calloc(GKS_HOUSE_VERTEX_COUNT, sizeof(GKSpoint_3));
    GKSpolygonArrPtr polygonList = (GKSpolygonArrPtr)calloc(GKS_HOUSE_POLYGON_COUNT, sizeof(GKSpolygon_3));

    
    
    // copy vertices using pointer arithmetic
    p = objectvert;
    q = vertexList;
    for(int i=0; i<GKS_HOUSE_VERTEX_COUNT; i++) {
        q->crd.x = p->x;
        q->crd.y = p->y;
        q->crd.z = p->z;
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

    anObject = (GKSobject_3 *)calloc(1, sizeof(GKSobject_3));
    anObject->vertices = vertexList;
    anObject->vertnum = GKS_HOUSE_VERTEX_COUNT;
    anObject->polygons = polygonList;
    anObject->polynum = GKS_HOUSE_POLYGON_COUNT;
    
    return anObject;
}

GKSobject_3 *SphereMesh(void)
{
    double          sini;
    int             vertexCount = 0;
    int             polygonCount = 0;

    // degreeDelta and facetCount
    // parameters describing sphere sampling size this controls
    // the number of total vertices and polygons. It goes without
    // saying that the 'degreeDelta' value needs to be a even
    // denomintor of 360.
    int degreeDelta = 10;               // should be a parameter
    int facetCount = 360/degreeDelta;
    int computedVertexCount = (180/degreeDelta + 1) * (360/degreeDelta);
    int computedPolygonCount = computedVertexCount - facetCount;

    // allocate sub arrays and then the container structure object
    // use calloc to clear allocatted memory to zeros
    GKSvertexArrPtr vertexList = (GKSvertexArrPtr)calloc(computedVertexCount, sizeof(GKSpoint_3));
    GKSpolygonArrPtr polygonList = (GKSpolygonArrPtr)calloc(computedPolygonCount, sizeof(GKSpolygon_3));
    GKSnormalArrPtr normalList = (GKSnormalArrPtr)calloc(computedPolygonCount, sizeof(GKSpoint_3));
    
    GKSvertexArrPtr transVertList = (GKSvertexArrPtr)calloc(computedVertexCount, sizeof(GKSpoint_3));
    GKSDCArrPtr devCoordList = (GKSDCArrPtr)calloc(computedVertexCount, sizeof(GKSpoint_2));

    GKSobject_3 *aSphere = (GKSobject_3 *)calloc(1, sizeof(GKSobject_3));
    
    // construct vertices
   for (int i=0; i<=180; i+=degreeDelta) {
        for (int j=0; j<360; j+=degreeDelta) {
            sini = sin(i*DEG_TO_RAD);
            int idx = (j+(i*facetCount))/degreeDelta;
            vertexList[idx].crd.x = 0.5 * sini * cos(j*DEG_TO_RAD);
            vertexList[idx].crd.y = 0.5 * sini * sin(j*DEG_TO_RAD);
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
    aSphere->normals = normalList;
    aSphere->vertnum = vertexCount;
    aSphere->polynum = polygonCount;
    aSphere->transverts = transVertList;
    aSphere->devcoords = devCoordList;

    return aSphere;
}

