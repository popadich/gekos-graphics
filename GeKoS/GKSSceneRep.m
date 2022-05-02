//
//  GKSSceneRep.m
//  GeKoS
//
//  Created by Alex Popadich on 4/19/22.
//

#import "GKSSceneRep.h"
#import "GKSConstants.h"
#import "GKS3DObjectRep.h"
#import "GKS3DActor.h"
#import "GKSMeshMonger.h"


@interface GKSSceneRep() {
    GKSlimits_3 volume;
}
@property (assign) GKSint gObjectRepID;
@property (strong) NSMutableArray* toObject3DReps;

@end


@implementation GKSSceneRep

- (instancetype)initWithContext:(GKScontext3D *)contextPtr
{
    self = [super init];
    if (self) {
        _title = @"Scene One";
        _gObjectRepID = 1;
        
        _toObject3DReps = [[NSMutableArray alloc] initWithCapacity:1024];
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

- (void)doStageActor:(GKS3DObjectRep * _Nonnull)object3DRep {

    GKSvector3d loc = [object3DRep positionVector];
    GKSvector3d rot = [object3DRep rotationVector];
    GKSvector3d sca = [object3DRep scaleVector];
    
    GKSMeshMonger *monger = [GKSMeshMonger sharedMeshMonger];
    
    GKSMeshRep *theMeshRep = [monger getMeshRep:object3DRep.objectKind];
    GKSmesh_3 *the_mesh = theMeshRep.meshPtr;
    
    NSAssert(the_mesh != NULL, @"Mesh pointer is missing");
    
    GKS3DActor *newActor = [[GKS3DActor alloc] initWithMesh:the_mesh ofKind:object3DRep.objectKind atLocation:loc withRotation:rot andScale:sca];
    
    newActor.lineColor = object3DRep.lineColor;
    newActor.fillColor = object3DRep.fillColor;
    [newActor computeActorInContext:self.context];
    
    object3DRep.actorObject = newActor;
    [self.toActors addObject:newActor];

}

- (void)add3DObjectRep:(GKS3DObjectRep *)object3DRep
{
//    BOOL createActors = NO;
//    if (createActors) {
//        [self doStageActor:object3DRep];
//    }
//    
    object3DRep.objectID = @(self.gObjectRepID);
    self.gObjectRepID += 1;
    
    NSMutableArray *bindingsCompliantArray = [self mutableArrayValueForKey:@"toObject3DReps"];
    [bindingsCompliantArray addObject:object3DRep];

}

- (void)deleteLast3DObjectRep
{
    NSMutableArray *bindingsCompliantArray = [self mutableArrayValueForKey:@"toObject3DReps"];
    [bindingsCompliantArray removeLastObject];
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
