//
//  GKSContent.m
//  GeKoS
//
//  Created by Alex Popadich on 3/15/22.
//

#import "GKSContent.h"
#import "GKSCameraRep.h"

@implementation GKSContent

- (instancetype)init
{
    self = [super init];
    if (self) {
        GKSCameraRep *cameraRep = [[GKSCameraRep alloc] init];
        GKSScene *frameOne = [[GKSScene alloc] initWithCamera:cameraRep];
        _theScene = frameOne;
    }
    return self;
}

@end
