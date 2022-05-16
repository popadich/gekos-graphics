//
//  GKSSceneRep.h
//  GeKoS
//
//  Created by Alex Popadich on 4/19/22.
//

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#include "gks_types.h"
#import "GKS3DActor.h"
#import "GeKoS+CoreDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@class GKSCameraRep;


@interface GKSSceneRep : NSObject

@property (assign) GKScontext3DPtr context;
//@property (strong) GKSCameraRep *toCamera;
@property (strong) NSMutableSet* toActors;

@property (strong) NSString *title;

@property (strong) NSNumber* worldVolumeMinX;
@property (strong) NSNumber* worldVolumeMinY;
@property (strong) NSNumber* worldVolumeMinZ;
@property (strong) NSNumber* worldVolumeMaxX;
@property (strong) NSNumber* worldVolumeMaxY;
@property (strong) NSNumber* worldVolumeMaxZ;

// TODO: verify this is used
@property (nonatomic,strong) NSColor* worldBackColor;
@property (nonatomic,strong) NSColor* worldLineColor;
@property (nonatomic,strong) NSColor* worldFillColor;

- (instancetype)initWithContext:(GKScontext3D *)contextPtr;
- (GKSlimits_3 *)worldVolumeLimits;

- (void)stageActor:(GKS3DActor *)actorObj;

@end

NS_ASSUME_NONNULL_END
