//
//  gks_drawing_glue.h
//  GeKoS
//
//  Created by Alex Popadich on 3/7/22.
//

#ifndef gks_drawing_glue_h
#define gks_drawing_glue_h

#include <stdio.h>
#include <stdbool.h>
#include "gks_types.h"

// callback functions type definitions
typedef void (*localpolyline_cb_t)(GKSint polygonID, GKSint num_pt, GKSDCArrPtr dc_array, GKScolor *lineColor, void *userdata);

int localpolyline_cb_register(localpolyline_cb_t cb, void *userdata);

void gks_prep_polyline_3(GKSint polygonID, GKSint num_pt, GKSvertexArrPtr vertex_array, GKSDCArrPtr dc_array, GKScolor *lineColor);

void gks_localpolyline_3(GKSint polygonID, GKSint num_pt, GKSDCArrPtr dc_array, GKScolor *lineColor);


#endif /* gks_drawing_glue_h */
