//
//  GKSSceneRep.h
//  GeKoS
//
//  Created by Alex Popadich on 4/19/22.
//

#import <Foundation/Foundation.h>
#include "gks/gks_types.h"

NS_ASSUME_NONNULL_BEGIN

@class GKS3DObjectRep;

@interface GKSSceneRep : NSObject

@property (assign) GKScontext3DPtr context;
@property (nonatomic, strong) NSMutableArray* toObject3DReps;

@property (strong) NSString *title;
@property (strong) NSString *kind;

@property (nonatomic,strong) NSNumber* worldVolumeMinX;
@property (nonatomic,strong) NSNumber* worldVolumeMinY;
@property (nonatomic,strong) NSNumber* worldVolumeMinZ;
@property (nonatomic,strong) NSNumber* worldVolumeMaxX;
@property (nonatomic,strong) NSNumber* worldVolumeMaxY;
@property (nonatomic,strong) NSNumber* worldVolumeMaxZ;

- (instancetype)initWithContext:(GKScontext3D *)contextPtr;

- (void)add3DObjectRep:(GKS3DObjectRep *)object3DRep withMesh:(GKSmesh_3 *)aMesh;
- (void)deleteLast3DObjectRep;

@end

NS_ASSUME_NONNULL_END
