//
//  GKSSceneInspector.h
//  GeKoS
//
//  Created by Alex Popadich on 3/16/22.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN
@class GKSScene;

@interface GKSSceneInspector : NSWindowController

+ (id)sharedInspector;

@property (nonatomic,weak) GKSScene* theScene;

@end

NS_ASSUME_NONNULL_END
