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
        [self zeroSettings];
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

- (void)zeroSettings {
    
        if (self) {
            self.upX = @0.0;
            self.upY = @1.0;
            self.upZ = @0.0;
            self.positionX = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefCameraLocX];
            self.positionY = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefCameraLocY];
            self.positionZ = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefCameraLocZ];
            self.dirX = @0.0;
            self.dirY = @0.0;
            self.dirZ = @-1.0;
        
            self.focalLength = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefPerspectiveDistance];
            self.near = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefNearPlaneDistance];
            self.far = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefFarPlaneDistance];
            
            self.roll  = @0.0;
            self.pitch = @0.0;
            self.yaw   = @0.0;
            
            self.lookX = @0.0;
            self.lookY = @0.0;
            self.lookZ = @0.0;
            
            // these property values are typically derived from the ones supplied above
            self.uHatX = @1.0;
            self.uHatY = @0.0;
            self.uHatZ = @0.0;
            
            self.vHatX = @0.0;
            self.vHatY = @1.0;
            self.vHatZ = @0.0;

            
            NSNumber *prType =  [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefProjectionType];
            
            self.projectionType = prType;

        }

}

- (void)cameraSetLookAt:(GKSvector3d)lookAt
{
    self.lookX = [NSNumber numberWithDouble:lookAt.crd.x];
    self.lookY = [NSNumber numberWithDouble:lookAt.crd.y];
    self.lookZ = [NSNumber numberWithDouble:lookAt.crd.z];
}

@end
