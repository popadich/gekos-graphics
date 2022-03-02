//
//  GKSCameraRep.h
//  GeKoS
//
//  Created by Alex Popadich on 3/2/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKSCameraRep : NSObject

@property (nonatomic, strong) NSNumber* perspectiveDistance;
@property (nonatomic, strong) NSNumber* positionX;
@property (nonatomic, strong) NSNumber* positionY;
@property (nonatomic, strong) NSNumber* positionZ;
@property (nonatomic, strong) NSNumber* upX;
@property (nonatomic, strong) NSNumber* upY;
@property (nonatomic, strong) NSNumber* upZ;
@property (nonatomic, strong) NSNumber* dirX;
@property (nonatomic, strong) NSNumber* dirY;
@property (nonatomic, strong) NSNumber* dirZ;
@property (nonatomic, strong) NSNumber* useLookAt;

// TODO: get rid of ambiguity
@property (nonatomic, strong) NSNumber* perspectiveProjectionFlag;
@property (nonatomic, strong) NSNumber* projectionType;

@end

NS_ASSUME_NONNULL_END
