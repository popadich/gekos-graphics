//
//  GKSMeshMonger.m
//  GeKoS
//
//  Created by Alex Popadich on 4/20/22.
//

#import "GKSMeshMonger.h"
#include "gks/gks.h"

@implementation GKSMeshMonger

- (instancetype)init
{
    self = [super init];
    if (self) {
        _meshes = [[NSMutableDictionary alloc] init];
        
        GKSMeshRep *meshRep = [[GKSMeshRep alloc] initWithID:@(kCubeKind) andMeshPtr:CubeMesh()];
        [self.meshes setObject:meshRep forKey:meshRep.meshId];
        
        meshRep = [[GKSMeshRep alloc] initWithID:@(kPyramidKind) andMeshPtr:PyramidMesh()];
        [self.meshes setObject:meshRep forKey:meshRep.meshId];

        meshRep = [[GKSMeshRep alloc] initWithID:@(kHouseKind) andMeshPtr:HouseMesh()];
        [self.meshes setObject:meshRep forKey:meshRep.meshId];

        meshRep = [[GKSMeshRep alloc] initWithID:@(kSphereKind) andMeshPtr:SphereMesh()];
        [self.meshes setObject:meshRep forKey:meshRep.meshId];

        meshRep = [[GKSMeshRep alloc] initWithID:@(kConeKind) andMeshPtr:ConeMesh()];
        [self.meshes setObject:meshRep forKey:meshRep.meshId];

        
    }
    return self;
}

- (void)addMeshRep:(GKSMeshRep *)meshRep
{
    [self.meshes setObject:meshRep forKey:meshRep.meshId];

}

- (GKSMeshRep *)getMeshRep:(NSNumber *)meshID
{
    GKSMeshRep *theMesh = nil;
    
    theMesh = [self.meshes objectForKey:meshID];
    
    
    return theMesh;
}


@end
