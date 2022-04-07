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
void gks_prep_polyline_3(GKSint polygonID, GKSint num_pt, GKSvertexArrPtr vertex_array, GKSDCArrPtr dc_array, GKScolor *lineColor)
{
    GKSint        i;
    GKSvector3d   world_model_coord = GKSMakeVector(0.0, 0.0, 0.0);
    GKSvector3d   world_model_norm_coord = GKSMakeVector(0.0, 0.0, 0.0);
    GKSvector3d   cartesian_coord = GKSMakeVector(0.0, 0.0, 0.0);
    GKSvector3d   camera_coord = GKSMakeVector(0.0, 0.0, 0.0);
    GKSvector3d   view_coord = GKSMakeVector(0.0, 0.0, 0.0);
    GKSpoint_2    dc;  // device coordinate
    
    // Get transformation matrices
    GKSmatrix_3 *world_matrix = gks_get_world_model_matrix();
    GKSmatrix_3 *view_matrix = gks_view_matrix_get();
    GKSmatrix_3 *projection_matrix = gks_projection_get_matrix();

    for (i=0; i<num_pt; i++) {
        gks_transform_vector_3(*world_matrix, vertex_array[i], &world_model_coord);
        
        gks_trans_wc_to_nwc(world_model_coord, &world_model_norm_coord);

        gks_transform_vector_3(*view_matrix, world_model_norm_coord, &view_coord);
        
        // projection transformation, no z coordinate is needed after this
        // homogeneous transform with conversion to cartesian point
        //
        //  (x'=x/w,y'=y/w,z'=z/w)
        //
        // NOTE: the order of multiplication is Vector x Matrix
        // FIXME: the order is wrong
        // Order might be affected by how the matrix is initialized row first or column first
        gks_vector_transform_3(view_coord, *projection_matrix, &camera_coord);
        
        // *** DO CLIPPING HERE ***
        // ON CAMERA COORDINATE BEFORE HOMOGENEOUS PROJECTION SCALING
        // clipping on the view volume which is now shaped like a cube
        
        // Delayed projection scaling/normalization
        cartesian_coord = GKSMakeVector(camera_coord.crd.x/camera_coord.crd.w, camera_coord.crd.y/camera_coord.crd.w, camera_coord.crd.z/camera_coord.crd.w);
        
        // convert to device port coordinates
        gks_trans_nwc_3_to_dc_2 (cartesian_coord,  &dc.x, &dc.y);

        dc_array[i] = dc;
    }

}



void gks_localpolyline_3(GKSint polygonID, GKSint num_pt, GKSDCArrPtr dc_array, GKScolor *lineColor)
{
    if (gksPOLYLINE != NULL) {
        gksPOLYLINE(polygonID, num_pt, dc_array, lineColor, gksPOLYLINEDATA);
    }
    
}

