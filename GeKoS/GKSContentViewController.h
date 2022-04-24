//
//  GKSContentViewController.h
//  GeKoS
//
//  Created by Alex Popadich on 2/23/22.
//

#import <Cocoa/Cocoa.h>
#import "GKSCameraController.h"
#import "GKSDrawingController.h"

NS_ASSUME_NONNULL_BEGIN


@class GKSSceneController;

@interface GKSContentViewController : NSViewController

@property (strong)NSNumber *isCenteredObject;

@property (nonatomic, strong) IBOutlet GKSCameraController* cameraViewController;
@property (nonatomic, strong) IBOutlet GKSDrawingController* drawingViewController;
@property (strong) IBOutlet GKSSceneController* sceneController;

@property (strong) NSMutableArray *toScenes;


@end

NS_ASSUME_NONNULL_END
