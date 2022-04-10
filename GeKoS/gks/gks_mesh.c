//
//  gks_mesh.c
//  GeKoS
//
//  Created by Alex Popadich on 12/5/21.
//

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "gks_mesh.h"
#include "gks_3d_matrix.h"

static bool centeredFlag = false;


GKSmesh_3 *MeshOfKind(GKSobjectKind kind)
{
    GKSmesh_3 *theMesh = NULL;
    switch (kind) {
        case kSpaceConeKind:
            theMesh = ConeHead();
            break;;
        case kPyramidKind:
            theMesh = PyramidMesh();
            break;;
        case kHouseKind:
            theMesh = HouseMesh();
            break;
        case kSphereKind:
            theMesh = SphereMesh();
            break;
        case kCubeKind:
            theMesh = CubeMesh();
            break;
        default:
            break;
    }

    return theMesh;
}

GKSmesh_3 *CubeMesh(void)
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
    static GKSpolygon_3 object_poly[GKS_CUBE_POLYGON_COUNT] = {
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
//    GKSpolygonArrPtr polygonList = (GKSpolygonArrPtr)calloc(GKS_CUBE_POLYGON_COUNT, sizeof(GKSpolygon_3));
    GKSint *compactPolyList = (GKSint *)calloc(GKS_CUBE_PARRAY_SIZE, sizeof(GKSint));

    // copy vertices using pointer arithmetic
    p = cubevert;
    q = vertexList;
    for(int i=0; i<GKS_CUBE_VERTEX_COUNT; i++) {
        q->crd.x = p->x;
        q->crd.y = p->y;
        q->crd.z = p->z;
        if (centeredFlag){
            q->crd.x -= 0.5;
            q->crd.y -= 0.5;
            q->crd.z -= 0.5;
        }
        q->crd.w = 1.0;
        p++; q++;
    }

    // copy polygons
    int k = 0;
    for(int i=0; i<GKS_CUBE_POLYGON_COUNT; i++) {
        int polygonSize = object_poly[i][0] + 1; // +1 includes the polygon count value as part of the size
        for(int j=0; j<polygonSize; j++) {
//            polygonList[i][j] = object_poly[i][j];
            
            compactPolyList[k] = object_poly[i][j];    // compact string all in a row
            k += 1;
        }
    }

    aCube = (GKSmesh_3 *)calloc(1, sizeof(GKSmesh_3));
    aCube->vertices = vertexList;
//    aCube->polygons = polygonList;
    aCube->polygons_compact = compactPolyList;
    aCube->vertnum = GKS_CUBE_VERTEX_COUNT;
    aCube->polynum = GKS_CUBE_POLYGON_COUNT;
    
    return aCube;
}


GKSmesh_3 *PyramidMesh(void)
{
    // Put some code here to configure a Pyramid.
    static GKSpoint_3 pyrverts[GKS_PYRAMID_VERTEX_COUNT] = {
        {0.0, 0.0, 0.0},
        {1.0, 0.0, 0.0},
        {1.0, 0.0, 1.0},
        {0.0, 0.0, 1.0},
        {0.5, 0.6636661, 0.5}
    };
    static GKSpolygon_3 object_poly[GKS_PYRAMID_POLYGON_COUNT] = {
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
//    GKSpolygonArrPtr polygonList = (GKSpolygonArrPtr)calloc(GKS_PYRAMID_POLYGON_COUNT, sizeof(GKSpolygon_3));
    GKSint *compactPolyList = (GKSint *)calloc(GKS_PYRAMID_PARRAY_SIZE, sizeof(GKSint)); // one extra for buffer


    // copy vertices using pointer arithmetic
    p = pyrverts;
    q = vertexList;
    for(int i=0; i<GKS_PYRAMID_VERTEX_COUNT; i++) {
        q->crd.x = p->x;
        q->crd.y = p->y;
        q->crd.z = p->z;
        if (centeredFlag){
            q->crd.x -= 0.5;
            q->crd.y -= 0.5;
            q->crd.z -= 0.5;
        }
        q->crd.w = 1.0;
        p++; q++;
    }

    // copy polygon data using array indexing
    int k = 0;
    for(int i=0; i<GKS_PYRAMID_POLYGON_COUNT; i++) {
        int polygonSize = object_poly[i][0] + 1;
        for(int j=0; j<polygonSize; j++) {
//            polygonList[i][j] = object_poly[i][j];
            
            compactPolyList[k] = object_poly[i][j];    // compact string all in a row
            k += 1;
        }
    }
    
    aPyramid = (GKSmesh_3 *)calloc(1, sizeof(GKSmesh_3));
    aPyramid->vertices = vertexList;
    aPyramid->vertnum = GKS_PYRAMID_VERTEX_COUNT;
//    aPyramid->polygons = polygonList;
    aPyramid->polynum = GKS_PYRAMID_POLYGON_COUNT;
    aPyramid->polygons_compact = compactPolyList;

    return aPyramid;
}

GKSmesh_3 *HouseMesh(void)
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
    static GKSpolygon_3 object_poly[GKS_HOUSE_POLYGON_COUNT] = {
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
//    GKSpolygonArrPtr polygonList = (GKSpolygonArrPtr)calloc(GKS_HOUSE_POLYGON_COUNT, sizeof(GKSpolygon_3));
    GKSint *compactPolyList = (GKSint *)calloc(GKS_HOUSE_PARRAY_SIZE, sizeof(GKSint)); // one extra for buffer
    
    // copy vertices using pointer arithmetic
    p = objectvert;
    q = vertexList;
    for(int i=0; i<GKS_HOUSE_VERTEX_COUNT; i++) {
        q->crd.x = p->x;
        q->crd.y = p->y;
        q->crd.z = p->z;
        if (centeredFlag){
            q->crd.x -= 8.0;
            q->crd.y -= 8.0;
            q->crd.z -= 42.0;
        }
        q->crd.w = 1.0;
        p++; q++;
    }

    // copy polygon data using array indexing
    int k = 0;
    for(int i=0; i<GKS_HOUSE_POLYGON_COUNT; i++) {
        int polygonSize = object_poly[i][0] + 1;
        for(int j=0; j<polygonSize; j++) {
//            polygonList[i][j] = object_poly[i][j];
            
            compactPolyList[k] = object_poly[i][j];    // compact string all in a row
            k += 1;
        }
    }

    aHouse = (GKSmesh_3 *)calloc(1, sizeof(GKSmesh_3));
    aHouse->vertices = vertexList;
    aHouse->vertnum = GKS_HOUSE_VERTEX_COUNT;
//    aHouse->polygons = polygonList;
    aHouse->polynum = GKS_HOUSE_POLYGON_COUNT;
    aHouse->polygons_compact = compactPolyList;

    return aHouse;
}

GKSmesh_3 *SphereMesh(void)
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
//    GKSpolygonArrPtr polygonList = (GKSpolygonArrPtr)calloc(computedPolygonCount, sizeof(GKSpolygon_3));
    GKSint *compactPolyList = (GKSint *)calloc(5000, sizeof(GKSint)); // TODO: compute size of buffer
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
    int k = 0;
    for (int i=0; i<computedPolygonCount; i+=facetCount) {
        for (int j=0; j<facetCount; j++) {
//            polygonList[j+i][0] = 4;
            compactPolyList[k] = 4;
            k += 1;
//            polygonList[j+i][1]= j+i+1;
            GKSint save1 = j+i+1;
            compactPolyList[k] = j+i+1;
            k += 1;
//            polygonList[j+i][2] = ((j+1) % facetCount) + i + 1;
            GKSint save2 = ((j+1) % facetCount) + i + 1;
            compactPolyList[k] = ((j+1) % facetCount) + i + 1;
            k += 1;
//            polygonList[j+i][3] = polygonList[j+i][2]+facetCount;
            compactPolyList[k] = save2 + facetCount;
            k += 1;
//            polygonList[j+i][4] = polygonList[j+i][1]+facetCount;
            compactPolyList[k] = save1 + facetCount;
            k += 1;
            polygonCount += 1;
            
        }
    }
    
//    printf("Size of sphere polygons: %d\n", polygonCount * 4 + polygonCount);
//    printf("Size of compact polygons: %d\n", k);
//
    
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
//    aSphere->polygons = polygonList;
    aSphere->vertnum = vertexCount;
    aSphere->polynum = polygonCount;
    aSphere->polygons_compact = compactPolyList;

    return aSphere;
}

GKSmesh_3 *ConeHead(void)
{
    GKSint vertex_count = 0;
    
    // degreeDelta describes a circle sampling at the base of a cone
    // fron that we compute the number of total vertices and polygons.
    // It goes without saying that the 'degreeDelta' value needs to be a even
    // denominator of 360.
    int degreeDelta = 10;               // should be a parameter
    int computedVertexCount = (360/degreeDelta) + 1 + 1;
    int computedPolygonCount = 360/degreeDelta * 2 + 2;
    
    // allocate sub arrays and then the container structure object
    // use calloc to clear allocatted memory to zeros
    GKSvertexArrPtr vertex_array = (GKSvertexArrPtr)calloc(computedVertexCount, sizeof(GKSvector3d));
//    GKSpolygonArrPtr polygon_array = (GKSpolygonArrPtr)calloc(computedPolygonCount, sizeof(GKSpolygon_3));
    GKSint *compact_array = (GKSint *)calloc(5000, sizeof(GKSint)); // TODO: compute size of buffer
    GKSmesh_3 *aCone = (GKSmesh_3 *)calloc(1, sizeof(GKSmesh_3));
    
    
    // construct vertices
    int  idx = vertex_count;
    // center point of base at zero
    vertex_array[idx].crd.x = 0.0;
    vertex_array[idx].crd.y = 0.0;
    vertex_array[idx].crd.z = 0.0;
    vertex_array[idx].crd.w = 1.0;
    vertex_count += 1;
    // center point of peak at one
    vertex_array[idx+1].crd.x = 0.0;
    vertex_array[idx+1].crd.y = 1.0;
    vertex_array[idx+1].crd.z = 0.0;
    vertex_array[idx+1].crd.w = 1.0;
    vertex_count += 1;

    // vertices at edge of circle on X-Z plane
    for (int j=0; j<360; j+=degreeDelta) {
        idx = vertex_count;
        vertex_array[idx].crd.x = 0.5 * cos(j*DEG_TO_RAD);
        vertex_array[idx].crd.y = 0.0;
        vertex_array[idx].crd.z = 0.5 * sin(j*DEG_TO_RAD);
        vertex_array[idx].crd.w = 1.0;
        vertex_count += 1;
    }

    
    //    for (GKSint i=0; i<vertex_count; i++) {
    //        printf("vert %d: %lf, %lf, %lf\n", i,
    //               vertex_array[i].crd.x,
    //               vertex_array[i].crd.y,
    //               vertex_array[i].crd.z);
    //    }

    // construct polygons
    GKSint O0 = 0;
    GKSint O1 = 1;
    GKSint P1 = 2;
    GKSint P2 = 3;
    GKSint polygonSize = 3;
    GKSint polygon_count = (vertex_count - 2) * 2 + 2;
    
//    printf("poly counts: %d   %d\n\n", computedPolygonCount, polygon_count);

    GKSint k = 0;
    for(GKSint i=0; i < polygon_count - 2; i+=2) {
        
        // polygon 1
//        polygon_array[i][0] = polygonSize;
        compact_array[k] = polygonSize;
        k += 1;
        
        // from center of base to segment at rim
//        polygon_array[i][1] = O0 + 1;
        compact_array[k] = O0 + 1;
        k += 1;
        
//        polygon_array[i][2] = P1 + 1;
        compact_array[k] = P1 + 1;
        k += 1;
        
//        polygon_array[i][3] = P2 + 1;
        compact_array[k] = P2 + 1;
        k += 1;
        
        
        // polygon 2
//        polygon_array[i+1][0] = polygonSize;
        compact_array[k] = polygonSize;
        k += 1;
        
        // from peak to segment at rim
//        polygon_array[i+1][1] = O1 + 1;
        compact_array[k] = O1 + 1;
        k += 1;
        
//        polygon_array[i+1][2] = P1 + 1;
        compact_array[k] = P1 + 1;
        k += 1;
        
//        polygon_array[i+1][3] = P2 + 1;
        compact_array[k] = P2 + 1;
        k += 1;
        
        // next segment
        P1 += 1;
        P2 += 1;
        
    }
    
    
    
    // polygon 1
//    polygon_array[polygon_count-2][0] = polygonSize;
    compact_array[k] = polygonSize;
    k += 1;
    
    // from center of base to segment at rim
//    polygon_array[polygon_count-2][1] = O0 + 1;
    compact_array[k] = 1;
    k += 1;
    
//    polygon_array[polygon_count-2][2] = P1 + 1;
    compact_array[k] = P1 + 1;
    k += 1;
    
//    polygon_array[polygon_count-2][3] = 3;
    compact_array[k] = 3;
    k += 1;

    // polygon 2
//    polygon_array[polygon_count-1][0] = polygonSize;
    compact_array[k] = polygonSize;
    k += 1;
    
    // from peak to segment at rim
//    polygon_array[polygon_count-1][1] = O1 + 1;
    compact_array[k] = O1 + 1;
    k += 1;
    
//    polygon_array[polygon_count-1][2] = P1 + 1;
    compact_array[k] = P1 + 1;
    k += 1;
    
//    polygon_array[polygon_count-1][3] = 3;
    compact_array[k] = 3;
    k += 1;
    

    
    aCone->vertices = vertex_array;
//    aCone->polygons = polygon_array;
    aCone->polygons_compact = compact_array;
    aCone->vertnum = computedVertexCount;
    aCone->polynum = computedPolygonCount;

    return NULL;
}

void setMeshCenteredFlag(bool isCentered)
{
    centeredFlag = isCentered;
}

