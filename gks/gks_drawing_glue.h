//
//  gks_drawing_glue.h
//  GeKoS
//
//  Created by Alex Popadich on 3/7/22.
//

#pragma once

#include <stdio.h>
#include <stdbool.h>
#include "gks_types.h"

// callback functions type definitions
typedef void (*localpolyline_cb_t)(GKSint polygonID, GKSint num_pt, GKSDCArrPtr dc_array, GKScolor *lineColor, void *userdata);

int localpolyline_cb_register(localpolyline_cb_t cb, void *userdata);

void gks_localpolyline_3(GKSint polygonID, GKSint num_pt, GKSDCArrPtr dc_array, GKScolor *lineColor);


