//
//  GKSSceneRep.m
//  GeKoS
//
//  Created by Alex Popadich on 4/19/22.
//

#import "GKSSceneRep.h"

@implementation GKSSceneRep

- (instancetype)init
{
    self = [super init];
    if (self) {
        _toObject3DReps = [[NSMutableArray alloc] initWithCapacity:1024];
    }
    return self;
}

@end
