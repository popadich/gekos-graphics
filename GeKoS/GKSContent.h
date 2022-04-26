//
//  GKSContent.h
//  GeKoS
//
//  Created by Alex Popadich on 3/15/22.
//

#import <Foundation/Foundation.h>
#import "GKSSceneController.h"
#import "GKSStoryBoardRep.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKSContent : NSObject

@property (strong) GKSCameraRep *camera;
@property (strong) GKSMeshMonger *meshMonger;
@property (strong) GKSStoryBoardRep *storyBoard;

@property (assign) GKScontext3DPtr context3D;

@end

NS_ASSUME_NONNULL_END
