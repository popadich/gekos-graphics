//
//  GKSMeshMonger.m
//  GeKoS
//
//  Created by Alex Popadich on 4/20/22.
//

#import "GKSMeshMonger.h"
#include "gks/gks.h"

@interface GKSMeshMonger ()

@property (strong)NSMutableDictionary *meshes;
@property (assign)NSInteger maxID;

@end

@implementation GKSMeshMonger


+ (id)sharedMeshMonger {
    static GKSMeshMonger *sharedMeshMonger = nil;
    
    static dispatch_once_t onceToken; // onceToken = 0
    _dispatch_once(&onceToken, ^{
        sharedMeshMonger = [[GKSMeshMonger alloc] init];
    });
    
    return sharedMeshMonger;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        _meshes = [[NSMutableDictionary alloc] init];
        
        GKSMeshRep *cubemeshRep = [[GKSMeshRep alloc] initWithID:@(kCubeKind) andMeshPtr:CubeMesh()];
        [self.meshes setObject:cubemeshRep forKey:cubemeshRep.meshId];
        
        GKSMeshRep *pyramidmeshRep = [[GKSMeshRep alloc] initWithID:@(kPyramidKind) andMeshPtr:PyramidMesh()];
        [self.meshes setObject:pyramidmeshRep forKey:pyramidmeshRep.meshId];

        GKSMeshRep *housemeshRep = [[GKSMeshRep alloc] initWithID:@(kHouseKind) andMeshPtr:HouseMesh()];
        [self.meshes setObject:housemeshRep forKey:housemeshRep.meshId];

        GKSMeshRep *spheremeshRep = [[GKSMeshRep alloc] initWithID:@(kSphereKind) andMeshPtr:SphereMesh()];
        [self.meshes setObject:spheremeshRep forKey:spheremeshRep.meshId];

        GKSMeshRep *conemeshRep = [[GKSMeshRep alloc] initWithID:@(kConeKind) andMeshPtr:ConeMesh()];
        [self.meshes setObject:conemeshRep forKey:conemeshRep.meshId];

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


- (NSArray *)meshList
{
    NSMutableArray *meshes = [[NSMutableArray alloc] init];
    for (int i=kCubeKind; i<=kHouseKind; i++) {
        GKSMeshRep *meshRep = [self getMeshRep:@(i)];
        [meshes addObject:meshRep];
        
    }
    
    return ([NSArray arrayWithArray:meshes]);
}




@end
