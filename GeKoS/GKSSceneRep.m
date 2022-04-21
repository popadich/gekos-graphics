//
//  GKSSceneRep.m
//  GeKoS
//
//  Created by Alex Popadich on 4/19/22.
//

#import "GKSSceneRep.h"
#import "GKS3DObjectRep.h"

@implementation GKSSceneRep

- (instancetype)init
{
    self = [super init];
    if (self) {
        _toObject3DReps = [[NSMutableArray alloc] initWithCapacity:1024];
    }
    return self;
}

- (void)add3DObjectRep:(GKS3DObjectRep *)object3DRep
{
    [self.toObject3DReps addObject:object3DRep];

}

- (void)deleteLast3DObjectRep
{
    [self.toObject3DReps removeLastObject];
}

@end
