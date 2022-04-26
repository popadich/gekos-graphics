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

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSError* error;
        NSColor* aColor;
        
        NSData* theData = [[NSUserDefaults standardUserDefaults] dataForKey:gksPrefBackgroundColor];
        if (theData != nil){
            aColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:theData error:&error];
            if (error.code == noErr) {
                self.worldBackColor = aColor;
            }
        }
        theData = [[NSUserDefaults standardUserDefaults] dataForKey:gksPrefPenColor];
        if (theData != nil){
            aColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:theData error:&error];
            if (error.code == noErr) {
                self.worldLineColor = aColor;
            }
        };
        theData = [[NSUserDefaults standardUserDefaults] dataForKey:gksPrefFillColor];
        if (theData != nil) {
            aColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:theData error:&error];
            if (error.code == noErr) {
                self.worldFillColor = aColor;
            }
        }
        
    }

    return self;
}



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
        
        GKSMeshMonger *monger = [GKSMeshMonger sharedMeshMonger];
        
        GKSMeshRep *theMeshRep = [monger getMeshRep:object3DRep.objectKind];
        GKSmesh_3 *theMesh = theMeshRep.meshPtr;
        
        if (theMesh != NULL) {
            [scene add3DObjectRep:object3DRep withMesh:theMesh];
      }
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

    
    // very esoteric calls here, make this simpler
    NSAssert(ctx != NULL, @"Scene context not set");
    

    if (ctx != NULL) {
        GKSlimits_3 *volume = [scene worldVolumeLimits];
        NSLog(@"get scene bolume %lf, %lf, %lf, %lf, %lf, %lf", volume->xmin, volume->xmax,
              volume->ymin, volume->ymax,
              volume->zmin, volume->zmax);
        gks_norms_set_world_volume(ctx, volume);
    }
    
}


@end
