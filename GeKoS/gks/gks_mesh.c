//
//  gks_mesh.c
//  GeKoS
//
//  Created by Alex Popadich on 12/5/21.
//
// Borrowed spec from wikipedia
// https://en.wikipedia.org/wiki/OFF_(file_format)
//
// This seems to be the definite specification for OFF files
// http://www.geomview.org/docs/html/OFF.html
//

#include <stdlib.h>
#include <math.h>
#include "gks_mesh.h"
#include "gks_3d_matrix.h"

static bool centeredFlag = false;


GKSmesh_3 *MeshOfKind(GKSkind kind)
{
    GKSmesh_3 *theMesh = NULL;
    switch (kind) {
        case kConeKind:
            theMesh = ConeMesh();
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
    static GKSpoint_3 object_verts[GKS_CUBE_VERTEX_COUNT] = {
        {0.0, 0.0, 0.0},
        {1.0, 0.0, 0.0},
        {1.0, 1.0, 0.0},
        {0.0, 1.0, 0.0},
        {0.0, 0.0, 1.0},
        {1.0, 0.0, 1.0},
        {1.0, 1.0, 1.0},
        {0.0, 1.0, 1.0}
    };
    static GKSpolygon_3 object_polys[GKS_CUBE_POLYGON_COUNT] = {
        {4,4,3,2,1},
        {4,5,6,7,8},
        {4,1,5,8,4},
        {4,2,3,7,6},
        {4,1,2,6,5},
        {4,3,4,8,7}
    };
    
    // connected vertices
    static GKSedge_3 object_edges[GKS_CUBE_EDGE_COUNT] = {
        1,2,
        2,3,
        3,4,
        4,1,
        5,6,
        6,7,
        7,8,
        8,5,
        1,5,
        2,6,
        3,7,
        4,8
    };

    GKSpoint_3 *p;
    GKSvector3dPtr q;
    GKSmesh_3 *aCube;

    // clear memory allocation to zeros
    GKSvertexArrPtr vertex_array = (GKSvertexArrPtr)calloc(GKS_CUBE_VERTEX_COUNT, sizeof(GKSvector3d));
    GKSindexArrPtr polygon_array = (GKSindexArrPtr)calloc(GKS_CUBE_PARRAY_SIZE, sizeof(GKSint));
    GKSedgeArrPtr edge_array = (GKSedgeArrPtr)calloc(GKS_CUBE_EDGE_COUNT, sizeof(GKSedge_3));

    // copy vertices using pointer arithmetic
    p = object_verts;
    q = vertex_array;
    for(GKSint i=0; i<GKS_CUBE_VERTEX_COUNT; i++) {
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
    GKSint k = 0;
    for(GKSint i=0; i<GKS_CUBE_POLYGON_COUNT; i++) {
        GKSint polygon_size = object_polys[i][0] + 1;     // +1 includes the polygon vertex
                                                       // count value as part of the size
        for(int j=0; j<polygon_size; j++) {
            polygon_array[k] = object_polys[i][j];
            k += 1;
        }
    }
    
    // copy edges
    for (GKSint i=0; i<GKS_CUBE_EDGE_COUNT; i++) {
        GKSint p1 = object_edges[i][0];
        GKSint p2 = object_edges[i][1];

        edge_array[i][0] = p1;
        edge_array[i][1] = p2;
    }

    aCube = (GKSmesh_3 *)calloc(1, sizeof(GKSmesh_3));
    aCube->vertices = vertex_array;
    aCube->polygons = polygon_array;
    aCube->edges = edge_array;
    aCube->vertnum = GKS_CUBE_VERTEX_COUNT;
    aCube->polynum = GKS_CUBE_POLYGON_COUNT;
    aCube->edgenum = GKS_CUBE_EDGE_COUNT;
    aCube->polystoresize = GKS_CUBE_PARRAY_SIZE;
    
    return aCube;
}


GKSmesh_3 *PyramidMesh(void)
{
    // Put some code here to configure a Pyramid.
    static GKSpoint_3 object_verts[GKS_PYRAMID_VERTEX_COUNT] = {
        {0.0, 0.0, 0.0},
        {1.0, 0.0, 0.0},
        {1.0, 0.0, 1.0},
        {0.0, 0.0, 1.0},
        {0.5, 0.6636661, 0.5}
    };
    static GKSpolygon_3 object_polys[GKS_PYRAMID_POLYGON_COUNT] = {
        {4,1,2,3,4},
        {3,1,5,2},
        {3,2,5,3},
        {3,3,5,4},
        {3,4,5,1}
    };
    static GKSedge_3 object_edges[GKS_PYRAMID_EDGE_COUNT] = {
        1,2,
        2,3,
        3,4,
        4,1,
        1,5,
        2,5,
        3,5,
        4,5
    };
    GKSpoint_3 *p;
    GKSvector3dPtr q;
    GKSmesh_3 *aPyramid = NULL;
    
    // clear memory allocation to zeros
    GKSvertexArrPtr vertex_array = (GKSvertexArrPtr)calloc(GKS_PYRAMID_VERTEX_COUNT, sizeof(GKSvector3d));
    GKSindexArrPtr polygon_array = (GKSindexArrPtr)calloc(GKS_PYRAMID_PARRAY_SIZE, sizeof(GKSint));
    GKSedgeArrPtr edge_array = (GKSedgeArrPtr)calloc(GKS_PYRAMID_EDGE_COUNT, sizeof(GKSedge_3));

    // copy vertices using pointer arithmetic
    p = object_verts;
    q = vertex_array;
    for(GKSint i=0; i<GKS_PYRAMID_VERTEX_COUNT; i++) {
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
    GKSint k = 0;
    for(GKSint i=0; i<GKS_PYRAMID_POLYGON_COUNT; i++) {
        GKSint polygon_size = object_polys[i][0] + 1;
        for(GKSint j=0; j < polygon_size; j++) {
            polygon_array[k] = object_polys[i][j];
            k += 1;
        }
    }
    
    // copy edges
    for (GKSint i=0; i<GKS_PYRAMID_EDGE_COUNT; i++) {
        GKSint p1 = object_edges[i][0];
        GKSint p2 = object_edges[i][1];

        edge_array[i][0] = p1;
        edge_array[i][1] = p2;
    }

    aPyramid = (GKSmesh_3 *)calloc(1, sizeof(GKSmesh_3));
    aPyramid->vertices = vertex_array;
    aPyramid->polygons = polygon_array;
    aPyramid->edges = edge_array;
    aPyramid->vertnum = GKS_PYRAMID_VERTEX_COUNT;
    aPyramid->polynum = GKS_PYRAMID_POLYGON_COUNT;
    aPyramid->edgenum = GKS_PYRAMID_EDGE_COUNT;
    aPyramid->polystoresize = GKS_PYRAMID_PARRAY_SIZE;

    return aPyramid;
}

GKSmesh_3 *HouseMesh(void)
{
    static GKSpoint_3 object_verts[GKS_HOUSE_VERTEX_COUNT] = {
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
    static GKSpolygon_3 object_polys[GKS_HOUSE_POLYGON_COUNT] = {
        {5, 5, 4, 3, 2, 1},
        {5, 6, 7, 8, 9, 10},
        {4, 1, 2, 7, 6},
        {4, 2, 3, 8, 7},
        {4, 1, 6, 10, 5},
        {4, 3, 4, 9, 8},
        {4, 4, 5, 10, 9}
    };
 
    static GKSedge_3 object_edges[GKS_HOUSE_EDGE_COUNT] = {
        1,2,
        2,3,
        3,4,
        4,1,
        4,10,
        1,5,
        10,5,
        5,6,
        10,9,
        6,9,
        7,8,
        6,7,
        9,8,
        3,8,
        2,7
    };
    
    GKSpoint_3 *p;
    GKSvector3dPtr q;
    GKSmesh_3 *aHouse = NULL;

    // clear memory allocation to zeros
    GKSvertexArrPtr vertex_array = (GKSvertexArrPtr)calloc(GKS_HOUSE_VERTEX_COUNT, sizeof(GKSvector3d));
    GKSint *polygon_array = (GKSindexArrPtr)calloc(GKS_HOUSE_PARRAY_SIZE, sizeof(GKSint));
    GKSedgeArrPtr edge_array = (GKSedgeArrPtr)calloc(GKS_HOUSE_EDGE_COUNT, sizeof(GKSedge_3));

    // copy vertices using pointer arithmetic
    p = object_verts;
    q = vertex_array;
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
        int polygon_size = object_polys[i][0] + 1;
        for(int j=0; j<polygon_size; j++) {
            polygon_array[k] = object_polys[i][j];
            k += 1;
        }
    }

    // copy edges
    for (GKSint i=0; i<GKS_HOUSE_EDGE_COUNT; i++) {
        GKSint p1 = object_edges[i][0];
        GKSint p2 = object_edges[i][1];

        edge_array[i][0] = p1;
        edge_array[i][1] = p2;
    }

    aHouse = (GKSmesh_3 *)calloc(1, sizeof(GKSmesh_3));
    aHouse->vertices = vertex_array;
    aHouse->polygons = polygon_array;
    aHouse->edges = edge_array;
    aHouse->vertnum = GKS_HOUSE_VERTEX_COUNT;
    aHouse->polynum = GKS_HOUSE_POLYGON_COUNT;
    aHouse->edgenum = GKS_HOUSE_EDGE_COUNT;
    aHouse->polystoresize = GKS_HOUSE_PARRAY_SIZE;

    return aHouse;
}

GKSmesh_3 *SphereMesh(void)
{
    GKSint             vertex_count = 0;
    GKSint             polygon_count = 0;

    // degreeDelta and facetCount
    // parameters describing sphere sampling size this controls
    // the number of total vertices and polygons. It goes without
    // saying that the 'degreeDelta' value needs to be a even
    // denominator of 360.
    GKSint delta = 10;               // set as parameter
    GKSint facets = 360/delta;       // number of longitute lines, like orange slices
    GKSint calc_vertex_count = (180/delta + 1) * (360/delta);
    GKSint calc_polygon_count = calc_vertex_count - facets;
    GKSint calc_compact_count = calc_polygon_count * 5;

    // allocate sub arrays and then the mesh structure to hold them
    // use calloc to clear allocatted memory to zeros
    GKSvertexArrPtr vertex_array = (GKSvertexArrPtr)calloc(calc_vertex_count, sizeof(GKSvector3d));
    GKSindexArrPtr polygon_array = (GKSindexArrPtr)calloc(calc_compact_count, sizeof(GKSint));
    GKSmesh_3 *aSphere = (GKSmesh_3 *)calloc(1, sizeof(GKSmesh_3));
    
    // construct vertices
   for (GKSint i=0; i<=180; i+=delta) {
        for (GKSint j=0; j<360; j+=delta) {
            double sine_of_i = sin(i*DEG_TO_RAD);
            GKSint idx = (j+(i*facets))/delta;
            vertex_array[idx].crd.x = 0.5 * sine_of_i * cos(j*DEG_TO_RAD);
            vertex_array[idx].crd.y = 0.5 * sine_of_i * sin(j*DEG_TO_RAD);
            vertex_array[idx].crd.z = 0.5 * cos(i*DEG_TO_RAD);
            vertex_array[idx].crd.w = 1.0;
            vertex_count += 1;
        }
    }
    
    // construct polygons
    GKSint k = 0;
    for (GKSint i=0; i<calc_polygon_count; i+=facets) {
        for (GKSint j=0; j<facets; j++) {
            polygon_array[k] = 4;     // poly size
            
            k += 1;
            GKSint point1 = j+i+1;
            polygon_array[k] = point1;
            
            k += 1;
            GKSint point2 = ((j+1) % facets) + i + 1;
            polygon_array[k] = point2;
            
            k += 1;
            polygon_array[k] = point2 + facets;
            
            k += 1;
            polygon_array[k] = point1 + facets;
            
            k += 1;
            polygon_count += 1;
            
        }
    }
    
//    printf("polygons: %d   %d\n", k, calc_compact_count);

    
    if (calc_polygon_count != polygon_count) {
        // Should throw something, because this should never happen
        // printf("Something is wrong !!\n");
        return NULL;
    }
    
    if (calc_vertex_count != vertex_count) {
        // throw something here, because this should never happen
        // NSLog(@"ERROR: vertex counts do not match.");
        return NULL;
    }
    
    aSphere->vertices = vertex_array;
    aSphere->vertnum = vertex_count;
    aSphere->polygons = polygon_array;
    aSphere->polynum = polygon_count;
    aSphere->edgenum = 1296;    //TODO: compute this
    aSphere->polystoresize = calc_compact_count;

    return aSphere;
}

GKSmesh_3 *ConeMesh(void)
{
    GKSint vertex_count = 0;
    
    // degreeDelta describes a circle sampling at the base of a cone
    // fron that we compute the number of total vertices and polygons.
    // It goes without saying that the 'degreeDelta' value needs to be a even
    // denominator of 360.
    GKSint delta = 10;               // should be a parameter
    GKSint facets = 360/delta;
    GKSint calc_vertex_count = facets + 1 + 1;
    GKSint calc_polygon_count = facets * 2;
    GKSint calc_compact_count = calc_polygon_count * 4;  // each polygon size 4
    
    // allocate sub arrays and then the container structure object
    // use calloc to clear allocatted memory to zeros
    GKSvertexArrPtr vertex_array = (GKSvertexArrPtr)calloc(calc_vertex_count, sizeof(GKSvector3d));
    
    // TODO: compute size of buffer
    GKSindexArrPtr polygon_array = (GKSindexArrPtr)calloc(calc_compact_count, sizeof(GKSint));
    GKSmesh_3 *aCone = (GKSmesh_3 *)calloc(1, sizeof(GKSmesh_3));
    
    
    //TODO: centering?
    // construct vertices
    GKSint idx = vertex_count;
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
    for (int j=0; j<360; j+=delta) {
        idx = vertex_count;
        vertex_array[idx].crd.x = 0.5 * cos(j*DEG_TO_RAD);
        vertex_array[idx].crd.y = 0.0;
        vertex_array[idx].crd.z = 0.5 * sin(j*DEG_TO_RAD);
        vertex_array[idx].crd.w = 1.0;
        vertex_count += 1;
    }

    // construct polygons
    GKSint O0 = 0;
    GKSint O1 = 1;
    GKSint P1 = 2;
    GKSint P2 = 3;
    GKSint polygon_size = 3;
    GKSint polygon_count = (vertex_count - 2) * 2;
    
    GKSint k = 0;
    for(GKSint i=0; i < polygon_count - 2; i+=2) {
        
        // polygon 1
        polygon_array[k] = polygon_size;
        k += 1;
        // from center of base to segment at rim
        polygon_array[k] = O0 + 1;
        k += 1;
        polygon_array[k] = P1 + 1;
        k += 1;
        polygon_array[k] = P2 + 1;
        k += 1;
        
        // polygon 2
        polygon_array[k] = polygon_size;
        k += 1;
        // from peak to segment at rim
        polygon_array[k] = O1 + 1;
        k += 1;
        polygon_array[k] = P1 + 1;
        k += 1;
        polygon_array[k] = P2 + 1;
        k += 1;
        
        // next segment
        P1 += 1;
        P2 += 1;
        
    }
    
    // polygon 1
    polygon_array[k] = polygon_size;
    k += 1;
    // from center of base to segment at rim
    polygon_array[k] = 1;
    k += 1;
    polygon_array[k] = P1 + 1;
    k += 1;
    polygon_array[k] = 3;
    k += 1;

    // polygon 2
    polygon_array[k] = polygon_size;
    k += 1;
    // from peak to segment at rim
    polygon_array[k] = O1 + 1;
    k += 1;
    polygon_array[k] = P1 + 1;
    k += 1;
    polygon_array[k] = 3;
    k += 1;
    
    
    aCone->vertices = vertex_array;
    aCone->polygons = polygon_array;
    aCone->vertnum = calc_vertex_count;
    aCone->polynum = calc_polygon_count;
    aCone->edgenum = 108;
    aCone->polystoresize = calc_compact_count;

    return aCone;
}

void setMeshCenteredFlag(bool isCentered)
{
    centeredFlag = isCentered;
}

void free_mesh(GKSmesh_3 *the_mesh)
{
    // Free the memory associated with mesh data structure
    free(the_mesh->vertices);
    the_mesh->vertices = NULL;
    free(the_mesh->polygons);
    the_mesh->polygons = NULL;
    free(the_mesh->edges);
    the_mesh->edges = NULL;
    
    free(the_mesh);
}
