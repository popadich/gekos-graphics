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

#define GKS_MAX_SCENE_ACTORS    32

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



// be careful, this seems to be 1s based indexing. Not sure this has ever been tested.
void gks_objarr_delete_at_index(int index)
{
    int i;
    
    int idx = index - 1;
    if (idx > 0 && idx < _object_count) {
  
        GKSmesh_3 obj = object_array[idx].mesh_object;
        GKSvertexArrPtr vertex_array = obj.vertices;
        GKSpolygonArrPtr polygon_array = obj.polygons;
        GKSint *compact_array = obj.polygons_compact;
        
        // Free the memory associated with actor data structure
        free(vertex_array);
        obj.vertices = NULL;
        free(polygon_array);
        obj.polygons = NULL;
        free(compact_array);
        obj.polygons_compact = NULL;
        
    }
    
    // TODO: Never tested
    if (idx > 0 && index < _object_count) {
        // index is in the middle of the list
        // brute force delete from array by copying elements from idx 0s based
        for (i=idx; i<_object_count; i++) {
            object_array[i].kind = object_array[i+1].kind;
            gks_copy_matrix_3(object_array[i+1].model_transform, object_array[i].model_transform);
            object_array[i].mesh_object = object_array[i+1].mesh_object;
            // needs line and fill colors and transforms? to be complete.
            // Better to use linked list instead.
        }
    }

    // Finally move stack pointer
    if (idx < _object_count) _object_count -= 1;
    
}


void gks_objarr_delete_last(void)
{
    gks_objarr_delete_at_index(_object_count);
}

void gks_objarr_delete_all(void)
{
    while (gks_objarr_count() > 0) {
        gks_objarr_delete_last();
    }
}


void compute_object_3(GKSactor *the_actor)
{
    GKSvertexArrPtr     vertex_array = NULL;
    GKSpolygonArrPtr    polygon_array = NULL;
    GKSint              *compact_array = NULL;
    GKSDCArrPtr         dev_coord_array = NULL;
    
    GKSint              pid;
    GKSint              polygonCount = 0;
    GKSint              vertex_idx = 0;
    GKSint              compact_idx = 0;
    GKSint              vertexCount = 0;

    GKSvector3d         temp_polygon_vertices[GKS_POLY_VERTEX_MAX];
    GKSpoint_2          temp_device_vertices[GKS_POLY_VERTEX_MAX];
    
    for (GKSint i=0; i<GKS_POLY_VERTEX_MAX; i++) {
        temp_polygon_vertices[i].crd.x = 0.0;
        temp_polygon_vertices[i].crd.y = 0.0;
        temp_polygon_vertices[i].crd.z = 0.0;
        temp_polygon_vertices[i].crd.w = 1.0;
        temp_device_vertices[i].x = 0.0;
        temp_device_vertices[i].y = 0.0;

    }
    
    vertex_array = the_actor->mesh_object.vertices;
    polygon_array = the_actor->mesh_object.polygons;
    compact_array = the_actor->mesh_object.polygons_compact;    // TODO: use this instead of polygon_array
    dev_coord_array = the_actor->devcoords;
    
    // TODO: transform object vertices first
    // to speed things up I should transform all the vertices of the object
    // to viewport space coordinates, and then test normals and then draw
    // polygons. Use a seperate vertex buffer like the one for polygons.
    
    polygonCount = the_actor->mesh_object.polynum;
    GKSint k = 0;
//    printf("compute object\n");

    for(pid=0; pid<polygonCount; pid++) {
        
        // copy polygon points over to a temporary array as a guard against modifying
        // the original data.
        vertexCount = polygon_array[pid][0];
        k += 1;
        
        for(GKSint j=0; j<vertexCount; j++){
//            vertex_idx = polygon_array[pid][j+1] - 1;     // this is a gotcha
            
            compact_idx = compact_array[k] - 1;
//            printf("poly_vertex: %d  ---  %d\n", vertex_idx, compact_idx);

            k += 1;
            
            // TODO: verfiy that this is a copy
            temp_polygon_vertices[j] = vertex_array[compact_idx];
        }

        // FIXME: does not work
        // dev coords index needs to be filled for each polygon
        gks_prep_polyline_3(pid, vertexCount, temp_polygon_vertices, temp_device_vertices, &the_actor->line_color);
        
        for(GKSint j=0; j<vertexCount; j++){
            vertex_idx = polygon_array[pid][j+1] - 1;     // this is a gotcha
            // TODO: verfiy that this is a copy
//            devcoordList[vertexNumber] = temp_device_vertices[j];   // mesh
            dev_coord_array[vertex_idx] = temp_device_vertices[j];    // actor
        }

        
    }
}

void draw_computed_object_3(GKSactor *the_actor)
{
    GKSpoint_2          temp_device_vertices[GKS_POLY_VERTEX_MAX];

    for (GKSint i=0; i<GKS_POLY_VERTEX_MAX; i++) {

        temp_device_vertices[i].x = 0.0;
        temp_device_vertices[i].y = 0.0;

    }
    GKSpolygonArrPtr polygon_array = the_actor->mesh_object.polygons;
    GKSint *compact_array = the_actor->mesh_object.polygons_compact;
    GKSDCArrPtr dev_coord_array = the_actor->devcoords;
    
    GKSint poly_count = the_actor->mesh_object.polynum;
    GKSint k = 0;
//    printf("draw object\n");
    for (GKSint i=0; i < poly_count; i++) {
        GKSint vert_count = polygon_array[i][0];
        k += 1;                                                  // vertex count part
        for(GKSint j=0; j<vert_count; j++){
            // FIXME: differs from addObjectRepToScene
            // vertex numbers in MESH file start at 1.
            // array indices are zero based 0.
            // so, -1 from vertex index -> array index.
            // 4,3,2,1 -> 3,2,1,0
            //
            
            
            // this is a gotcha the j+1 skips
            // the vertex count part of the matrix
            // and the ( - 1) turns a point number
            // which normally start at 1 into a
            // zero based array index.
//            GKSint vertexIndex = polygon_array[i][j+1] - 1 ;
            
            GKSint compact_idx = compact_array[k] - 1;
            
            k += 1;
                        
            // TODO: verfiy that this is a copy
            temp_device_vertices[j] = dev_coord_array[compact_idx];
        }
        
        // call-back to drawing routine
        gks_localpolyline_3(i, vert_count, temp_device_vertices, &the_actor->line_color);
        
    }
}


// TODO: pipeline objects
void gks_compute_object(GKSactor *the_actor)
{
    // set object into the world
    gks_set_world_model_matrix(the_actor->model_transform);
    compute_object_3(the_actor);
    
}

void gks_draw_computed_object(GKSactor *the_actor)
{
    draw_computed_object_3(the_actor);
    
}

void gks_objarr_draw_list(void)
{
    for (int i=0; i<_object_count; i++) {
        GKSactor *actor_ptr = &object_array[i];
        gks_compute_object(actor_ptr);
        gks_draw_computed_object(actor_ptr);
    }
}
