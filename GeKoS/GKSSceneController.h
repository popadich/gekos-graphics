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

@property (strong) GKSSceneRep *scene;
@property (nonatomic, strong) GKSCameraRep* camera;
@property (strong) GKSMeshMonger *monger;

@property (nonatomic, strong) NSMutableArray* objectActors;
@property (assign) GKScontext3DPtr context;



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


- (instancetype)initWithCamera:(GKSCameraRep *)aCamera andScene:(GKSSceneRep *)scene;

- (void)add3DObjectRep:(GKS3DObjectRep *)object3DRep;

- (void)deleteLast3DObject;

- (void)transformAllObjects;

- (void)setTheWorldVolume;


@end

NS_ASSUME_NONNULL_END
