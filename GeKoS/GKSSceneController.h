//
//  GKSScene.h
//  gks-cocoa
//
//  Created by Alex Popadich on 7/31/21.
//

#import <Foundation/Foundation.h>
#import "GKS3DActor.h"
#import "GKS3DObjectRep.h"
#import "GKSSceneRep.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKSSceneController : NSObject

@property (strong) GKSSceneRep *scene;




- (void)setFrustumCulling:(BOOL)flag;

- (void)add3DObjectRep:(GKS3DObjectRep *)object3DRep;

- (void)deleteLastObject;

- (void)transformAllObjects;

- (void)setWorldVolumeG;


@end

NS_ASSUME_NONNULL_END
