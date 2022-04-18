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



//
// Initialize world, viewport, and device transformations
//
GKScontext3DPtr gks_context_init(void)
{
    GKScontext3DPtr theContext;
    theContext = (GKScontext3D *)calloc(1, sizeof(GKScontext3D));
    return theContext;
}





