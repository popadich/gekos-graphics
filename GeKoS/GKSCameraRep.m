//
//  GKSCameraRep.m
//  GeKoS
//
//  Created by Alex Popadich on 3/2/22.
//

#import "GKSCameraRep.h"
#include "gks/gks_types.h"

@interface GKSCameraRep () {
    Gpt_3 unit_vect;

}

@property (nonatomic, strong) NSNumber* vHatX;
@property (nonatomic, strong) NSNumber* vHatY;
@property (nonatomic, strong) NSNumber* vHatZ;

@end

@implementation GKSCameraRep

- (instancetype)init
{
    self = [super init];
    if (self) {
        _focalLength = [NSNumber numberWithFloat:1.0];
        _upX = [NSNumber numberWithFloat:0.0];
        _upY = [NSNumber numberWithFloat:1.0];
        _upZ = [NSNumber numberWithFloat:0.0];
        _dirX = [NSNumber numberWithFloat:0.0];
        _dirY = [NSNumber numberWithFloat:0.0];
        _dirZ = [NSNumber numberWithFloat:-1.0];
        _positionX = [NSNumber numberWithFloat:0.0];
        _positionY = [NSNumber numberWithFloat:0.0];
        _positionZ = [NSNumber numberWithFloat:1.0];
        
        _vHatX = @(0);
        _vHatY = @(1);
        _vHatZ = @(0);
        
        _yaw = @(0);
        _pitch = @(0);
        _roll = @(0);

        // TODO: get from preference
        _projectionType = [NSNumber numberWithInt:kPerspectiveProjection];
        _perspectiveProjectionFlag = [NSNumber numberWithBool:YES];
        
        _visibleSurfaceFlag = [NSNumber numberWithBool:NO];
        _useLookAt = [NSNumber numberWithBool:NO];
   }
    return self;
}


@end
