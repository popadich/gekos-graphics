//
//  GKSCameraRep.m
//  GeKoS
//
//  Created by Alex Popadich on 3/2/22.
//

#import "GKSCameraRep.h"
#import "GKSConstants.h"

@interface GKSCameraRep () {

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
        
        _vHatX = @0.0;
        _vHatY = @1.0;
        _vHatZ = @0.0;
        
        _yaw = @0.0;
        _pitch = @0.0;
        _roll = @0.0;

        _lookX = @0.0;
        _lookY = @0.0;
        _lookZ = @0.0;
        
        // TODO: get from preference
        _projectionType = [NSNumber numberWithInteger:kOrthogonal];
        
        _visibleSurfaceFlag = [NSNumber numberWithBool:NO];

   }
    return self;
}


@end
