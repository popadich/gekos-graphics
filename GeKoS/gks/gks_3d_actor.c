//
//  gks_3d_actor.c
//  GeKoS
//
//  Created by Alex Popadich on 4/22/22.
//

#include "gks_3d_actor.h"
#include "gks_3d_matrix.h"



void gks_actor_transform_to_world(GKSactor *actor) {
    GKSmatrix_3 transform;
    GKSvector3d scaleVec;
    GKSvector3d rotVec;
    GKSvector3d transVec;
    
    // TODO: use pointers
    scaleVec = actor->scale_vector;
    rotVec = actor->rotate_vector;
    transVec = actor->translate_vector;
    
    // Create transform matrix for model space to world space
    gks_create_scaling_matrix_3(scaleVec.crd.x,scaleVec.crd.y,scaleVec.crd.z, transform);
    
    // ORDER MATTERS S x R x T
    gks_accumulate_x_rotation_matrix_3(rotVec.crd.x, transform);
    gks_accumulate_y_rotation_matrix_3(rotVec.crd.y, transform);
    gks_accumulate_z_rotation_matrix_3(rotVec.crd.z, transform);
    gks_accumulate_translation_matrix_3(transVec.crd.x, transVec.crd.y, transVec.crd.z, transform);
    
    gks_matrix_copy_3(transform, actor->model_transform);
}
