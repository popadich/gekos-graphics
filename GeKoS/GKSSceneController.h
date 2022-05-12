//
//  GKSScene.h
//  gks-cocoa
//
//  Created by Alex Popadich on 7/31/21.
//

#import <Foundation/Foundation.h>
#import "GKSSceneRep.h"
#import "GKSMeshMonger.h"
#import "ActorEntity+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKSSceneController : NSObject

@property (strong) GKSSceneRep *scene;
@property (strong) NSMutableDictionary *actorWhitePages;
@property (strong) GKSMeshMonger *theMonger;

- (void)setFrustumCulling:(BOOL)flag;

- (void)castSetOfActors:(NSSet *)actors;
- (GKS3DActor *)castActorFromEnt:(ActorEntity * _Nonnull)actor;

- (void)transformAllObjects;

- (void)setWorldVolumeG;


@end

NS_ASSUME_NONNULL_END
