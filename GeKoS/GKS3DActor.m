//
//  GKS3DActor.m
//  GeKoS
//
//  Created by Alex Popadich on 3/28/22.
//

#import "GKS3DActor.h"

@interface GKS3DActor () {
    GKSactor the_actor;
    GKSDCArrPtr dev_coord_ptr;
}

@property (nonatomic, strong) NSUUID* actorID;
@property (nonatomic, strong) NSNumber* kind;
@property (nonatomic, strong) NSNumber* hidden;
@property (nonatomic, strong) NSNumber* priority;

@property (assign) GKSvector3d location_vec;
@property (assign) GKSvector3d rotation_vec;
@property (assign) GKSvector3d scale_vec;

@end



@implementation GKS3DActor


- (instancetype)init
{
    GKSmesh_3 *mesh = CubeMesh();
    GKSvector3d loc = GKSMakeVector(0.0, 0.0, 0.0);
    GKSvector3d rot = GKSMakeVector(0.0, 0.0, 0.0);
    GKSvector3d sca = GKSMakeVector(1.0, 1.0, 1.0);
    _lineColor = [NSColor greenColor];
    
    return ( [self initWithMesh:mesh ofKind:@(kCubeKind) atLocation:loc withRotation:rot andScale:sca] );
}


- (instancetype)initWithMesh:(GKSmesh_3 *)the_mesh ofKind:(NSNumber *)kind atLocation:(GKSvector3d)location withRotation:(GKSvector3d)rotation andScale:(GKSvector3d)scale;
{
    
    self = [super init];
    if (self) {
                
        _hidden = [NSNumber numberWithBool:NO];
        _kind = kind;
        _priority = @0;
        _actorID = [NSUUID UUID];
        
        // TODO: better defaults
        _lineColor = [NSColor greenColor];
        _fillColor = [NSColor greenColor];
        
        _location_vec = location;
        _rotation_vec = rotation;
        _scale_vec = scale;
        
        the_actor.kind = kind.intValue;
        the_actor.hidden = false;
        the_actor.priority = 0.0;
        the_actor.scale_vector = scale;
        the_actor.rotate_vector = rotation;
        the_actor.translate_vector = location;
        
        GKScolor line_color = {0.0, 1.0, 0.0, 1.0};
        GKScolor fill_color = {0.0, 1.0, 0.0, 1.0};
        the_actor.line_color = line_color;
        the_actor.fill_color = fill_color;
        
        // TODO: make a seperate setter
        _mesh_ptr = the_mesh;
        dev_coord_ptr = (GKSDCArrPtr)calloc(the_mesh->vertnum, sizeof(GKSpoint_2));
        
        the_actor.mesh_object = *the_mesh;
        the_actor.dev_coords = dev_coord_ptr;
        
        [self stageUpdateActor];
        
    }
    return self;
}


- (void)setPosition:(GKSvector3d)location
{
    self.location_vec = location;
}

- (void)setRotation:(GKSvector3d)rotation
{
    self.rotation_vec = rotation;
}

- (void)setScaling:(GKSvector3d)scale
{
    self.scale_vec = scale;
}

- (GKSvector3d)positionVector
{
    GKSvector3d pos;
    pos = self.location_vec;
    return pos;
}

- (GKSvector3d)rotationVector
{
    GKSvector3d rot;
    rot = self.rotation_vec;
    return rot;
}

- (GKSvector3d)scaleVector
{
    GKSvector3d sca;
    sca = self.scale_vec;
    return sca;
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

- (void)stageUpdateActor
{
    the_actor.scale_vector = self.scaleVector;
    the_actor.rotate_vector = self.rotationVector;
    the_actor.translate_vector = self.positionVector;

    gks_actor_transform_to_world(&the_actor);
}


- (void)stageRemoveActor
{
    
}

- (void)computeActorInContext:(GKScontext3DPtr)context
{
    gks_pipeline_object_actor(context, &the_actor);
}

- (void)drawActor
{
    gks_draw_piped_actor(&the_actor);
    
}

- (NSDictionary *)actorAsDictionary
{
    GKSfloat locX = self.location_vec.crd.x;
    GKSfloat locY = self.location_vec.crd.y;
    GKSfloat locZ = self.location_vec.crd.z;
    GKSfloat rotX = self.rotationVector.crd.x;
    GKSfloat rotY = self.rotationVector.crd.y;
    GKSfloat rotZ = self.rotationVector.crd.z;
    GKSfloat scaX = self.scaleVector.crd.x;
    GKSfloat scaY = self.scaleVector.crd.y;
    GKSfloat scaZ = self.scaleVector.crd.z;
    
    NSDictionary *actDict = @{ @"posX"    : @(locX),
                               @"posY"    : @(locY),
                               @"posZ"    : @(locZ),
                               @"rotX"    : @(rotX),
                               @"rotY"    : @(rotY),
                               @"rotZ"    : @(rotZ),
                               @"scaleX"    : @(scaX),
                               @"scaleY"    : @(scaY),
                               @"scaleZ"    : @(scaZ),
                               @"kind"    : self.kind
    };
    
    return actDict;
}

- (GKSint)getPolygonCount
{
    GKSint polynum = 0;
    polynum = self.mesh_ptr->polynum;
    return polynum;
}

- (GKSint)getVertexCount
{
    GKSint vertnum = 0;
    vertnum = self.mesh_ptr->vertnum;
    return vertnum;
}


@end
