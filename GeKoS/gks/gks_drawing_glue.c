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
    GKSvector3d   world_model_coord = GKSMakeVector(0.0, 0.0, 0.0);
    GKSvector3d   world_model_norm_coord = GKSMakeVector(0.0, 0.0, 0.0);
    GKSvector3d   cartesian_coord = GKSMakeVector(0.0, 0.0, 0.0);
    GKSvector3d   view_coord = GKSMakeVector(0.0, 0.0, 0.0); // view space coordinate
    GKSpoint_2    dc;             // device coordinate
    GKSfloat      r, s;           // viewport coordinates
    
    // Get transformation matrices
    GKSmatrix_3 *view_matrix = gks_get_view_matrix();
    GKSmatrix_3 *world_matrix = gks_get_world_model_matrix();
    GKSmatrix_3 *projection_matrix = gks_get_projection_matrix();

    for (i=0;i<num_pt;i++) {
        gks_transform_vector_3(*world_matrix, vertex_array[i], &world_model_coord);
        gks_trans_wc_to_nwc(world_model_coord, &world_model_norm_coord);
        gks_transform_vector_3(*view_matrix, world_model_norm_coord, &view_coord);
        
        // projection transformation, no z info is needed after this
        // homogeneous transform with conversion to cartesian point (x'=x/w,y'=y/w,z'=z/w)
        // NOTE: the order of multiplication is reversed V x M
        gks_vector_transform_projection(view_coord, *projection_matrix, &cartesian_coord);
        gks_trans_ndc_3_to_dc_2 (cartesian_coord,  &r, &s);

        dc.x = r;
        dc.y = s;
        // TODO: assert that array exists
        dc_array[i] = dc;
    }

}



void gks_localpolyline_3(GKSint polygonID, GKSint num_pt, GKSvertexArrPtr trans_array, GKSDCArrPtr dc_array, GKScolor *lineColor)
{
    if (gksPOLYLINE != NULL) {
        gksPOLYLINE(polygonID, num_pt, trans_array, dc_array, lineColor, gksPOLYLINEDATA);
    }
    
}

