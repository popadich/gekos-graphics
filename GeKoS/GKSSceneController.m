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
    GKSlimits_3 volume;
}


@end


@implementation GKSSceneController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _worldVolumeMinX = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMinX];
        _worldVolumeMaxX = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMaxX];
        _worldVolumeMinY = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMinY];
        _worldVolumeMaxY = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMaxY];
        _worldVolumeMinZ = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMinZ];
        _worldVolumeMaxZ = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMaxZ];
        
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


- (GKSlimits_3 *)worldVolumeLimits
{
    volume.xmin = self.worldVolumeMinX.doubleValue;
    volume.ymin = self.worldVolumeMinY.doubleValue;
    volume.zmin = self.worldVolumeMinZ.doubleValue;
    
    volume.xmax = self.worldVolumeMaxX.doubleValue;
    volume.ymax = self.worldVolumeMaxY.doubleValue;
    volume.zmax = self.worldVolumeMaxZ.doubleValue;
    return &volume;
}

- (void)setFrustumCulling:(BOOL)flag
{
    self.context->cullFlag = flag;
}


- (void)add3DObjectRep:(GKS3DObjectRep *)object3DRep
{
    // TODO: assert not null
    if (self.context != NULL) {
        
        GKSMeshRep *theMeshRep = [self.monger getMeshRep:object3DRep.objectKind];
        GKSmesh_3 *theMesh = theMeshRep.meshPtr;
        
        if (theMesh != NULL) {
            [self.scene add3DObjectRep:object3DRep withMesh:theMesh forContext:self.context];
        }
    }
}



- (void)deleteLastObject
{
    [self.scene deleteLast3DObjectRep];
}

- (void)transformAllObjects
{
    GKScontext3DPtr ctx = self.context;
    for (GKS3DObjectRep *objRep in self.scene.toObject3DReps) {
        [objRep.actorObject computeActorInContext:ctx];
    }
}

- (void)setWorldVolumeG
{
    // very esoteric calls here, make this simpler
    if (self.context != NULL) {
        GKSlimits_3 *volume = [self worldVolumeLimits];
        gks_norms_set_world_volume(self.context, volume);
    }
    
}


@end
