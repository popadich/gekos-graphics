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
void gks_objarr_draw_list(void);
void gks_objarr_draw_object(GKSactor *anActor);

void gks_compute_object(GKSactor *anActor);
void gks_draw_computed_object(GKSactor *anActor);

//
//int  gks_objarr_count(void);
//
//GKSactor gks_objarr_object_at_index(int index);
//

bool gks_objarr_actor_add(GKSactor actor);


void gks_objarr_delete_all(void);
void gks_objarr_delete_last(void);
//void gks_objarr_delete_at_index(int index);        // 1s based?

#endif /* gks_3d_object_list_h */
