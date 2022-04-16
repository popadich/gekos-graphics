//
//  GKSContent.m
//  GeKoS
//
//  Created by Alex Popadich on 3/15/22.
//

#import "GKSContent.h"
#import "GKSCameraRep.h"
#import "GKS3DObject.h"
#import "GKSConstants.h"


@implementation GKSContent

- (instancetype)init
{
    self = [super init];
    if (self) {
        GKSCameraRep *cameraRep = [[GKSCameraRep alloc] init];
        GKSScene *aScene = [[GKSScene alloc] initWithCamera:cameraRep];
        
        // Default volume bounds to the GKS 3D world.
        
        aScene.worldVolumeMinX = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMinX];
        aScene.worldVolumeMinY = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMinY];
        aScene.worldVolumeMinZ = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMinZ];
        
        aScene.worldVolumeMaxX = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMaxX];
        aScene.worldVolumeMaxY = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMaxY];
        aScene.worldVolumeMaxZ = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMaxZ];
        
        
        // TODO: remove when done with playing
        BOOL playing = YES;
        if (playing) {
            setMeshCenteredFlag(true);
            GKSfloat rad = 0.0;
            for (int i=0; i<7; i++) {
                GKS3DObject *object3D = [[GKS3DObject alloc] init];
                [object3D locateX:0.0 Y:i%2 Z: -2.0 * i];
                [object3D rotateX:0.0 Y:rad Z:0.0];

                [aScene add3DObject:object3D];
                rad += DEG_TO_RAD * 35;
            }
        }


        _theScene = aScene;
    }
    return self;
}


@end
