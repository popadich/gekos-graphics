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
    gksPOLYLINE = cb;
    gksPOLYLINEDATA = userdata;
    return 1;
}

// Primitive 3D pipeline
void gks_preppolyline_3(GKSint polygonID, GKSint num_pt, GKSvertexArrPtr vertex_array, GKSvertexArrPtr trans_array, GKSDCArrPtr dc_array, GKSnormalArrPtr norms, GKScolor *lineColor, bool hiddenSurfaceRemoveFlag)
{
    int      i;              // vertex index
    GKSpoint_3    ndc;            // normalized device coordinate
    GKSpoint_3    mwc;            // world model coordinate
    GKSpoint_3    vrc;            // view reference coordinate
    GKSpoint_2     dc;            // device coordinate

    
    GKSint     r, s, r1, s1;
    GKSmatrix_3 *view_matrix = gks_get_view_matrix();
    GKSmatrix_3 *world_matrix = gks_get_world_model_matrix();
    GKSmatrix_3 *projection_matrix = gks_get_projection_matrix();
    
    GKSvector_3 hmvector;
    GKSpoint_3 p1;
    GKSpoint_3 p2;
    GKSpoint_3 p3;
    GKSpoint_3 normal_vector;

    // transform point 0
    gks_transform_point_3(*world_matrix, &vertex_array[0], &mwc);
    gks_trans_wc_to_ndc_3(&mwc,&ndc);
    
    gks_transform_point_3(*view_matrix, &ndc, &vrc);
    vrc.w = 1.0;

    // store point 0
    trans_array[0] = vrc;
    
    // projection transformation
    gks_transform_vector_4(*projection_matrix, (GKSfloat *)&vrc, hmvector);
    
    // homogeneous coordinates to 3D normalized view coordinates
    ndc.x = hmvector[0]/hmvector[3];
    ndc.y = hmvector[1]/hmvector[3];
    ndc.z = 1.0;
    
    // init normal points
    p1 = ndc;
    p2 = ndc; //this is temp
    p3 = ndc; //ditto

    gks_trans_ndc_3_to_dc_2(&ndc, &r1, &s1);
    
    dc.x = r1;
    dc.y = s1;
    dc_array[0] = dc;
    
    for (i=1;i<num_pt;i++) {
        gks_transform_point_3(*world_matrix, &vertex_array[i], &mwc);
        gks_trans_wc_to_ndc_3(&mwc,&ndc);
        
        gks_transform_point_3(*view_matrix, &ndc, &vrc);
        vrc.w = 1.0;

        // store transformed point
        trans_array[i] = vrc;
        
        // projection transformation/no z info after this
        gks_transform_vector_4(*projection_matrix, (GKSfloat *)&vrc, hmvector);
       
        ndc.x = hmvector[0]/hmvector[3];
        ndc.y = hmvector[1]/hmvector[3];
        ndc.z = 1.0;
        
        // collect 3 different points, all the same now
        if (i==1) p2 = ndc;
        if (i==2) p3 = ndc;

        gks_trans_ndc_3_to_dc_2(&ndc,&r,&s);
        
        dc.x = r;
        dc.y = s;
        dc_array[i] = dc;
    }
    
    // this would be smarter at mesh instantiation
    // and then just transform normal vectors with the rest of
    // the vertices.
    p1.w = p2.w = p3.w = 1.0; // not sure is necessary or correct
    gks_plane_equation_3(p1, p2, p3, &normal_vector);
    
    // store the normal to the polygon
    norms[polygonID] = normal_vector;

}



void gks_localpolyline_3(GKSint polygonID, GKSint num_pt, GKSvertexArrPtr trans_array, GKSDCArrPtr dc_array, GKSnormalArrPtr norms, GKScolor *lineColor, bool hiddenSurfaceRemoveFlag)
{
    if (gksPOLYLINE != NULL) {
        gksPOLYLINE(polygonID, num_pt, trans_array, dc_array, norms, lineColor, hiddenSurfaceRemoveFlag, gksPOLYLINEDATA);
    }
    
}

