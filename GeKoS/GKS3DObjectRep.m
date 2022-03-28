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

- (GKSactor)objectActor
{
    GKSactor anActor;

    
    GKSvector3d position = [self positionVector];
    GKSvector3d rotation = [self rotationVector];
    GKSvector3d scale = [self scaleVector];
    
    CGFloat r,g,b,a;
    NSColor* theColor = self.lineColor;
    [theColor getRed:&r green:&g blue:&b alpha:&a];
    GKScolor line_color = {r,g,b,a};
    theColor = self.fillColor;
    [theColor getRed:&r green:&g blue:&b alpha:&a];
    GKScolor fill_color = {r,g,b,a};
    
    anActor.kind = self.objectKind.intValue;
    anActor.hidden = self.hidden.boolValue;
    
    //What to do with this
    //anActor.mesh_object = *mesh_object_ptr;
    
    anActor.priority = self.priority.doubleValue;
    anActor.scale_vector = scale;
    anActor.rotate_vector = rotation;
    anActor.translate_vector = position;
    anActor.line_color = line_color;
    anActor.fill_color = fill_color;
    
    
    return anActor;
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
