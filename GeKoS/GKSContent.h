//
//  GKSContent.h
//  GeKoS
//
//  Created by Alex Popadich on 3/15/22.
//

#import <Foundation/Foundation.h>
#import "GKSSceneController.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKSContent : NSObject

@property (strong) GKSCameraRep *camera;
@property (strong) GKSSceneRep *scene;
@property (strong) GKSMeshMonger *meshMonger;

//@property (strong) GKSSceneController *sceneController;
@property (assign) GKScontext3DPtr context3D;


@end

NS_ASSUME_NONNULL_END
