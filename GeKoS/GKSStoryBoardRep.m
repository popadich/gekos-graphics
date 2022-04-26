//
//  GKSStoryBoardRep.m
//  GeKoS
//
//  Created by Alex Popadich on 4/26/22.
//

#import "GKSStoryBoardRep.h"
#import "GKSSceneRep.h"

@implementation GKSStoryBoardRep

- (instancetype)init
{
    self = [super init];
    if (self) {
        _keyScenes = [[NSMutableArray alloc] init];
    }
    return self;
}

-(GKSSceneRep *)sceneOne
{
    GKSSceneRep *firstScene = nil;
    if (self.keyScenes.count > 0) {
        firstScene = [self.keyScenes objectAtIndex:0];
    }
    
    return firstScene;
}

@end
