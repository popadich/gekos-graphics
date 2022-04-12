//
//  gks_3d_pipeline.c
//  GeKoS
//
//  Created by Alex Popadich on 4/12/22.
//

#include "gks_3d_pipeline.h"
#include "gks_drawing_glue.h"
#include "gks_3d_world.h"


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
