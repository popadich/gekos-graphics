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

#define GKS_MAX_SCENE_OBJECTS    32

static bool         _visble_Surface_Only_Flag;
static int          _object_count;                          // count of objects 3D
static GKSactor        object_array[GKS_MAX_SCENE_OBJECTS];    // world Scene max objects

void gks_init_object_list(void)
{
    _object_count = 0;
    _visble_Surface_Only_Flag = false;
}

void gks_objarr_set_hidden_surface_removal(bool flag)
{
    _visble_Surface_Only_Flag = flag;
}

bool gks_objarr_get_hidden_surface_removal(void)
{
    return _visble_Surface_Only_Flag;
}

int gks_objarr_count(void)
{
    return _object_count;
}

// TODO: return a pointer instead
GKSactor gks_objarr_object_at_index(int index) {
    GKSactor object3d = object_array[index];
    return object3d;
}

bool gks_objarr_add(GKSobjectKind kind, GKSobject_3 *object, GKSvector3d transVec, GKSvector3d rotVec, GKSvector3d scaleVec, GKScolor lineColor, GKScolor fillColor)
{
    //add_object_new(object, transVec, scaleVec, rotVec);
    bool did_add = false;
    
    if (_object_count<GKS_MAX_SCENE_OBJECTS) {

        object_array[_object_count].kind = kind;
        object_array[_object_count].fill_color = fillColor;
        object_array[_object_count].line_color = lineColor;

        gks_create_scaling_matrix_3(scaleVec.crd.x,scaleVec.crd.y,scaleVec.crd.z,object_array[_object_count].modelTransform);
        
        // ORDER MATTERS S x R x T
        gks_accumulate_x_rotation_matrix_3(rotVec.crd.x,object_array[_object_count].modelTransform);
        gks_accumulate_y_rotation_matrix_3(rotVec.crd.y,object_array[_object_count].modelTransform);
        gks_accumulate_z_rotation_matrix_3(rotVec.crd.z,object_array[_object_count].modelTransform);
        gks_accumulate_translation_matrix_3(transVec.crd.x, transVec.crd.y, transVec.crd.z, object_array[_object_count].modelTransform);
        
        // !!!: This copies the object
        object_array[_object_count].meshObject = *object;
        
        object_array[_object_count].scaleVector = scaleVec;
        object_array[_object_count].rotateVector = rotVec;
        object_array[_object_count].translateVector = transVec;
        
        
        // @TODO: Add object to Table View
        // Add to some kind of list that can be displayed in the GUI
        //AddObjectToList(gTopOfIndex,actorList[gTopOfIndex].instanceKind,tx,ty,tz,rx,ry,rz,sx,sy,sz);
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
            gks_create_scaling_matrix_3(sx,sy,sz, object_array[index].modelTransform);
            gks_accumulate_x_rotation_matrix_3(rx, object_array[index].modelTransform);
            gks_accumulate_y_rotation_matrix_3(ry, object_array[index].modelTransform);
            gks_accumulate_z_rotation_matrix_3(rz, object_array[index].modelTransform);
            gks_accumulate_translation_matrix_3(tx,ty,tz, object_array[index].modelTransform);
            object_array[index].scaleVector = scale;
            object_array[index].translateVector = translate;
            object_array[index].rotateVector = rotate;
            // UpdateObjectList(index,kind,tx,ty,tz,rx,ry,rz,sx,sy,sz);
        }
    }

}



// be careful, this seems to be 1s based indexing. Not sure this has ever been tested.
void gks_objarr_delete_at_index(int index)
{
    int i;
    
    int idx = index - 1;
    if (idx < _object_count) {
  
        // Free the memory associated with actor object
        GKSobject_3 obj = object_array[idx].meshObject;
        GKSvertexArrPtr verts = obj.vertices;
        GKSpolygonArrPtr polys = obj.polygons;
//        GKSnormalArrPtr norms = obj.normals;
//        GKSvertexArrPtr trans = obj.transverts;
//        GKSDCArrPtr dvcds = obj.devcoords;
        free(verts);
        obj.vertices = NULL;
        free(polys);
        obj.polygons = NULL;
//        free(norms);
//        obj.normals = NULL;
//        free(trans);
//        obj.transverts = NULL;
//        free(dvcds);
//        obj.devcoords = NULL;
        
    }
    
    // TODO: Never tested
    if (index < _object_count) {
        // index is in the middle of the list
        // brute force delete from array by copying elements from idx 0s based
        for (i=idx; i<_object_count; i++) {
            object_array[i].kind = object_array[i+1].kind;
            gks_copy_matrix_3(object_array[i+1].modelTransform, object_array[i].modelTransform);
            object_array[i].meshObject = object_array[i+1].meshObject;
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

void gks_objarr_delete_all(void) {
    while (gks_objarr_count() > 0) {
        gks_objarr_delete_last();
    }
}


void draw_object_3(GKSactor *theObject)
{
    GKSvertexArrPtr     vertexList;
    GKSpolygonArrPtr    polygonList;
    GKSvertexArrPtr     transVertList;
    GKSDCArrPtr         devcoordList;
    
    GKSint              polygonID;
    GKSint              polygonCount;
    GKSint              vertexNumber;
    GKSint              polygon_point_count;
    
    GKSvector3d         temp_vertex_array[GKS_MIN_VERTEX_COUNT];
    for (GKSint i=0; i<GKS_MIN_VERTEX_COUNT; i++) {
        temp_vertex_array[i].crd.x = 0.0;
        temp_vertex_array[i].crd.y = 0.0;
        temp_vertex_array[i].crd.z = 0.0;
        temp_vertex_array[i].crd.w = 1.0;
    }
    
    vertexList = theObject->meshObject.vertices;
    polygonList = theObject->meshObject.polygons;
    transVertList = theObject->meshObject.transverts;
    devcoordList = theObject->meshObject.devcoords;
    
    // TODO: transform object vertices first
    // to speed things up I should transform all the vertices of the object
    // to viewport space coordinates, and then test normals and then draw
    // polygons. Use a seperate vertex buffer like the one for polygons.
    
    polygonCount = theObject->meshObject.polynum;
//    totalVerteces = theObject->vertnum;

    for(polygonID=0; polygonID<polygonCount; polygonID++) {
        
        // copy polygon points over to a temporary array as a guard against modifying
        // the original data.
        polygon_point_count = polygonList[polygonID][0];
        for(GKSint j=0; j<polygon_point_count; j++){
            vertexNumber = polygonList[polygonID][j+1] - 1;     // this is a gotcha
            // TODO: verfiy that this is a copy
            temp_vertex_array[j] = vertexList[vertexNumber];
        }

        gks_prep_polyline_3(polygonID, polygon_point_count, temp_vertex_array, devcoordList, &theObject->line_color);
        gks_localpolyline_3(polygonID, polygon_point_count, devcoordList, &theObject->line_color);
        
    }
}


void gks_objarr_draw_object(GKSactor the_object)
{
    gks_set_world_model_matrix(the_object.modelTransform);
    
    // TODO: arguments smell
    draw_object_3(&the_object);
    
}

void gks_objarr_draw_list(void)
{
    for (int i=0; i<_object_count; i++) {
        gks_objarr_draw_object(object_array[i]);
    }
}
