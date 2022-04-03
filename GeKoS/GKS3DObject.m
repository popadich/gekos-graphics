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
    GKSmatrix_3 model_transform;
}

@property (nonatomic, strong) NSNumber* objectID;
@property (nonatomic, strong) NSNumber* hidden;
@property (nonatomic, strong) NSNumber* priority;

@property (nonatomic, strong) NSNumber* transX;
@property (nonatomic, strong) NSNumber* transY;
@property (nonatomic, strong) NSNumber* transZ;
@property (nonatomic, strong) NSNumber* rotX;
@property (nonatomic, strong) NSNumber* rotY;
@property (nonatomic, strong) NSNumber* rotZ;
@property (nonatomic, strong) NSNumber* scaleX;
@property (nonatomic, strong) NSNumber* scaleY;
@property (nonatomic, strong) NSNumber* scaleZ;

@end



@implementation GKS3DObject


- (instancetype)init
{
    GKSmesh_3 *mesh = CubeMesh();
    GKSvector3d loc = GKSMakeVector(0.0, 0.0, 0.0);
    GKSvector3d rot = GKSMakeVector(0.0, 0.0, 0.0);
    GKSvector3d sca = GKSMakeVector(1.0, 1.0, 1.0);
    return ( [self initWithMesh:mesh atLocation:loc withRotation:rot andScale:sca] );
}


- (instancetype)initWithMesh:(GKSmesh_3 *)the_mesh atLocation:(GKSvector3d)location withRotation:(GKSvector3d)rotation andScale:(GKSvector3d)scale;
{
    
    self = [super init];
    if (self) {
        
        [self zeroLocation];
        
        _transX = [NSNumber numberWithDouble:location.crd.x];
        _transY = [NSNumber numberWithDouble:location.crd.y];
        _transZ = [NSNumber numberWithDouble:location.crd.z];

        _rotX = [NSNumber numberWithDouble:rotation.crd.x];
        _rotY = [NSNumber numberWithDouble:rotation.crd.y];
        _rotZ = [NSNumber numberWithDouble:rotation.crd.z];
        
        _scaleX = [NSNumber numberWithDouble:scale.crd.x];
        _scaleY = [NSNumber numberWithDouble:scale.crd.y];
        _scaleZ = [NSNumber numberWithDouble:scale.crd.z];

        
        mesh_ptr = the_mesh;
        dev_coord_ptr = (GKSDCArrPtr)calloc(mesh_ptr->vertnum, sizeof(GKSpoint_2));
        
        [self generateModelTransform];
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
    [self generateModelTransform];
}

- (void)rotateX:(CGFloat)rotFactorX Y:(CGFloat)rotFactorY Z:(CGFloat)rotFactorZ {
    self.rotX = [NSNumber numberWithDouble:rotFactorX];
    self.rotY = [NSNumber numberWithDouble:rotFactorY];
    self.rotZ = [NSNumber numberWithDouble:rotFactorZ];
    [self generateModelTransform];
}

- (void)locateX:(CGFloat)locFactorX Y:(CGFloat)locFactorY Z:(CGFloat)locFactorZ {
    self.transX = [NSNumber numberWithDouble:locFactorX];
    self.transY = [NSNumber numberWithDouble:locFactorY];
    self.transZ = [NSNumber numberWithDouble:locFactorZ];
    [self generateModelTransform];
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
    
//    NSLog(@"mesh: %p",&act.mesh_object);
    
    // transforms
    gks_compute_object(&act);
}

- (void)drawActor
{
    GKSactor act = self.objectActor;
    
    gks_draw_computed_object(&act);
}

- (void)generateModelTransform {
    GKSmatrix_3 transform;
    GKSvector3d scaleVec;
    GKSvector3d rotVec;
    GKSvector3d transVec;
    
    scaleVec = [self scaleVector];
    rotVec = [self rotationVector];
    transVec = [self positionVector];
    
    // Create transform matrix for world object to model space
    gks_create_scaling_matrix_3(scaleVec.crd.x,scaleVec.crd.y,scaleVec.crd.z, transform);
    
    // ORDER MATTERS S x R x T
    gks_accumulate_x_rotation_matrix_3(rotVec.crd.x, transform);
    gks_accumulate_y_rotation_matrix_3(rotVec.crd.y, transform);
    gks_accumulate_z_rotation_matrix_3(rotVec.crd.z, transform);
    gks_accumulate_translation_matrix_3(transVec.crd.x, transVec.crd.y, transVec.crd.z, transform);
    
    gks_matrix_copy_3(transform, model_transform);
}

- (GKSactor)objectActor
{
    GKSactor anActor;
    
    anActor.kind = 0;       // not needed
    anActor.hidden = self.hidden.boolValue;
    
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

    
    //What to do with this
    anActor.mesh_object = *mesh_ptr;
    
    anActor.priority = self.priority.doubleValue;
    anActor.scale_vector = scale;
    anActor.rotate_vector = rotation;
    anActor.translate_vector = position;
    anActor.line_color = line_color;
    anActor.fill_color = fill_color;
    
    anActor.devcoords = dev_coord_ptr;

    gks_copy_matrix_3(model_transform, anActor.model_transform);
    
    return anActor;
}


@end
