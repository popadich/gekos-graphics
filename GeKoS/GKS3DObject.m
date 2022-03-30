//
//  GKS3DObject.m
//  GeKoS
//
//  Created by Alex Popadich on 3/28/22.
//

#import "GKS3DObject.h"

@interface GKS3DObject () {
    GKSobject_3 *mesh_ptr;
}

@end



@implementation GKS3DObject

- (instancetype)initWithKind:(NSNumber *)daKine
{
    self = [super init];
    if (self) {
        _objectKind = daKine;
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

- (instancetype)init
{
    return ( [self initWithKind:[NSNumber numberWithInteger:kCubeKind]] );
}

- (GKSobject_3 *)getMesh
{
    BOOL isCentered = NO;
    GKSobject_3 *mesh_object_ptr = NULL;
    GKSobjectKind kind = self.objectKind.intValue;
    
    if (mesh_ptr != NULL) {
        mesh_object_ptr = mesh_ptr;
    }
    else {
        switch (kind) {
            case kCubeKind:
                mesh_object_ptr = CubeMesh(isCentered);
                break;
            case kSphereKind:
                mesh_object_ptr = SphereMesh(isCentered);
                break;
            case kPyramidKind:
                mesh_object_ptr = PyramidMesh(isCentered);
                break;
            case kHouseKind:
                mesh_object_ptr = HouseMesh(isCentered);
                break;
            default:
                break;
        }
        mesh_ptr = mesh_object_ptr;
    }
    

    return mesh_object_ptr;
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

- (void)computeAction
{
    
}

- (void)drawActor
{
    
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
    GKSobject_3 *mesh_ptr = self.getMesh;
    anActor.mesh_object = *mesh_ptr;
    
    anActor.priority = self.priority.doubleValue;
    anActor.scale_vector = scale;
    anActor.rotate_vector = rotation;
    anActor.translate_vector = position;
    anActor.line_color = line_color;
    anActor.fill_color = fill_color;
    
    
    return anActor;
}


@end
