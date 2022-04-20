//
//  GKSMeshMonger.m
//  GeKoS
//
//  Created by Alex Popadich on 4/20/22.
//

#import "GKSMeshMonger.h"
#include "gks/gks.h"

@interface GKSMeshMonger ()

@property (assign) NSInteger maxID;

@end

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

        _maxID = kHouseKind;
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

- (NSNumber *)nextID
{
    self.maxID += 1;
    NSNumber *newID = [NSNumber numberWithInt:(GKSint)self.maxID];
    return newID;
}


@end
