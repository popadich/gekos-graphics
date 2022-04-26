//
//  GKSStoryBoardRep.h
//  GeKoS
//
//  Created by Alex Popadich on 4/26/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class GKSSceneRep;

@interface GKSStoryBoardRep : NSObject

@property (strong) NSMutableArray *keyScenes;

-(GKSSceneRep *)sceneOne;

@end

NS_ASSUME_NONNULL_END
