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

@interface GKSSceneRep ()
@property (assign) GKSint gObjectID;
@end

@implementation GKSSceneRep

- (instancetype)initWithContext:(GKScontext3D *)contextPtr
{
    self = [super init];
    if (self) {
        _title = @"Untitled Scene";
        _gObjectID = 1;
        
        _toObject3DReps = [[NSMutableArray alloc] initWithCapacity:1024];
        _context = contextPtr;
        
        _worldVolumeMinX = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMinX];
        _worldVolumeMaxX = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMaxX];
        _worldVolumeMinY = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMinY];
        _worldVolumeMaxY = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMaxY];
        _worldVolumeMinZ = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMinZ];
        _worldVolumeMaxZ = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMaxZ];
    }
    return self;
}

- (void)add3DObjectRep:(GKS3DObjectRep *)object3DRep withMesh:(GKSmesh_3 *)aMesh
{
    
    GKSvector3d loc = [object3DRep positionVector];
    GKSvector3d rot = [object3DRep rotationVector];
    GKSvector3d sca = [object3DRep scaleVector];

    GKS3DActor *newActor = [[GKS3DActor alloc] initWithMesh:aMesh atLocation:loc withRotation:rot andScale:sca];

    newActor.lineColor = object3DRep.lineColor;
    newActor.fillColor = object3DRep.fillColor;
    
    [newActor computeActorInContext:self.context];
    
    object3DRep.actorObject = newActor;
    object3DRep.objectID = @(self.gObjectID);
    self.gObjectID += 1;
    
    NSMutableArray *bindingsCompliantArray = [self mutableArrayValueForKey:@"toObject3DReps"];
    [bindingsCompliantArray addObject:object3DRep];

}

- (void)deleteLast3DObjectRep
{
    NSMutableArray *bindingsCompliantArray = [self mutableArrayValueForKey:@"toObject3DReps"];
    [bindingsCompliantArray removeLastObject];
}

@end
