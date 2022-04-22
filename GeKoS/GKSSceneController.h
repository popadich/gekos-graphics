//
//  GKSScene.h
//  gks-cocoa
//
//  Created by Alex Popadich on 7/31/21.
//

#import <Foundation/Foundation.h>
#import "GKS3DObject.h"
#import "GKS3DObjectRep.h"
#import "GKSCameraRep.h"
#import "GKSSceneRep.h"
#import "GKSMeshMonger.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKSSceneController : NSObject

@property (strong) NSMutableArray *scenes;
@property (strong) GKSMeshMonger *monger;


@property (nonatomic,strong) NSNumber* worldVolumeMinX;
@property (nonatomic,strong) NSNumber* worldVolumeMinY;
@property (nonatomic,strong) NSNumber* worldVolumeMinZ;
@property (nonatomic,strong) NSNumber* worldVolumeMaxX;
@property (nonatomic,strong) NSNumber* worldVolumeMaxY;
@property (nonatomic,strong) NSNumber* worldVolumeMaxZ;

// TODO: verify this is used
@property (nonatomic,strong) NSColor* worldBackColor;
@property (nonatomic,strong) NSColor* worldLineColor;
@property (nonatomic,strong) NSColor* worldFillColor;


- (void)setFrustumCulling:(BOOL)flag;

- (void)add3DObjectRep:(GKS3DObjectRep *)object3DRep;
- (void)addSceneRep:(GKSSceneRep *)sceneRep;
- (GKSSceneRep *)getCurrentSceneRep;

- (void)deleteLastObject;

- (void)transformAllObjects;

- (void)setWorldVolumeG;


@end

NS_ASSUME_NONNULL_END
