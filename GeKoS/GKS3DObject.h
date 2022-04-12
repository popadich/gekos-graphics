//
//  GKS3DObject.h
//  GeKoS
//
//  Created by Alex Popadich on 3/28/22.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#include "gks/gks.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKS3DObject : NSObject



@property (nonatomic, copy) NSColor* lineColor;
@property (nonatomic, copy) NSColor* fillColor;

- (instancetype)initWithMesh:(GKSmesh_3 *)the_mesh atLocation:(GKSvector3d)location withRotation:(GKSvector3d)rot andScale:(GKSvector3d)scale;

- (void)scaleX:(CGFloat)scaleFactorX Y:(CGFloat)scaleFactorY Z:(CGFloat)scaleFactorZ;
- (void)rotateX:(CGFloat)rotFactorX Y:(CGFloat)rotFactorY Z:(CGFloat)rotFactorZ;
- (void)locateX:(CGFloat)locFactorX Y:(CGFloat)locFactorY Z:(CGFloat)locFactorZ;
- (GKSvector3d)positionVector;
- (GKSvector3d)rotationVector;
- (GKSvector3d)scaleVector;


- (GKSactor *)objectActor;

- (void)computeAction;
- (void)drawActor;

// testing
- (GKSmesh_3 *)getMeshPointer;          // for debug, delete when done

@end

NS_ASSUME_NONNULL_END
