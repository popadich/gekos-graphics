//
//  GKS3DActor.h
//  GeKoS
//
//  Created by Alex Popadich on 3/28/22.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#include "gks.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKS3DActor : NSObject



@property (nonatomic, copy) NSColor* lineColor;
@property (nonatomic, copy) NSColor* fillColor;
@property (assign) GKSmesh_3* mesh_ptr;

- (instancetype)initWithMesh:(GKSmesh_3 *)the_mesh ofKind:(NSNumber *)kind atLocation:(GKSvector3d)location withRotation:(GKSvector3d)rot andScale:(GKSvector3d)scale;

- (GKSvector3d)positionVector;
- (GKSvector3d)rotationVector;
- (GKSvector3d)scaleVector;
- (void)setScaling:(GKSvector3d)scale;
- (void)setRotation:(GKSvector3d)rotation;
- (void)setPosition:(GKSvector3d)location;

- (NSDictionary *)actorAsDictionary;

- (GKSint)getPolygonCount;
- (GKSint)getVertexCount;

- (void)stageUpdateActor;
- (void)stageRemoveActor;
- (void)computeActorInContext:(GKScontext3DPtr)context;
- (void)drawActor;



@end

NS_ASSUME_NONNULL_END
