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
void gks_prep_polyline_3(GKSint polygonID, GKSint num_pt, GKSvertexArrPtr vertex_array, GKSvertexArrPtr trans_array, GKSDCArrPtr dc_array, GKScolor *lineColor)
{
    GKSint        i;              // vertex index
    GKSvector3d   normalized_device_coord;
    GKSvector3d   world_model_coord;
    GKSvector3d   view_coord;     // view reference coordinate
    GKSpoint_2    dc;             // device coordinate

    
    GKSint     r, s;
    
    // Get transformation matrices
    GKSmatrix_3 *view_matrix = gks_get_view_matrix();
    GKSmatrix_3 *world_matrix = gks_get_world_model_matrix();
    GKSmatrix_3 *projection_matrix = gks_get_projection_matrix();
    
    // homogeneous coordinate point
    GKSvector3d homogenous_vector;


    // transform point 0
    // TODO: transform vector_4 instead
    gks_transform_point(*world_matrix, vertex_array[0], &world_model_coord);

    gks_trans_wc_to_ndc(world_model_coord, &normalized_device_coord);
    
    gks_transform_point(*view_matrix, normalized_device_coord, &view_coord);
    view_coord.crd.w = 1.0;

    // store point 0
    trans_array[0] = view_coord;
    
    // projection transformation
    gks_transform_vector_projection(*projection_matrix, view_coord, &homogenous_vector);
    
    // homogeneous coordinates to 3D normalized device coordinates
    normalized_device_coord.crd.x = homogenous_vector.arr[0]/homogenous_vector.arr[3];
    normalized_device_coord.crd.y = homogenous_vector.arr[1]/homogenous_vector.arr[3];
    normalized_device_coord.crd.z = homogenous_vector.arr[2]/homogenous_vector.arr[3];
    normalized_device_coord.crd.z = 1.0;

    // init normal points
//    p1 = normalized_device_coord;
//    p2 = normalized_device_coord; //this is temp
//    p3 = normalized_device_coord; //ditto

    gks_trans_ndc_to_dc (normalized_device_coord,  &r, &s);

    dc.x = r;
    dc.y = s;
    dc_array[0] = dc;
    
    for (i=1;i<num_pt;i++) {
        // TODO: use vector_4 transform
        gks_transform_point(*world_matrix, vertex_array[i], &world_model_coord);

        gks_trans_wc_to_ndc(world_model_coord, &normalized_device_coord);

        gks_transform_point(*view_matrix, normalized_device_coord, &view_coord);
        view_coord.crd.w = 1.0;
        
        // store transformed point
        trans_array[i] = view_coord;
        
        // projection transformation/no z info after this
        gks_transform_vector_projection(*projection_matrix, view_coord, &homogenous_vector);

        
        normalized_device_coord.crd.x = homogenous_vector.arr[0]/homogenous_vector.arr[3];
        normalized_device_coord.crd.y = homogenous_vector.arr[1]/homogenous_vector.arr[3];
        normalized_device_coord.crd.z = homogenous_vector.arr[2]/homogenous_vector.arr[3];
        normalized_device_coord.crd.z = 1.0;
        


        gks_trans_ndc_to_dc (normalized_device_coord,  &r, &s);

        dc.x = r;
        dc.y = s;
        dc_array[i] = dc;
    }

}



void gks_localpolyline_3(GKSint polygonID, GKSint num_pt, GKSvertexArrPtr trans_array, GKSDCArrPtr dc_array, GKScolor *lineColor)
{
    if (gksPOLYLINE != NULL) {
        gksPOLYLINE(polygonID, num_pt, trans_array, dc_array, lineColor, gksPOLYLINEDATA);
    }
    
}

