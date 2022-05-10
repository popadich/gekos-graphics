//
//  GKSMeshRep.m
//  GeKoS
//
//  Created by Alex Popadich on 4/19/22.
//

#import "GKSMeshRep.h"
#include "gks/gks.h"

@implementation GKSMeshRep


- (instancetype)initWithID:(NSNumber *)meshID andMeshPtr:(GKSmesh_3 *)meshPtr andOffString:(NSString *)offString
{
    self = [super init];
    if (self) {
        _meshId = meshID;
        _meshPtr = meshPtr;
        
        if (meshID.intValue <= kHouseKind) {
            NSDictionary *meshNameLookup = @{  @1 : @"Cube",
                                               @2 : @"Sphere",
                                               @3 : @"Pyramid",
                                               @4 : @"Cone",
                                               @5 : @"House"
            };
            _meshName = meshNameLookup[meshID];
        }
        else
            _meshName = @"Tetra";
        
        _offString = offString;
    }
    return self;
}


@end
