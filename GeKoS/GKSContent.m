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
#import "GKSMeshParser.h"

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
            for (int i=-3; i<4; i++) {
                GKS3DObject *object3D = [[GKS3DObject alloc] init];
                [object3D locateX:2.0 * i Y:i%2 Z:0.0];

                [aScene add3DObject:object3D];
            }
        }


        _theScene = aScene;
    }
    return self;
}




- (GKSmesh_3 *)readModelFromURL:(NSURL*)URL;
{
    GKSmesh_3 *model = nil;
    NSError *error;

    NSString *contentString = [[NSString alloc] initWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:&error];
    if (contentString != nil) {
        NSLog(@"Parse Mesh string %@", contentString);
        
        GKSvector3d loc = GKSMakeVector(0.0, 0.0, 0.0);
        GKSvector3d rot = GKSMakeVector(0.0, 0.0, 0.0);
        GKSvector3d sca = GKSMakeVector(1.0, 1.0, 1.0);
        
        GKSMeshParser *parser = [GKSMeshParser sharedMeshParser];
        model = [parser parseOFFMeshFile:URL error:&error];
        if (model) {
            
            // TODO: do this elsewhere
            GKS3DObject *customMeshObj = [[GKS3DObject alloc] initWithMesh:model atLocation:loc withRotation:rot andScale:sca];
            [_theScene add3DObject:customMeshObj];
            
        }
    }
    return  model;
}



@end
