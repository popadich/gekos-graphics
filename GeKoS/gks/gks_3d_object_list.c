//
//  gks_3d_object_list.c
//  GeKoS
//
//  Created by Alex Popadich on 3/7/22.

/*
 This c module would make a good candidate for making into an object.

    The object should maintain a scene list and have a way of specifying
 which scene in the list should be displayed.
 
 Good Color Values for Hidden Surface Removal:
   [[NSColor colorWithRed:0.800 green:0.800 blue:0.600 alpha:1.0] setStroke];
   [[NSColor colorWithRed:1.000 green:1.000 blue:0.800 alpha:1.0] setFill];

*/

#include <stdlib.h>
#include <math.h>
#include <float.h>

#include "gks_3d_object_list.h"
#include "gks_3d_matrix.h"
#include "gks_3d_pipeline.h"

#define GKS_MAX_SCENE_ACTORS    1024

static int          _object_count;                          // count of objects 3D
static GKSactor     object_array[GKS_MAX_SCENE_ACTORS];    // world Scene max objects

void gks_init_object_list(void)
{
    _object_count = 0;
}

int gks_objarr_count(void)
{
    return _object_count;
}

// TODO: return a pointer instead
GKSactor gks_objarr_object_at_index(int index)
{
    GKSactor object3d = object_array[index];
    return object3d;
}


bool gks_objarr_actor_add(GKSactor actor)
{
    bool did_add = false;
    
    // TODO: all calculations should be performed prior to add
    if (_object_count < GKS_MAX_SCENE_ACTORS) {

        object_array[_object_count].kind = actor.kind;
        object_array[_object_count].fill_color = actor.fill_color;
        object_array[_object_count].line_color = actor.line_color;
        object_array[_object_count].scale_vector = actor.scale_vector;
        object_array[_object_count].rotate_vector = actor.rotate_vector;
        object_array[_object_count].translate_vector = actor.translate_vector;
        
        // FIXME: use pointers
        // This copies the object
        object_array[_object_count].mesh_object = actor.mesh_object;
        object_array[_object_count].devcoords = actor.devcoords;
        
        // TODO: verify
        gks_matrix_copy_3(actor.model_transform, object_array[_object_count].model_transform);
        
        _object_count += 1;
        did_add = true;
    }

    return did_add;
}


void gks_objarr_update_object(GKSint index, GKSkind kind, GKSvector3d translate, GKSvector3d rotate, GKSvector3d scale)
{
    GKSfloat rx, ry, rz;
    rx = rotate.crd.x;
    ry = rotate.crd.y;
    rz = rotate.crd.z;
    GKSfloat sx, sy, sz;
    sx = scale.crd.x;
    sy = scale.crd.y;
    sz = scale.crd.z;
    GKSfloat tx, ty, tz;
    tx = translate.crd.x;
    ty = translate.crd.y;
    tz = translate.crd.z;
    
    if (index >=0 && index<_object_count) {
        if (object_array[index].kind == kind) {
            gks_create_scaling_matrix_3(sx,sy,sz, object_array[index].model_transform);
            gks_accumulate_x_rotation_matrix_3(rx, object_array[index].model_transform);
            gks_accumulate_y_rotation_matrix_3(ry, object_array[index].model_transform);
            gks_accumulate_z_rotation_matrix_3(rz, object_array[index].model_transform);
            gks_accumulate_translation_matrix_3(tx,ty,tz, object_array[index].model_transform);
            object_array[index].scale_vector = scale;
            object_array[index].translate_vector = translate;
            object_array[index].rotate_vector = rotate;
        }
    }

}



void gks_objarr_draw_list(void)
{
}
