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


- (void)castArrayOfActors:(NSArray *)actors
{
    NSLog(@"Cast array of actors now");

// TODO: pull old actor white pages
    
    NSMutableDictionary *actorWhitePages = [[NSMutableDictionary alloc] initWithCapacity:1024];

    // FIXME: override fetch
    for (ActorEntity *actorEntity in actors) {
        GKS3DActor *actor = [self.scene castActorFromEnt:actorEntity];
        [actorWhitePages setObject:actor forKey:actorEntity.name];
        [self.scene stageActor:actor];
        
//        actorEntity.transientActor = actor;
    }
    self.actorWhitePages = actorWhitePages;


}


- (void)transformAllObjects
{
    GKSSceneRep *scene = self.scene;
    GKScontext3DPtr ctx = scene.context;
    NSAssert(ctx != NULL, @"Scene context not set");

    for (GKS3DActor *actorObject in scene.toActors) {
        [actorObject computeActorInContext:ctx];
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
