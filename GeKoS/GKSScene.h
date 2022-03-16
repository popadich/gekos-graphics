//
//  GKSScene.h
//  gks-cocoa
//
//  Created by Alex Popadich on 7/31/21.
//

#import <Foundation/Foundation.h>
#import "GKS3DObjectRep.h"
#import "GKSCameraRep.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKSScene : NSObject

- (instancetype)initWithCamera:(GKSCameraRep *)aCamera;

- (void) addObjectRep:(GKS3DObjectRep*) anObject3D;

@property (nonatomic,strong) GKSCameraRep* camera;

@property (nonatomic,strong) NSNumber* worldVolumeMinX;
@property (nonatomic,strong) NSNumber* worldVolumeMinY;
@property (nonatomic,strong) NSNumber* worldVolumeMinZ;
@property (nonatomic,strong) NSNumber* worldVolumeMaxX;
@property (nonatomic,strong) NSNumber* worldVolumeMaxY;
@property (nonatomic,strong) NSNumber* worldVolumeMaxZ;

@property (nonatomic,strong) NSColor* worldBackColor;
@property (nonatomic,strong) NSColor* worldLineColor;
@property (nonatomic,strong) NSColor* worldFillColor;



@end

NS_ASSUME_NONNULL_END
