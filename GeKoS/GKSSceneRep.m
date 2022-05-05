//
//  GKSSceneRep.m
//  GeKoS
//
//  Created by Alex Popadich on 4/19/22.
//

#import "GKSSceneRep.h"
#import "GKSConstants.h"
#import "GKS3DActor.h"
#import "GKSMeshMonger.h"



@interface GKSSceneRep() {
    GKSlimits_3 volume;
}

@end


@implementation GKSSceneRep

- (instancetype)initWithContext:(GKScontext3D *)contextPtr
{
    self = [super init];
    if (self) {
        _title = @"Scene One";
        
        _toActors = [[NSMutableSet alloc] initWithCapacity:1024];
        _context = contextPtr;
        
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

- (GKS3DActor *)castActorFromEnt:(ActorEntity * _Nonnull)actorEntity
{
    
    GKSvector3d loc = GKSMakeVector(actorEntity.locX, actorEntity.locY, actorEntity.locZ);
    GKSvector3d rot = GKSMakeVector(actorEntity.rotX, actorEntity.rotY, actorEntity.rotZ);
    GKSvector3d sca = GKSMakeVector(actorEntity.scaleX, actorEntity.scaleY, actorEntity.scaleZ);

    NSNumber *kindNum = @(actorEntity.kind);
    
    GKSMeshMonger *monger = [GKSMeshMonger sharedMeshMonger];
    GKSMeshRep *theMeshRep = [monger getMeshRep:kindNum];
    GKSmesh_3 *the_mesh = theMeshRep.meshPtr;
    
    NSAssert(the_mesh != NULL, @"Mesh pointer is missing");
    GKS3DActor *newActorObject = [[GKS3DActor alloc] initWithMesh:the_mesh ofKind:kindNum atLocation:loc withRotation:rot andScale:sca];
    
    // TODO: where are the colors stored?
    newActorObject.lineColor = [NSColor greenColor];
    newActorObject.fillColor = [NSColor greenColor];
    
    return newActorObject;
}

- (void)stageActor:(GKS3DActor *)actor
{

    [actor computeActorInContext:self.context];
    [self.toActors addObject:actor];   // add to local mutable set
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


@end
