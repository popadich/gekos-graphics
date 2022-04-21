//
//  GKSSceneRep.m
//  GeKoS
//
//  Created by Alex Popadich on 4/19/22.
//

#import "GKSSceneRep.h"
#import "GKS3DObjectRep.h"
#import "GKS3DObject.h"

@implementation GKSSceneRep

- (instancetype)initWithContext:(GKScontext3D *)contextPtr
{
    self = [super init];
    if (self) {
        _toObject3DReps = [[NSMutableArray alloc] initWithCapacity:1024];
        _context = contextPtr;
    }
    return self;
}

- (void)add3DObjectRep:(GKS3DObjectRep *)object3DRep withMesh:(GKSmesh_3 *)aMesh
{
    
    GKSvector3d loc = [object3DRep positionVector];
    GKSvector3d rot = [object3DRep rotationVector];
    GKSvector3d sca = [object3DRep scaleVector];

    GKS3DObject *newActor = [[GKS3DObject alloc] initWithMesh:aMesh atLocation:loc withRotation:rot andScale:sca];

    newActor.lineColor = object3DRep.lineColor;
    newActor.fillColor = object3DRep.fillColor;
    
    [newActor computeActorInContext:self.context];
    
    object3DRep.actorObject = newActor;
    
    [self.toObject3DReps addObject:object3DRep];

}

- (void)deleteLast3DObjectRep
{
    [self.toObject3DReps removeLastObject];
}

@end
