//
//  GKS3DObjectRep.m
//  gks-cocoa
//
//  Created by Alex Popadich on 6/23/21.
//

#import "GKS3DObjectRep.h"

#import "GKS3DObject.h"


@interface GKS3DObjectRep () {
    GKSmesh_3 *mesh;

}
@end


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
        
        _actorObject = nil;
    }
    return self;
}


- (instancetype)initWithKind:(GKSint)kind atLocation:(GKSvector3d)location withRotation:(GKSvector3d)rotation andScale:(GKSvector3d)scale;
{
    
    self = [super init];
    if (self) {
        
        [self zeroLocation];
        
        _objectKind = [NSNumber numberWithInt:kind];
        
        _transX = [NSNumber numberWithDouble:location.crd.x];
        _transY = [NSNumber numberWithDouble:location.crd.y];
        _transZ = [NSNumber numberWithDouble:location.crd.z];

        _rotX = [NSNumber numberWithDouble:rotation.crd.x];
        _rotY = [NSNumber numberWithDouble:rotation.crd.y];
        _rotZ = [NSNumber numberWithDouble:rotation.crd.z];
        
        _scaleX = [NSNumber numberWithDouble:scale.crd.x];
        _scaleY = [NSNumber numberWithDouble:scale.crd.y];
        _scaleZ = [NSNumber numberWithDouble:scale.crd.z];
        
        // TODO: better defaults
        _lineColor = [NSColor greenColor];
        _fillColor = [NSColor greenColor];
    }
    return self;
}


- (void)zeroLocation
{
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
    self.transX = [NSNumber numberWithDouble:locFactorX];
    self.transY = [NSNumber numberWithDouble:locFactorY];
    self.transZ = [NSNumber numberWithDouble:locFactorZ];
}

- (void)drawActor
{
    [self.actorObject drawActor];
}


- (GKSint)getPolygonCount
{
    GKSint polynum = 0;
    GKS3DObject *actor = self.actorObject;
    polynum = actor.getMeshPointer->polynum;
    return polynum;
}

- (GKSint)getVertexCount
{
    GKSint vertnum = 0;
    GKS3DObject *actor = self.actorObject;
    vertnum = actor.getMeshPointer->vertnum;
    return vertnum;
}

- (void)storeMesh:(GKSmesh_3 *)meshPtr
{
    mesh = meshPtr;
}

- (GKSmesh_3 *)getMesh
{
    return mesh;
}

@end
