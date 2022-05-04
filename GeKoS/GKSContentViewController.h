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

@property (strong) IBOutlet GKSCameraController* cameraViewController;
@property (strong) IBOutlet GKSDrawingController* drawingViewController;
@property (strong) IBOutlet GKSSceneController* sceneController;

@property (strong) NSManagedObjectContext *managedObjectContext;

@property (strong) NSNumber *isCenteredObject;
@property (strong) NSNumber *makeKinds;

@end

NS_ASSUME_NONNULL_END
