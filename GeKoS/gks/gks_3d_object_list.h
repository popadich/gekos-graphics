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
void gks_objarr_draw_object(Actor anActor);

//void gks_objarr_set_hidden_surface_removal(bool isHiddenSurfaceFlag);
//bool gks_objarr_get_hidden_surface_removal(void);
//
//int  gks_objarr_count(void);
//
//Actor gks_objarr_object_at_index(int index);
//
void gks_objarr_add(ObjectKind kind, GKSobject_3 *object, GKSpoint_3 transVec, GKSpoint_3 scaleVec, GKSpoint_3 rotVec, GKScolor lineColor);
//void gks_objarr_update_object(int index, int kind, Gfloat tx, Gfloat ty, Gfloat tz, Gfloat sx, Gfloat sy, Gfloat sz, Gfloat rx, Gfloat ry, Gfloat rz);
//
//void gks_objarr_delete_last(void);
//void gks_objarr_delete_at_index(int index);        // 1s based?
//void gks_objarr_delete_all(void);

#endif /* gks_3d_object_list_h */
