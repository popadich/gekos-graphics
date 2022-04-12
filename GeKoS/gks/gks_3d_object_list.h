//
//  gks_3d_object_list.h
//  GeKoS
//
//  Created by Alex Popadich on 3/7/22.
//


#ifndef gks_3d_object_list_h
#define gks_3d_object_list_h

#include <stdbool.h>
#include "gks_types.h"
#include "gks_mesh.h"

void gks_init_object_list(void);
int  gks_objarr_count(void);

void gks_objarr_draw_object(GKSactor *anActor);

void gks_pipeline_object_actor(GKSactor *anActor);
void gks_draw_piped_actor(GKSactor *anActor);

bool gks_objarr_actor_add(GKSactor actor);

#endif /* gks_3d_object_list_h */
