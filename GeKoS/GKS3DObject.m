//
//  GKS3DObject.m
//  GeKoS
//
//  Created by Alex Popadich on 3/28/22.
//

#import "GKS3DObject.h"

@interface GKS3DObject () {
    GKSactor the_actor;
    GKSmesh_3 *mesh_ptr;
    GKSDCArrPtr dev_coord_ptr;
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
        
        the_actor.kind = 0;       // not needed
        the_actor.hidden = false;
        the_actor.priority = 0.0;
        the_actor.scale_vector = scale;
        the_actor.rotate_vector = rotation;
        the_actor.translate_vector = location;
        
        GKScolor line_color = {0.0, 1.0, 0.0, 1.0};
        GKScolor fill_color = {0.0, 1.0, 0.0, 1.0};
        the_actor.line_color = line_color;
        the_actor.fill_color = fill_color;
        
        mesh_ptr = the_mesh;
        dev_coord_ptr = (GKSDCArrPtr)calloc(mesh_ptr->vertnum, sizeof(GKSpoint_2));
        
        the_actor.mesh_object = *mesh_ptr;
        the_actor.dev_coords = dev_coord_ptr;
        
        gks_actor_transform_to_world(&the_actor);
        
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

- (void)setLineColor:(NSColor *)lineColor
{
    CGFloat r,g,b,a;
    [lineColor getRed:&r green:&g blue:&b alpha:&a];
    GKScolor line_color = {r,g,b,a};
    the_actor.line_color = line_color;

    _lineColor = lineColor;
}

- (void)setFillColor:(NSColor *)fillColor
{
    CGFloat r,g,b,a;
    [fillColor getRed:&r green:&g blue:&b alpha:&a];
    GKScolor fill_color = {r,g,b,a};
    the_actor.fill_color = fill_color;
    
    _fillColor = fillColor;
}

- (void)computeActorInContext:(GKScontext3DPtr)context
{
    gks_pipeline_object_actor(context, &the_actor);
}

- (void)drawActor
{
    gks_draw_piped_actor(&the_actor);
    
}


- (GKSint)getPolygonCount
{
    GKSint polynum = 0;
    polynum = mesh_ptr->polynum;
    return polynum;
}

- (GKSint)getVertexCount
{
    GKSint vertnum = 0;
    vertnum = mesh_ptr->vertnum;
    return vertnum;
}


@end
