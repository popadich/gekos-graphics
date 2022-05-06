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
@property (strong) NSMutableDictionary *actorWhitePages;

- (void)setFrustumCulling:(BOOL)flag;

- (void)castSetOfActors:(NSSet *)actors;

- (void)transformAllObjects;

- (void)setWorldVolumeG;


@end

NS_ASSUME_NONNULL_END
