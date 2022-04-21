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

        GKSCameraRep *cameraRep = [[GKSCameraRep alloc] init];
        GKSSceneRep *sceneRep = [[GKSSceneRep alloc] initWithContext:_context3D];
        GKSMeshMonger *monger = [[GKSMeshMonger alloc] init];
        
        _meshMonger = monger;
        _scene = sceneRep;
        _camera = cameraRep;
        
    }
    return self;
}


@end
