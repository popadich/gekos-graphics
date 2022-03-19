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

#define XS_MAX_SCENE_OBJECTS    32

static bool         _hidden_Surface_Removal_Flag;
static int          _object_count;                      // count of objects 3D
static Actor        object_array[XS_MAX_SCENE_OBJECTS];  // world Scene max objects

void gks_init_object_list(void)
{
    _object_count = 0;
    _hidden_Surface_Removal_Flag = false;
}

void gks_objarr_set_hidden_surface_removal(bool flag)
{
    _hidden_Surface_Removal_Flag = flag;
}

bool gks_objarr_get_hidden_surface_removal(void)
{
    return _hidden_Surface_Removal_Flag;
}

int gks_objarr_count(void)
{
    return _object_count;
}

// TODO: return a pointer instead
Actor gks_objarr_object_at_index(int index) {
    Actor object3d = object_array[index];
    return object3d;
}

bool gks_objarr_add(ObjectKind kind, GKSobject_3 *object, GKSvector3d transVec, GKSvector3d scaleVec, GKSvector3d rotVec, GKScolor lineColor)
{
    //add_object_new(object, transVec, scaleVec, rotVec);
    bool did_add = false;
    
    if (_object_count<XS_MAX_SCENE_OBJECTS) {

        object_array[_object_count].kind = kind;
        object_array[_object_count].its_color = lineColor;

        gks_create_scaling_matrix_3(scaleVec.crd.x,scaleVec.crd.y,scaleVec.crd.z,object_array[_object_count].instanceTransform);
        
        // ORDER MATTERS S x R x T
        gks_accumulate_x_rotation_matrix_3(rotVec.crd.x,object_array[_object_count].instanceTransform);
        gks_accumulate_y_rotation_matrix_3(rotVec.crd.y,object_array[_object_count].instanceTransform);
        gks_accumulate_z_rotation_matrix_3(rotVec.crd.z,object_array[_object_count].instanceTransform);
        gks_accumulate_translation_matrix_3(transVec.crd.x, transVec.crd.y, transVec.crd.z, object_array[_object_count].instanceTransform);
        
        // !!!: This copies the object
        object_array[_object_count].instanceObject = *object;
        
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

void gks_objarr_update_object(GKSint index, GKSint kind, GKSfloat tx, GKSfloat ty, GKSfloat tz, GKSfloat sx, GKSfloat sy, GKSfloat sz, GKSfloat rx, GKSfloat ry, GKSfloat rz)
{        
    if (index >=0 && index<_object_count) {
        if (object_array[index].kind == kind) {
            gks_create_scaling_matrix_3(sx,sy,sz, object_array[index].instanceTransform);
            gks_accumulate_x_rotation_matrix_3(rx, object_array[index].instanceTransform);
            gks_accumulate_y_rotation_matrix_3(ry, object_array[index].instanceTransform);
            gks_accumulate_z_rotation_matrix_3(rz, object_array[index].instanceTransform);
            gks_accumulate_translation_matrix_3(tx,ty,tz, object_array[index].instanceTransform);
            object_array[index].scaleVector.crd.x = sx;
            object_array[index].scaleVector.crd.y = sy;
            object_array[index].scaleVector.crd.z = sz;
            object_array[index].translateVector.crd.x = tx;
            object_array[index].translateVector.crd.y = ty;
            object_array[index].translateVector.crd.z = tz;
            object_array[index].rotateVector.crd.x = rx;
            object_array[index].rotateVector.crd.y = ry;
            object_array[index].rotateVector.crd.z = rz;
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
        GKSobject_3 obj = object_array[idx].instanceObject;
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
            gks_copy_matrix_3(object_array[i+1].instanceTransform, object_array[i].instanceTransform);
            object_array[i].instanceObject = object_array[i+1].instanceObject;
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


void draw_object_3(GKSobject_3 *theObject, GKScolor *object_color, bool hiddenSurfaceRemoveFlag)
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
    
    vertexList = theObject->vertices;
    polygonList = theObject->polygons;
    transVertList = theObject->transverts;
    devcoordList = theObject->devcoords;
    
    // TODO: transform object vertices first
    // to speed things up I should transform all the vertices of the object
    // to viewport space coordinates, and then test normals and then draw
    // polygons. Use a seperate vertex buffer like the one for polygons.
    
    polygonCount = theObject->polynum;
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

        gks_prep_polyline_3(polygonID, polygon_point_count, temp_vertex_array, transVertList, devcoordList, object_color);
        gks_localpolyline_3(polygonID, polygon_point_count, transVertList, devcoordList, object_color);
        
    }
}


void gks_objarr_draw_object(Actor the_object)
{
    gks_set_world_model_matrix(the_object.instanceTransform);
    
    draw_object_3(&the_object.instanceObject, &the_object.its_color, _hidden_Surface_Removal_Flag);
    
}

void gks_objarr_draw_list(void)
{
    for (int i=0; i<_object_count; i++) {
        gks_objarr_draw_object(object_array[i]);
    }
}
