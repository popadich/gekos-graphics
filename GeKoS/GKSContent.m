//
//  GKSContent.m
//  GeKoS
//
//  Created by Alex Popadich on 3/15/22.
//

#import "GKSContent.h"
#import "GKSConstants.h"
#import "GKSCameraRep.h"
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
        [storyBoard setStoryTitle:@"A Gekos Story"];
        [storyBoard.toScenes addObject:sceneRep];
        
        _storyBoard = storyBoard;
        _theScene = sceneRep;
        
    }
    return self;
}


@end
