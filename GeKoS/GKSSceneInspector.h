//
//  GKSSceneInspector.h
//  GeKoS
//
//  Created by Alex Popadich on 3/16/22.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN
@class GKSSceneController;

@interface GKSSceneInspector : NSWindowController <NSWindowDelegate>

+ (id)sharedInspector;

@property (nonatomic,weak) GKSSceneController* sceneController;

@end

NS_ASSUME_NONNULL_END
