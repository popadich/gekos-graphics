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


void gks_localpolyline_3(GKSint polygonID, GKSint num_pt, GKSDCArrPtr dc_array, GKScolor *lineColor)
{
    if (gksPOLYLINE != NULL) {
        gksPOLYLINE(polygonID, num_pt, dc_array, lineColor, gksPOLYLINEDATA);
    }
    
}

