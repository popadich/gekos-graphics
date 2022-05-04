//
//  GKSScene.h
//  gks-cocoa
//
//  Created by Alex Popadich on 7/31/21.
//

#import <Foundation/Foundation.h>
#import "GKSSceneRep.h"
#import "ActorEntity+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKSSceneController : NSObject

@property (strong) GKSSceneRep *scene;

- (void)setFrustumCulling:(BOOL)flag;

- (void)transformAllObjects;

- (void)setWorldVolumeG;


@end

NS_ASSUME_NONNULL_END
