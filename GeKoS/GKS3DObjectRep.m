//
//  GKS3DObjectRep.m
//  gks-cocoa
//
//  Created by Alex Popadich on 6/23/21.
//

#import "GKS3DObjectRep.h"


@implementation GKS3DObjectRep


- (id)initWithStructure:(Actor)actorStruct
{
    self = [super init];
    if (self) {
        _objectKind = [NSNumber numberWithInteger:actorStruct.kind];
        _scaleX = [NSNumber numberWithDouble:actorStruct.scaleVector.crd.x];
        _scaleY = [NSNumber numberWithDouble:actorStruct.scaleVector.crd.y];
        _scaleZ = [NSNumber numberWithDouble:actorStruct.scaleVector.crd.z];
        _rotX = [NSNumber numberWithDouble:actorStruct.rotateVector.crd.x];
        _rotY = [NSNumber numberWithDouble:actorStruct.rotateVector.crd.y];
        _rotZ = [NSNumber numberWithDouble:actorStruct.rotateVector.crd.z];
        _transX = [NSNumber numberWithDouble:actorStruct.translateVector.crd.x];
        _transY = [NSNumber numberWithDouble:actorStruct.translateVector.crd.y];
        _transZ = [NSNumber numberWithDouble:actorStruct.translateVector.crd.z];
        _lineColor = [NSColor greenColor];
        _fillColor = [NSColor lightGrayColor];
    }
    return self;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        _objectKind = [NSNumber numberWithInt:1];
        _transX = [NSNumber numberWithDouble:0.0];
        _transY = [NSNumber numberWithDouble:0.0];
        _transZ = [NSNumber numberWithDouble:0.0];
        _scaleX = [NSNumber numberWithDouble:1.0];
        _scaleY = [NSNumber numberWithDouble:1.0];
        _scaleZ = [NSNumber numberWithDouble:1.0];
        _rotX = [NSNumber numberWithDouble:0.0];
        _rotY = [NSNumber numberWithDouble:0.0];
        _rotZ = [NSNumber numberWithDouble:0.0];
        _lineColor = [NSColor greenColor];
        _fillColor = [NSColor lightGrayColor];
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
    rot = GKSMakeVector([self.rotX doubleValue], [self.rotY doubleValue], [self.rotZ doubleValue]);
    return rot;
}

- (GKSvector3d)scaleVector
{
    GKSvector3d rot;
    rot = GKSMakeVector([self.scaleX doubleValue], [self.scaleY doubleValue], [self.scaleZ doubleValue]);
    return rot;
}



// In the implementation
-(id)copyWithZone:(NSZone *)zone
{
    GKS3DObjectRep *another = [[GKS3DObjectRep allocWithZone: zone] init];;
//    another.objectKind = [_objectKind copyWithZone: zone];
//    another.objectKind = _objectKind;
    another.objectKind = self.objectKind;
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
