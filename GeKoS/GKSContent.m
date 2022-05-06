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

- (instancetype)initWithManagedObjectContext: (NSManagedObjectContext *)moc
{
    self = [super init];
    if (self) {
        _context3D =  gks_init();
        _managedObjectContext = moc;
        
        GKSCameraRep *cameraRep = [[GKSCameraRep alloc] initWithContext:_context3D];
        GKSSceneRep *sceneRep = [[GKSSceneRep alloc] initWithContext:_context3D];
        _theCamera = cameraRep;

        _theScene = sceneRep;
        
    }
    return self;
}

- (NSData *)textRepresentation
{
//    NSString *simplestjson = @"{ 'name' : 'alex' }";
    
    NSMutableDictionary *sceneDict = [[NSMutableDictionary alloc] init];
    
    [sceneDict setObject:@"Alex Popadich" forKey:@"director"];
    [sceneDict setObject:@1 forKey:@"frameCount"];
    
    
    NSMutableArray *film = [[NSMutableArray alloc] init];
    [sceneDict setObject:film forKey:@"film"];
    
    GKSSceneRep *teh_scene = self.theScene;
    for (GKS3DActor *actor3D in teh_scene.toActors) {
        NSMutableDictionary *actorSpecs = [[NSMutableDictionary alloc] init];
        actorSpecs[@"kind"] = @1;
        GKSvector3d pos = [actor3D positionVector];
        actorSpecs[@"locX"] = @(pos.crd.x);
        actorSpecs[@"locY"] = @(pos.crd.y);
        actorSpecs[@"locZ"] = @(pos.crd.z);
        GKSvector3d sca = [actor3D scaleVector];
        actorSpecs[@"scaleX"] = @(sca.crd.x);
        actorSpecs[@"scaleY"] = @(sca.crd.y);
        actorSpecs[@"scaleZ"] = @(sca.crd.z);
        GKSvector3d rot = [actor3D rotationVector];
        actorSpecs[@"rotX"] = @(rot.crd.x);
        actorSpecs[@"rotY"] = @(rot.crd.y);
        actorSpecs[@"rotZ"] = @(rot.crd.z);
        [film addObject:actorSpecs];
        
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sceneDict
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    
    return jsonData;

}

@end
