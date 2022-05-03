//
//  GKS3DObjectRep.m
//  gks-cocoa
//
//  Created by Alex Popadich on 6/23/21.
//

#import "GKS3DObjectRep.h"

#import "GKS3DActor.h"



@implementation GKS3DObjectRep

- (instancetype)init
{
    GKSvector3d loc = GKSMakeVector(0.0, 0.0, 0.0);
    GKSvector3d rot = GKSMakeVector(0.0, 0.0, 0.0);
    GKSvector3d sca = GKSMakeVector(1.0, 1.0, 1.0);
    return ( [self initWithKind:kCubeKind atLocation:loc withRotation:rot andScale:sca] );
    
}


- (instancetype)initWithKind:(GKSkind)kind atLocation:(GKSvector3d)location withRotation:(GKSvector3d)rotation andScale:(GKSvector3d)scale;
{
    
    self = [super init];
    if (self) {
        
        [self zeroLocation];
        
        _kind = [NSNumber numberWithInt:kind];
        
        _locX = [NSNumber numberWithDouble:location.crd.x];
        _locY = [NSNumber numberWithDouble:location.crd.y];
        _locZ = [NSNumber numberWithDouble:location.crd.z];

        _rotX = [NSNumber numberWithDouble:rotation.crd.x];
        _rotY = [NSNumber numberWithDouble:rotation.crd.y];
        _rotZ = [NSNumber numberWithDouble:rotation.crd.z];
        
        _scaleX = [NSNumber numberWithDouble:scale.crd.x];
        _scaleY = [NSNumber numberWithDouble:scale.crd.y];
        _scaleZ = [NSNumber numberWithDouble:scale.crd.z];
        
        // TODO: better defaults
        _lineColor = [NSColor greenColor];
        _fillColor = [NSColor greenColor];
        
        _actorObject = nil;
    }
    return self;
}


- (void)zeroLocation
{
    _name = @"noname";
    _hidden = [NSNumber numberWithBool:NO];
    _objectRepID = @0;
    _priority = @0;
    
    _locX = [NSNumber numberWithDouble:0.0];
    _locY = [NSNumber numberWithDouble:0.0];
    _locZ = [NSNumber numberWithDouble:0.0];
    _scaleX = [NSNumber numberWithDouble:1.0];
    _scaleY = [NSNumber numberWithDouble:1.0];
    _scaleZ = [NSNumber numberWithDouble:1.0];
    _rotX = [NSNumber numberWithDouble:0.0];
    _rotY = [NSNumber numberWithDouble:0.0];
    _rotZ = [NSNumber numberWithDouble:0.0];
    
    // TODO: better defaults
    _lineColor = [NSColor greenColor];
    _fillColor = [NSColor greenColor];

}


- (GKSvector3d)positionVector
{
    GKSvector3d pos;
    pos = GKSMakeVector([self.locX doubleValue], [self.locY doubleValue], [self.locZ doubleValue]);
    return pos;
}

- (GKSvector3d)rotationVector
{
    GKSvector3d rot;
    GKSfloat degreesAroundX = self.rotX.doubleValue;
    GKSfloat degreesAroundY = self.rotY.doubleValue;
    GKSfloat degreesAroundZ = self.rotZ.doubleValue;
    
    rot = GKSMakeVector(degreesAroundX * DEG_TO_RAD, degreesAroundY * DEG_TO_RAD, degreesAroundZ * DEG_TO_RAD);
    return rot;
}

- (GKSvector3d)scaleVector
{
    GKSvector3d rot;
    rot = GKSMakeVector([self.scaleX doubleValue], [self.scaleY doubleValue], [self.scaleZ doubleValue]);
    return rot;
}



// MARK: NSCopying protocol
- (id)copyWithZone:(NSZone *)zone
{
    GKS3DObjectRep *another = [[GKS3DObjectRep allocWithZone: zone] init];;
    another.kind = self.kind;
    another.hidden = self.hidden;
    another.priority = self.priority;
    another.objectRepID = self.objectRepID;
    another.locX = self.locX;
    another.locY = self.locY;
    another.locZ = self.locZ;
    another.scaleX = self.scaleX;
    another.scaleY = self.scaleY;
    another.scaleZ = self.scaleZ;
    another.rotX = self.rotX;
    another.rotY = self.rotY;
    another.rotZ = self.rotZ;
    another.lineColor = self.lineColor;
    another.fillColor = self.fillColor;
    
    return another;
}


- (void)scaleX:(CGFloat)scaleFactorX Y:(CGFloat)scaleFactorY Z:(CGFloat)scaleFactorZ {
    self.scaleX = [NSNumber numberWithDouble:scaleFactorX];
    self.scaleY = [NSNumber numberWithDouble:scaleFactorY];
    self.scaleZ = [NSNumber numberWithDouble:scaleFactorZ];
}

- (void)rotateX:(CGFloat)rotFactorX Y:(CGFloat)rotFactorY Z:(CGFloat)rotFactorZ {
    self.rotX = [NSNumber numberWithDouble:rotFactorX];
    self.rotY = [NSNumber numberWithDouble:rotFactorY];
    self.rotZ = [NSNumber numberWithDouble:rotFactorZ];
}

- (void)locateX:(CGFloat)locFactorX Y:(CGFloat)locFactorY Z:(CGFloat)locFactorZ {
    self.locX = [NSNumber numberWithDouble:locFactorX];
    self.locY = [NSNumber numberWithDouble:locFactorY];
    self.locZ = [NSNumber numberWithDouble:locFactorZ];
}


- (NSString *)description
{
    NSString *desc = [NSString stringWithFormat:@"%.2f  %.2f  %.2f", self.locX.floatValue, self.locY.floatValue, self.locZ.floatValue];
    return desc;
}


@end
