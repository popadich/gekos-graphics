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
@class GKSStoryBoardRep;

@interface GKSContentViewController : NSViewController

@property (strong)NSNumber *isCenteredObject;

@property (nonatomic, strong) IBOutlet GKSCameraController* cameraViewController;
@property (nonatomic, strong) IBOutlet GKSDrawingController* drawingViewController;
@property (strong) IBOutlet GKSSceneController* sceneController;

@property (strong) NSManagedObjectContext *context;

@property (strong) NSMutableArray *toScenes;
@property (strong) GKSStoryBoardRep* itsStoryBoard;

@property (strong) NSMutableSet *contentStories;

@end

NS_ASSUME_NONNULL_END
