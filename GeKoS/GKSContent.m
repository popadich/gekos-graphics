//
//  GKSContent.m
//  GeKoS
//
//  Created by Alex Popadich on 3/15/22.
//

#import "GKSContent.h"
#import "GKSConstants.h"
#import "GKSCameraRep.h"
#import "GKSSceneRep.h"
#import "GKSMeshMonger.h"



@implementation GKSContent

- (instancetype)init
{
    self = [super init];
    if (self) {
        _context3D =  gks_init();

        GKSCameraRep *cameraRep = [[GKSCameraRep alloc] initWithContext:_context3D];
        GKSSceneRep *sceneRep = [[GKSSceneRep alloc] initWithContext:_context3D];
        sceneRep.toCamera = cameraRep;
        
        GKSStoryBoardRep *storyBoard = [[GKSStoryBoardRep alloc] init];
        [storyBoard setStoryTitle:@"Untitled Story"];
        [storyBoard.keyScenes addObject:sceneRep];
        
        _storyBoard = storyBoard;
        
    }
    return self;
}


@end
