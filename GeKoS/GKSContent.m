//
//  GKSContent.m
//  GeKoS
//
//  Created by Alex Popadich on 3/15/22.
//

#import "GKSContent.h"
#import "GKSCameraRep.h"
#import "GKS3DObject.h"

@implementation GKSContent

- (instancetype)init
{
    self = [super init];
    if (self) {
        GKSCameraRep *cameraRep = [[GKSCameraRep alloc] init];
        GKSScene *aScene = [[GKSScene alloc] initWithCamera:cameraRep];
        
        
        for (int i=-3; i<4; i++) {
            GKS3DObject *object3D = [[GKS3DObject alloc] init];
            [object3D locateX:2.0 * i Y:i%2 Z:0.0];

            [aScene add3DObject:object3D];
        }


        _theScene = aScene;
    }
    return self;
}

@end
