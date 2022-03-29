//
//  GKSScene.h
//  gks-cocoa
//
//  Created by Alex Popadich on 7/31/21.
//

#import <Foundation/Foundation.h>
#import "GKS3DObject.h"
#import "GKSCameraRep.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKSScene : NSObject

@property (nonatomic, strong) NSMutableArray* objectList;


@property (nonatomic,strong) GKSCameraRep* camera;

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


- (instancetype)initWithCamera:(GKSCameraRep *)aCamera;
- (void)add3DObject:(GKS3DObject*) anObject3D;


@end

NS_ASSUME_NONNULL_END
