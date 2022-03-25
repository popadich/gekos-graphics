//
//  GKS3DObjectRep.h
//  gks-cocoa
//
//  Created by Alex Popadich on 6/23/21.
//

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#import "gks/gks.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKS3DObjectRep : NSObject <NSCopying>

@property (nonatomic, strong) NSNumber* objectKind;
@property (nonatomic, strong) NSNumber* transX;
@property (nonatomic, strong) NSNumber* transY;
@property (nonatomic, strong) NSNumber* transZ;
@property (nonatomic, strong) NSNumber* rotX;
@property (nonatomic, strong) NSNumber* rotY;
@property (nonatomic, strong) NSNumber* rotZ;
@property (nonatomic, strong) NSNumber* scaleX;
@property (nonatomic, strong) NSNumber* scaleY;
@property (nonatomic, strong) NSNumber* scaleZ;
@property (nonatomic, strong) NSColor* lineColor;
@property (nonatomic, strong) NSColor* fillColor;


- (id)initWithStructure:(GKSactor)actorStruct;
- (void)scaleX:(CGFloat)scaleFactorX Y:(CGFloat)scaleFactorY Z:(CGFloat)scaleFactorZ;
- (void)rotateX:(CGFloat)rotFactorX Y:(CGFloat)rotFactorY Z:(CGFloat)rotFactorZ;
- (void)locateX:(CGFloat)locFactorX Y:(CGFloat)locFactorY Z:(CGFloat)locFactorZ;
- (GKSvector3d)positionVector;
- (GKSvector3d)rotationVector;
- (GKSvector3d)scaleVector;

@end

NS_ASSUME_NONNULL_END
