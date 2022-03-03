//
//  GKSCameraRep.m
//  GeKoS
//
//  Created by Alex Popadich on 3/2/22.
//

#import "GKSCameraRep.h"
#include "gks/gks_types.h"

@interface GKSCameraRep () {
    float unit_vect[3];
}

@end

@implementation GKSCameraRep

- (instancetype)init
{
    self = [super init];
    if (self) {
        _upX = [NSNumber numberWithFloat:0.0];
        _upY = [NSNumber numberWithFloat:1.0];
        _upZ = [NSNumber numberWithFloat:0.0];
        _dirX = [NSNumber numberWithFloat:0.0];
        _dirY = [NSNumber numberWithFloat:0.0];
        _dirZ = [NSNumber numberWithFloat:1.0];
        _positionX = [NSNumber numberWithFloat:0.0];
        _positionY = [NSNumber numberWithFloat:0.0];
        _positionZ = [NSNumber numberWithFloat:1.0];
        
        // TODO: get from preference
        _projectionType = [NSNumber numberWithInt:kPerspectiveProjection];
        _perspectiveProjectionFlag = [NSNumber numberWithBool:YES];
        _perspectiveDistance = [NSNumber numberWithFloat:1.0];
        
        _visibleSurfaceFlag = [NSNumber numberWithBool:NO];
        _useLookAt = [NSNumber numberWithBool:NO];
   }
    return self;
}


@end