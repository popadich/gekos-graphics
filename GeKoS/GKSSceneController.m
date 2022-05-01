//
//  GKSScene.m
//  gks-cocoa
//
//  Created by Alex Popadich on 7/31/21.
//

#import "GKSSceneController.h"
#import "GKSConstants.h"
#import "GKSMeshRep.h"


@interface GKSSceneController () {
    float seg_vect[3];
}


@end


@implementation GKSSceneController


- (void)setFrustumCulling:(BOOL)flag
{
    GKSSceneRep *scene = self.scene;
    scene.context->cull_flag = flag;
}


- (void)add3DObjectRep:(GKS3DObjectRep *)object3DRep
{
    GKSSceneRep *scene = self.scene;
    GKScontext3DPtr ctx = scene.context;

    NSAssert(ctx != NULL, @"Scene context not set");
    if (ctx != NULL) {
        [scene add3DObjectRep:object3DRep];
    }
}

- (void)deleteLastObject
{
    GKSSceneRep *scene = self.scene;

    [scene deleteLast3DObjectRep];
}

- (void)transformAllObjects
{
    GKSSceneRep *scene = self.scene;
    GKScontext3DPtr ctx = scene.context;
    NSAssert(ctx != NULL, @"Scene context not set");
    for (GKS3DObjectRep *objRep in scene.toObject3DReps) {
        [objRep.actorObject computeActorInContext:ctx];
    }
}

- (void)setWorldVolumeG
{
    GKSSceneRep *scene = self.scene;
    GKScontext3DPtr ctx = scene.context;
    
    NSAssert(ctx != NULL, @"Scene context not set");
    if (ctx != NULL) {
        GKSlimits_3 *volume = [scene worldVolumeLimits];
        gks_norms_set_world_volume(ctx, volume);
    }
    
}


@end
