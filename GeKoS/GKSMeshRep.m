//
//  GKSMeshRep.m
//  GeKoS
//
//  Created by Alex Popadich on 4/19/22.
//

#import "GKSMeshRep.h"
#include "gks/gks.h"

@implementation GKSMeshRep

- (instancetype)init
{
    return ([self initWithID:@(kCubeKind) andMeshPtr:CubeMesh()]);
}

- (instancetype)initWithID:(NSNumber *)meshID andMeshPtr:(GKSmesh_3 *)meshPtr
{
    self = [super init];
    if (self) {
        _meshId = meshID;
        _meshPtr = meshPtr;
        
        NSDictionary *meshNameLookup = @{  @1 : @"Cube",
                                           @2 : @"Sphere",
                                           @3 : @"Pyramid",
                                           @4 : @"Cone",
                                           @5 : @"House"
        };
        _meshName = meshNameLookup[meshID];
        
    }
    return self;
}

@end
