//
//  GKS3DObjectRep.m
//  gks-cocoa
//
//  Created by Alex Popadich on 6/23/21.
//

#import "GKS3DObjectRep.h"


@implementation GKS3DObjectRep

- (instancetype)init
{
    self = [super init];
    if (self) {
        _objectKind = [NSNumber numberWithInteger:kCubeKind];
        _hidden = [NSNumber numberWithBool:NO];
        _objectID = @0;
        _priority = @0;
        
        _transX = [NSNumber numberWithDouble:0.0];
        _transY = [NSNumber numberWithDouble:0.0];
        _transZ = [NSNumber numberWithDouble:0.0];
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
    return self;
}


- (GKSvector3d)positionVector
{
    GKSvector3d pos;
    pos = GKSMakeVector([self.transX doubleValue], [self.transY doubleValue], [self.transZ doubleValue]);
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
    another.objectKind = self.objectKind;
    another.hidden = self.hidden;
    another.priority = self.priority;
    another.objectID = self.objectID;
    another.transX = self.transX;
    another.transY = self.transY;
    another.transZ = self.transZ;
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


@end
