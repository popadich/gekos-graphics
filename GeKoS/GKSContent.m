//
//  GKSContent.m
//  GeKoS
//
//  Created by Alex Popadich on 3/15/22.
//

#import "GKSContent.h"
#import "GKSCameraRep.h"
#import "GKS3DObjectRep.h"

@implementation GKSContent

- (instancetype)init
{
    self = [super init];
    if (self) {
        GKSCameraRep *cameraRep = [[GKSCameraRep alloc] init];
        GKSScene *frameOne = [[GKSScene alloc] initWithCamera:cameraRep];
        
        
        for (int i=-3; i<4; i++) {
            GKS3DObjectRep *object1 = [[GKS3DObjectRep alloc] init];
            [object1 locateX:2.0 * i Y:0.0 Z:0.0];

            [frameOne addObjectRep:object1];
        }


        _theScene = frameOne;
    }
    return self;
}

@end
