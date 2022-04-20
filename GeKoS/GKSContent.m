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
#import "GKSSceneRep.h"
#import "GKSMeshMonger.h"


@implementation GKSContent

- (instancetype)init
{
    self = [super init];
    if (self) {
        _context3D =  gks_init();

        GKSCameraRep *cameraRep = [[GKSCameraRep alloc] init];
        GKSSceneRep *sceneRep = [[GKSSceneRep alloc] init];
        GKSMeshMonger *monger = [[GKSMeshMonger alloc] init];
        GKSSceneController *sceneController = [[GKSSceneController alloc] initWithCamera:cameraRep andScene:sceneRep];
        sceneController.monger = monger;
        
        // Default volume bounds to the GKS 3D world.
        
        sceneController.worldVolumeMinX = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMinX];
        sceneController.worldVolumeMinY = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMinY];
        sceneController.worldVolumeMinZ = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMinZ];
        
        sceneController.worldVolumeMaxX = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMaxX];
        sceneController.worldVolumeMaxY = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMaxY];
        sceneController.worldVolumeMaxZ = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMaxZ];

        sceneController.context = _context3D;
        _sceneController = sceneController;
    }
    return self;
}


@end
