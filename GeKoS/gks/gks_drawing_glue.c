//
//  gks_drawing_glue.c
//  gks-cocoa
//
//  Created by Alex Popadich on 9/6/21.
//

#include <stddef.h>
#include "gks.h"
#include "gks_drawing_glue.h"

localpolyline_cb_t gksPOLYLINE = NULL;
void *gksPOLYLINEDATA = NULL;

int localpolyline_cb_register(localpolyline_cb_t cb, void *userdata)
{
    gksPOLYLINE = cb;           // call-back drawing routine
    gksPOLYLINEDATA = userdata;
    return 1;
}

// Primitive 3D pipeline
void gks_prep_polyline_3(GKSint polygonID, GKSint num_pt, GKSvertexArrPtr vertex_array, GKSvertexArrPtr trans_array, GKSDCArrPtr dc_array, GKSnormalArrPtr norms, GKScolor *lineColor, bool hiddenSurfaceRemoveFlag)
{
    int      i;              // vertex index
    GKSpoint_3    ndc;            // normalized device coordinate
    GKSvector3d   normalized_device_coord;
    GKSpoint_3    mwc;            // world model coordinate
    GKSvector3d   world_model_coord;
    GKSpoint_3    vrc;            // view reference coordinate
    GKSvector3d   view_coord;
    GKSpoint_2     dc;            // device coordinate

    
    GKSint     r, s, r1, s1;
    
    // Get transformation matrices
    GKSmatrix_3 *view_matrix = gks_get_view_matrix();
    GKSmatrix_3 *world_matrix = gks_get_world_model_matrix();
    GKSmatrix_3 *projection_matrix = gks_get_projection_matrix();
    
    // homogeneous coordinate point
    GKSvector_3 hmvector;
    GKSvector3d homogenous_vector;
    
    GKSvector3d p1;
    GKSvector3d p2;
    GKSvector3d p3;
    GKSvector3d normal_vector;

    // transform point 0
    // TODO: transform vector_4 instead
    gks_transform_point_3(*world_matrix, &vertex_array[0].crd, &mwc);
//    gks_transform_vector(*world_matrix, vertex_array[0], &world_model_coord);
    gks_transform_point(*world_matrix, vertex_array[0], &world_model_coord);

//    gks_transform_vector_4(*world_matrix, (double *)&vertex_array[0].arr, world_model_coord);
    gks_trans_wc_to_ndc_3(&mwc,&ndc);
    gks_trans_wc_to_ndc(world_model_coord, &normalized_device_coord);
    
    gks_transform_point_3(*view_matrix, &ndc, &vrc);
    vrc.w = 1.0;
    gks_transform_point(*view_matrix, normalized_device_coord, &view_coord);
    view_coord.crd.w = 1.0;

    // store point 0
    // TODO: transformed array should be vectors
//    trans_array[0].crd = vrc;
    trans_array[0] = view_coord;
    
    // projection transformation
    gks_transform_vector_4(*projection_matrix, (GKSfloat *)&vrc, hmvector);
    gks_transform_vector_projection(*projection_matrix, view_coord, &homogenous_vector);
    
    // homogeneous coordinates to 3D normalized device coordinates
    ndc.x = hmvector[0]/hmvector[3];
    ndc.y = hmvector[1]/hmvector[3];
    ndc.z = 1.0;
    
    normalized_device_coord.crd.x = homogenous_vector.arr[0]/homogenous_vector.arr[3];
    normalized_device_coord.crd.y = homogenous_vector.arr[1]/homogenous_vector.arr[3];
    normalized_device_coord.crd.z = homogenous_vector.arr[2]/homogenous_vector.arr[3];
    normalized_device_coord.crd.z = 1.0;

    // init normal points
    p1 = normalized_device_coord;
    p2 = normalized_device_coord; //this is temp
    p3 = normalized_device_coord; //ditto

//    gks_trans_ndc_3_to_dc_2(&ndc, &r1, &s1);
    gks_trans_ndc_to_dc (normalized_device_coord,  &r1, &s1);

    dc.x = r1;
    dc.y = s1;
    dc_array[0] = dc;
    
    for (i=1;i<num_pt;i++) {
        // TODO: use vector_4 transform
        gks_transform_point_3(*world_matrix, &vertex_array[i].crd, &mwc);
//        gks_transform_vector(*world_matrix, vertex_array[i], &world_model_coord);
        gks_transform_point(*world_matrix, vertex_array[i], &world_model_coord);

        gks_trans_wc_to_ndc_3(&mwc,&ndc);
        gks_trans_wc_to_ndc(world_model_coord, &normalized_device_coord);

        gks_transform_point_3(*view_matrix, &ndc, &vrc);
        vrc.w = 1.0;
        gks_transform_point(*view_matrix, normalized_device_coord, &view_coord);
        view_coord.crd.w = 1.0;
        
        // store transformed point
        // TODO: transformed array should be vectors
//        trans_array[i].crd = vrc;
        trans_array[i] = view_coord;
        
        // projection transformation/no z info after this
        gks_transform_vector_4(*projection_matrix, (GKSfloat *)&vrc, hmvector);
        gks_transform_vector_projection(*projection_matrix, view_coord, &homogenous_vector);

        ndc.x = hmvector[0]/hmvector[3];
        ndc.y = hmvector[1]/hmvector[3];
        ndc.z = 1.0;
        
        normalized_device_coord.crd.x = homogenous_vector.arr[0]/homogenous_vector.arr[3];
        normalized_device_coord.crd.y = homogenous_vector.arr[1]/homogenous_vector.arr[3];
        normalized_device_coord.crd.z = homogenous_vector.arr[2]/homogenous_vector.arr[3];
        normalized_device_coord.crd.z = 1.0;
        
        // collect 3 different points, all the same now
        if (i==1) p2 = normalized_device_coord;
        if (i==2) p3 = normalized_device_coord;

//        gks_trans_ndc_3_to_dc_2(&ndc,&r,&s);
        gks_trans_ndc_to_dc (normalized_device_coord,  &r, &s);

        dc.x = r;
        dc.y = s;
        dc_array[i] = dc;
    }
    
    gks_plane_equation(p1, p2, p3, &normal_vector);
    
    // store the normal to the polygon
    norms[polygonID] = normal_vector;

}



void gks_localpolyline_3(GKSint polygonID, GKSint num_pt, GKSvertexArrPtr trans_array, GKSDCArrPtr dc_array, GKSnormalArrPtr norms, GKScolor *lineColor, bool hiddenSurfaceRemoveFlag)
{
    if (gksPOLYLINE != NULL) {
        gksPOLYLINE(polygonID, num_pt, trans_array, dc_array, norms, lineColor, hiddenSurfaceRemoveFlag, gksPOLYLINEDATA);
    }
    
}

