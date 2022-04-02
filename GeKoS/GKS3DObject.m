//
//  GKS3DObject.m
//  GeKoS
//
//  Created by Alex Popadich on 3/28/22.
//

#import "GKS3DObject.h"

@interface GKS3DObject () {
    GKSmesh_3 *mesh_ptr;
    GKSDCArrPtr dev_coord_ptr;
}

@end



@implementation GKS3DObject


- (instancetype)init
{
    GKSmesh_3 *mesh = CubeMesh();
    return ( [self initWithMesh:mesh ofKind:[NSNumber numberWithInt:kCubeKind]] );
}


- (instancetype)initWithMesh:(GKSmesh_3 *)the_mesh ofKind:(NSNumber *)daKine
{
    
    self = [super init];
    if (self) {
        _objectKind = daKine;
        
        [self zeroLocation];
        
        mesh_ptr = the_mesh;
        dev_coord_ptr = (GKSDCArrPtr)calloc(mesh_ptr->vertnum, sizeof(GKSpoint_2));
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
    mesh_ptr = NULL;
    dev_coord_ptr = NULL;
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
    GKSactor act = self.objectActor;
    
    // transforms
    gks_compute_object(&act);
}

- (void)drawActor
{
    GKSactor act = self.objectActor;
    
    gks_draw_computed_object(&act);
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

    anActor.mesh_object = *mesh_ptr;
    
    anActor.priority = self.priority.doubleValue;
    anActor.scale_vector = scale;
    anActor.rotate_vector = rotation;
    anActor.translate_vector = position;
    anActor.line_color = line_color;
    anActor.fill_color = fill_color;
    
    anActor.devcoords = dev_coord_ptr;
    
    
    GKSvector3d scaleVec;
    GKSvector3d rotVec;
    GKSvector3d transVec;
    
    scaleVec = anActor.scale_vector;
    rotVec = anActor.rotate_vector;
    transVec = anActor.translate_vector;
    
    // Create transform matrix for world object to model space
    gks_create_scaling_matrix_3(scaleVec.crd.x,scaleVec.crd.y,scaleVec.crd.z, anActor.model_transform);
    
    // ORDER MATTERS S x R x T
    gks_accumulate_x_rotation_matrix_3(rotVec.crd.x, anActor.model_transform);
    gks_accumulate_y_rotation_matrix_3(rotVec.crd.y, anActor.model_transform);
    gks_accumulate_z_rotation_matrix_3(rotVec.crd.z, anActor.model_transform);
    gks_accumulate_translation_matrix_3(transVec.crd.x, transVec.crd.y, transVec.crd.z, anActor.model_transform);
    
    return anActor;
}


@end
