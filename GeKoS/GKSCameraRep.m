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
@property (nonatomic, strong) NSNumber* uHatX;
@property (nonatomic, strong) NSNumber* uHatY;
@property (nonatomic, strong) NSNumber* uHatZ;

@end

@implementation GKSCameraRep

- (instancetype)init
{
    self = [super init];
    if (self) {
        _focalLength = [NSNumber numberWithFloat:1.0];
        _upX = [NSNumber numberWithDouble:0.0];
        _upY = [NSNumber numberWithDouble:1.0];
        _upZ = [NSNumber numberWithDouble:0.0];

        _positionX = [NSNumber numberWithDouble:0.0];
        _positionY = [NSNumber numberWithDouble:0.0];
        _positionZ = [NSNumber numberWithDouble:1.0];

        _lookX = @0.0;
        _lookY = @0.0;
        _lookZ = @0.0;
        
        _yaw = @0.0;
        _pitch = @0.0;
        _roll = @0.0;
        
        _projectionType = [NSNumber numberWithInteger:kPerspective];

        // these property values are typically derived from the ones supplied above
        _uHatX = @1.0;
        _uHatY = @0.0;
        _uHatZ = @0.0;
        
        _vHatX = @0.0;
        _vHatY = @1.0;
        _vHatZ = @0.0;

        _dirX = [NSNumber numberWithDouble:0.0];
        _dirY = [NSNumber numberWithDouble:0.0];
        _dirZ = [NSNumber numberWithDouble:-1.0];
        
        _near = @0.0;
        _far =  @0.0;

   }
    
    return self;
}


- (GKSvector3d)positionVector
{
    GKSvector3d pos_vector = GKSMakeVector([self.positionX doubleValue], [self.positionY doubleValue], [self.positionZ doubleValue]);
    return pos_vector;
}

- (GKSvector3d)directionVector
{
    GKSvector3d dir_vector = GKSMakeVector([self.dirX doubleValue], [self.dirY doubleValue], [self.dirZ doubleValue]);
    return dir_vector;
}

- (void)cameraSetLook:(GKSvector3d)lookAt
{
    self.lookX = [NSNumber numberWithDouble:lookAt.crd.x];
    self.lookY = [NSNumber numberWithDouble:lookAt.crd.y];
    self.lookZ = [NSNumber numberWithDouble:lookAt.crd.z];
}

@end
