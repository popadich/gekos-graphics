//
//  gks_3d_context.c
//  GeKoS
//
//  Created by Alex Popadich on 12/8/21.
//

/*
 Device independent coordinate transformations
 
 The device independence is brought to you by having a set of transforms which can
 be used to translate from normalized device coordinates, device coordinates and
 world coordinates.
 
 - World Coordinates: (WC) used by the application programmer to describe graphical information to GKS.
 - Normalized Device Coordinates: (NDC) used to define a uniform coordinate system for all workstations.
 - Device Coordinates: (DC), one coordinate system per workstation, representing its display surface coordinates. Input containing coordinates are expressed to GKS by the device using DC values.
 
 */

#include <stdlib.h>
#include "gks_3d_context.h"
#include "gks_3d_normalization.h"
#include "gks_3d_view_orient.h"
#include "gks_3d_matrix.h"
#include "gks_3d_projection.h"


const GKSint kWorldVolumeSetup = 0;
const GKSint kViewVolumeSetup = 1;

const GKSint kViewMatrixSetup = 0;
const GKSint kProjectionMatrixSetup = 1;

//  P R O T O T Y P E S
void store_context(GKSint vantage_point);

// S T A T I C   G L O B A L S
static GKScontext3DPtr   g_curr_context;


//
// Initialize world, viewport, and device transformations
//
GKScontext3DPtr gks_context_init(void)
{
    GKScontext3DPtr theContext;
    theContext = (GKScontext3D *)calloc(1, sizeof(GKScontext3D));
    g_curr_context = theContext;
    return theContext;
}





