//
//  GKSSceneInspector.h
//  GeKoS
//
//  Created by Alex Popadich on 3/16/22.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN
@class GKSSceneController;
@class GKSSceneRep;

@interface GKSSceneInspector : NSWindowController <NSWindowDelegate>

+ (id)sharedInspector;

//@property (nonatomic,weak) GKSSceneController* sceneController;
@property (nonatomic,weak) GKSSceneRep* scene;

@end

NS_ASSUME_NONNULL_END
