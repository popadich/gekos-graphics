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
        
        _theCamera = [[GKSCameraRep alloc] initWithContext:_context3D];
        _theScene = [[GKSSceneRep alloc] initWithContext:_context3D];
        
        GKSMeshMonger *monger = [[GKSMeshMonger alloc] init];
        _theMonger = monger;
        
        
        // Load Default Colors for Content View
        NSError *error;
        NSData *colorData = [[NSUserDefaults standardUserDefaults] dataForKey:gksPrefPenColor];
        if (colorData != nil) {
            self.contentLineColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:colorData error:&error];
        }
        colorData = [[NSUserDefaults standardUserDefaults] dataForKey:gksPrefFillColor];
        if (colorData != nil) {
            self.contentFillColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:colorData error:&error];
        }

        
    }
    return self;
}



- (NSData *)textRepresentation
{
//    NSString *simplestjson = @"{ 'name' : 'alex' }";
    
    NSMutableDictionary *filmDict = [[NSMutableDictionary alloc] init];
    
    NSInteger frameCount = 1;
    [filmDict setObject:@"Alex Popadich" forKey:@"director"];
    [filmDict setObject:@(frameCount) forKey:@"frameCount"];
    
    
    NSMutableArray *filmFrames = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i<frameCount; i++) {
        NSDictionary *frameDict = [[NSMutableDictionary alloc] init];

        GKSCameraRep *camera = self.theCamera;
        NSDictionary *observerDict = camera.cameraAsDictionary;
        [frameDict setValue:observerDict forKey:@"observer"];
        
        // add actor array
        NSMutableArray *actorList = [[NSMutableArray alloc] init];
        for (GKS3DActor *actor3D in self.theScene.toActors) {
            
            NSDictionary* actorSpecs = actor3D.actorAsDictionary;
            
            [actorList addObject:actorSpecs];
            
        }
        [frameDict setValue:actorList forKey:@"spheres"];
        
        [filmFrames addObject:frameDict];
    }
    
    
    [filmDict setObject:filmFrames forKey:@"frames"];

    NSDictionary *filmJson = @{@"film" : filmDict };
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:filmJson
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    
    return jsonData;

}

@end
