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
#include "gks_drawing_glue.h"
#include "gks_mesh.h"
#include "gks_3d_matrix.h"
#include "gks_3d_world.h"

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


void gks_objarr_update_object(GKSint index, GKSobjectKind kind, GKSvector3d translate, GKSvector3d rotate, GKSvector3d scale)
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



void pipeline_actor(GKSactor *the_actor)
{
    GKSvector3d polygon_vertex_buffer[GKS_POLY_VERTEX_MAX];
    GKSpoint_2 dev_coord_buffer[GKS_POLY_VERTEX_MAX];
    
    GKSint polygon_count = the_actor->mesh_object.polynum;
    GKSvertexArrPtr vertex_array = the_actor->mesh_object.vertices;
    GKSpolyArrPtr poly_array = the_actor->mesh_object.polygons_compact;
    GKSDCArrPtr dev_coord_array = the_actor->devcoords;
    
    // TODO: transform all object vertices first
    // to speed things up I should transform all the vertices of the object
    // to viewport space coordinates, and then do tests on polygons.
    
    GKSint k = 0;
    for(GKSint pid=0; pid<polygon_count; pid++) {
        
        // copy polygon points over to a temporary array as a guard against modifying
        // the original data.
        GKSint polygon_size = poly_array[k];
        k += 1;
        
        for(GKSint j=0; j<polygon_size; j++){
            GKSint vertex_idx = poly_array[ k + j ] - 1;            // this is a gotcha
            polygon_vertex_buffer[j] = vertex_array[vertex_idx];    // point number to
                                                                    // array index
        }

        // do transforms on temporary device polygons
        gks_prep_polyline_3(pid, polygon_size, polygon_vertex_buffer, dev_coord_buffer, &the_actor->line_color);
        
        // copy transformed points back to actor array
        for(GKSint j=0; j<polygon_size; j++){
            GKSint vertex_idx = poly_array[ k + j ] - 1;
            dev_coord_array[vertex_idx] = dev_coord_buffer[j];    // actor
        }

        k += polygon_size;
    }
}


void gks_draw_piped_actor(GKSactor *the_actor)
{
    GKSpoint_2          dev_coord_buffer[GKS_POLY_VERTEX_MAX];

    GKSint poly_count           = the_actor->mesh_object.polynum;
    GKSpolyArrPtr polygon_array = the_actor->mesh_object.polygons_compact;
    GKSDCArrPtr dev_coord_array = the_actor->devcoords;
    
    GKSint k = 0;
    for (GKSint i=0; i < poly_count; i++) {
        GKSint polygon_size = polygon_array[k];
        k += 1;     // vertex count part
        for(GKSint j=0; j<polygon_size; j++){
            
            // TODO: check addObjectRepToScene
            // vertex numbers in MESH file start at 1.
            // the ( - 1) turns a point number
            // which normally start at 1 into a
            // zero based array index.
            GKSint vertex_idx = polygon_array[k] - 1;
            dev_coord_buffer[j] = dev_coord_array[vertex_idx];

            k += 1;
        }
        
        // call-back to drawing routine
        gks_localpolyline_3(i, polygon_size, dev_coord_buffer, &the_actor->line_color);
        
    }
}


// TODO: pipeline objects
void gks_pipeline_object_actor(GKSactor *the_actor)
{
    // TODO: set all pipeline matrices
    
    // set object into the world
    gks_set_world_model_matrix(the_actor->model_transform);
    
    pipeline_actor(the_actor);
    
}


void gks_objarr_draw_list(void)
{
    for (int i=0; i<_object_count; i++) {
        GKSactor *actor_ptr = &object_array[i];
        gks_pipeline_object_actor(actor_ptr);
        gks_draw_piped_actor(actor_ptr);
    }
}
