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
        GKSvertexArrPtr verts = obj.vertices;
        GKSpolygonArrPtr polys = obj.polygons;
        GKSDCArrPtr dvcds = obj.devcoords;
        
        // Free the memory associated with actor data structure
        free(verts);
        obj.vertices = NULL;
        free(polys);
        obj.polygons = NULL;
        free(dvcds);
        obj.devcoords = NULL;
        
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


void compute_object_3(GKSactor *theObject)
{
    GKSvertexArrPtr     vertexList = NULL;
    GKSpolygonArrPtr    polygonList = NULL;
    GKSDCArrPtr         devcoordList = NULL;
    GKSDCArrPtr         devCoordPtr = NULL;
    
    GKSint              pid;
    GKSint              polygonCount = 0;
    GKSint              vertexNumber = 0;
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
    
    vertexList = theObject->mesh_object.vertices;
    polygonList = theObject->mesh_object.polygons;
    devcoordList = theObject->mesh_object.devcoords;
    devCoordPtr = theObject->devcoords;
    
    // TODO: transform object vertices first
    // to speed things up I should transform all the vertices of the object
    // to viewport space coordinates, and then test normals and then draw
    // polygons. Use a seperate vertex buffer like the one for polygons.
    
    polygonCount = theObject->mesh_object.polynum;

    for(pid=0; pid<polygonCount; pid++) {
        
        // copy polygon points over to a temporary array as a guard against modifying
        // the original data.
        vertexCount = polygonList[pid][0];
        
        for(GKSint j=0; j<vertexCount; j++){
            vertexNumber = polygonList[pid][j+1] - 1;     // this is a gotcha
            // TODO: verfiy that this is a copy
            temp_polygon_vertices[j] = vertexList[vertexNumber];
        }

        // FIXME: does not work
        // dev coords index needs to be filled for each polygon
        gks_prep_polyline_3(pid, vertexCount, temp_polygon_vertices, temp_device_vertices, &theObject->line_color);
        
        for(GKSint j=0; j<vertexCount; j++){
            vertexNumber = polygonList[pid][j+1] - 1;     // this is a gotcha
            // TODO: verfiy that this is a copy
//            devcoordList[vertexNumber] = temp_device_vertices[j];   // mesh
            devCoordPtr[vertexNumber] = temp_device_vertices[j];    // actor
        }

        
    }
}

void draw_computed_object_3(GKSactor *theObject)
{
    GKSpoint_2          temp_device_vertices[GKS_POLY_VERTEX_MAX];

    for (GKSint i=0; i<GKS_POLY_VERTEX_MAX; i++) {

        temp_device_vertices[i].x = 0.0;
        temp_device_vertices[i].y = 0.0;

    }
    GKSpolygonArrPtr polygonList = theObject->mesh_object.polygons;
    GKSDCArrPtr devcoordList = theObject->devcoords;
    
    GKSint polygonCount = theObject->mesh_object.polynum;

    for (GKSint i=0; i < polygonCount; i++) {
        GKSint vertexCount = polygonList[i][0];

        for(GKSint j=0; j<vertexCount; j++){
            // FIXME: differs from addObject3DToLists
            GKSint vertexIndex = polygonList[i][j+1] - 1 ;     // this is a gotcha
            // TODO: verfiy that this is a copy
            printf("Vertex Num: %d\n", vertexIndex);
            temp_device_vertices[j] = devcoordList[vertexIndex];
        }
        
        // FIXME: does not work
        // dev coords index needs to be moved for each polygon
        // call-back to drawing routine
        gks_localpolyline_3(i, vertexCount, temp_device_vertices, &theObject->line_color);
        
    }
}




void draw_object_3(GKSactor *theObject)
{
    GKSvertexArrPtr     vertexList;
    GKSpolygonArrPtr    polygonList;
    GKSDCArrPtr         devcoordList;
    
    GKSint              pid;
    GKSint              polygonCount;
    GKSint              vertexNumber;
    GKSint              polygon_point_count;
    
    // TODO: get rid of this temp allocation
    GKSvector3d         temp_vertex_array[GKS_POLY_VERTEX_MAX];
    
    for (GKSint i=0; i<GKS_POLY_VERTEX_MAX; i++) {
        temp_vertex_array[i].crd.x = 0.0;
        temp_vertex_array[i].crd.y = 0.0;
        temp_vertex_array[i].crd.z = 0.0;
        temp_vertex_array[i].crd.w = 1.0;
    }
    
    vertexList = theObject->mesh_object.vertices;
    polygonList = theObject->mesh_object.polygons;
    devcoordList = theObject->mesh_object.devcoords;
    
    // TODO: transform object vertices first
    // to speed things up I should transform all the vertices of the object
    // to viewport space coordinates, and then test normals and then draw
    // polygons. Use a seperate vertex buffer like the one for polygons.
    
    polygonCount = theObject->mesh_object.polynum;
//    totalVerteces = theObject->vertnum;

    for(pid=0; pid<polygonCount; pid++) {
        
        // copy polygon points over to a temporary array as a guard against modifying
        // the original data.
        polygon_point_count = polygonList[pid][0];
        for(GKSint j=0; j<polygon_point_count; j++){
            vertexNumber = polygonList[pid][j+1] - 1;     // !!!: this is a gotcha
            // TODO: verfiy that this is a copy
            temp_vertex_array[j] = vertexList[vertexNumber];
        }

        // transformations here
        //  world->model->view->camera->projection->...
        //
        gks_prep_polyline_3(pid, polygon_point_count, temp_vertex_array, devcoordList, &theObject->line_color);
        
        // call-back to drawing routine
        gks_localpolyline_3(pid, polygon_point_count, devcoordList, &theObject->line_color);
        
    }
}


// TODO: pipeline objects
void gks_compute_object(GKSactor *the_object)
{
    // set object into the world
    gks_set_world_model_matrix(the_object->model_transform);
    compute_object_3(the_object);
    
}

void gks_draw_computed_object(GKSactor *the_object)
{
    draw_computed_object_3(the_object);
    
}


void gks_objarr_draw_object(GKSactor *the_object)
{
    gks_set_world_model_matrix(the_object->model_transform);
    draw_object_3(the_object);
    
}

void gks_objarr_draw_list(void)
{
    for (int i=0; i<_object_count; i++) {
        GKSactor *actor_ptr = &object_array[i];
        gks_compute_object(actor_ptr);
        gks_draw_computed_object(actor_ptr);
    }
}
