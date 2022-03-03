//
//  GKSCameraRep.h
//  GeKoS
//
//  Created by Alex Popadich on 3/2/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKSCameraRep : NSObject

@property (nonatomic, strong) NSNumber* focalLength;
@property (nonatomic, strong) NSNumber* positionX;
@property (nonatomic, strong) NSNumber* positionY;
@property (nonatomic, strong) NSNumber* positionZ;
@property (nonatomic, strong) NSNumber* upX;
@property (nonatomic, strong) NSNumber* upY;
@property (nonatomic, strong) NSNumber* upZ;
@property (nonatomic, strong) NSNumber* dirX;
@property (nonatomic, strong) NSNumber* dirY;
@property (nonatomic, strong) NSNumber* dirZ;


@property (nonatomic, strong) NSNumber* vHatX;
@property (nonatomic, strong) NSNumber* vHatY;
@property (nonatomic, strong) NSNumber* vHatZ;

@property (nonatomic, strong) NSNumber* useLookAt;
@property (nonatomic, strong) NSNumber* yaw;
@property (nonatomic, strong) NSNumber* pitch;
@property (nonatomic, strong) NSNumber* roll;

// TODO: get rid of ambiguity
@property (nonatomic, strong) NSNumber* perspectiveProjectionFlag;
@property (nonatomic, strong) NSNumber* projectionType;

@property (nonatomic, strong) NSNumber* visibleSurfaceFlag;

@end

NS_ASSUME_NONNULL_END
