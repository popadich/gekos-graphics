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


- (void)castSetOfActors:(NSSet *)actorEntities
{
    NSLog(@"Cast set of actors now");
    
    //  pull old actors
//    [self.scene.toActors removeAllObjects];
    
    NSMutableSet *actors = [[NSMutableSet alloc] init];
    NSMutableDictionary *actorWhitePages = [[NSMutableDictionary alloc] initWithCapacity:1024];
    for (ActorEntity *actorEntity in actorEntities) {
        //TODO: get transient actor
        // actor = actorEntity.transientActor;
        GKS3DActor *actor = [self castActorFromEnt:actorEntity];
        [actorWhitePages setObject:actor forKey:actorEntity.name];
        [actors addObject:actor];
        
    }
    self.actorWhitePages = actorWhitePages;
    self.scene.toActors = actors;
}


- (GKS3DActor *)castActorFromEnt:(ActorEntity * _Nonnull)actorEntity
{
    
    GKSvector3d loc = GKSMakeVector(actorEntity.locX, actorEntity.locY, actorEntity.locZ);
    GKSvector3d rot = GKSMakeVector(actorEntity.rotX, actorEntity.rotY, actorEntity.rotZ);
    GKSvector3d sca = GKSMakeVector(actorEntity.scaleX, actorEntity.scaleY, actorEntity.scaleZ);

    NSNumber *kindNum = @(actorEntity.kind);
    
    GKSMeshMonger *monger = self.theMonger;
    GKSMeshRep *theMeshRep = [monger getMeshRep:kindNum];
    GKSmesh_3 *the_mesh = theMeshRep.meshPtr;
    
    NSAssert(the_mesh != NULL, @"Mesh pointer is missing");
    GKS3DActor *newActorObject = [[GKS3DActor alloc] initWithMesh:the_mesh ofKind:kindNum atLocation:loc withRotation:rot andScale:sca];
    
    // TODO: where are the colors stored?
    newActorObject.lineColor = actorEntity.lineColor;
    newActorObject.fillColor = [NSColor greenColor];
    
    return newActorObject;
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
