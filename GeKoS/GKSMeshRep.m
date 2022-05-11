//
//  GKSMeshRep.m
//  GeKoS
//
//  Created by Alex Popadich on 4/19/22.
//

#import "GKSMeshRep.h"
#include "gks/gks.h"

@implementation GKSMeshRep


- (instancetype)initWithID:(NSNumber *)meshID andName:(NSString *)meshName andMeshPtr:(GKSmesh_3 *)meshPtr andOffString:(NSString *)offString
{
    self = [super init];
    if (self) {
        _meshId = meshID;
        _meshPtr = meshPtr;
        _meshName = meshName;
        _offString = offString;
    }
    return self;
}


@end
