//
//  GKSSceneRep.h
//  GeKoS
//
//  Created by Alex Popadich on 4/19/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class GKS3DObjectRep;

@interface GKSSceneRep : NSObject

@property (nonatomic, strong) NSMutableArray* toObject3DReps;

- (void)add3DObjectRep:(GKS3DObjectRep *)object3DRep;
- (void)deleteLast3DObjectRep;

@end

NS_ASSUME_NONNULL_END
