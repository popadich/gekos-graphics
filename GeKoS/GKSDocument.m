//
//  Document.m
//  GeKoS
//
//  Created by Alex Popadich on 11/30/21.
//

#import "GKSDocument.h"
#import "GKSContent.h"
#import "GKSConstants.h"
#import "GKSWindowController.h"
#import "GKSContentViewController.h"
#import "GKSMeshParser.h"
#import "GKSMeshMonger.h"
#import "ActorEntity+CoreDataClass.h"

@interface GKSDocument ()

@end

@implementation GKSDocument


// TODO: make this the designated init
- (instancetype)init {
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        
        _content = [[GKSContent alloc] initWithManagedObjectContext:self.managedObjectContext];
        // Stage actors for all Actor entities
        NSFetchRequest *request = [StoryBoardEntity fetchRequest];
        NSError *error = nil;
        NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
        if (!results) {
            NSLog(@"Error fetching storyboard objects: %@\n%@", [error localizedDescription], [error userInfo]);
            abort();
        }
        if (results.count == 1) {
            StoryBoardEntity *story = [results objectAtIndex:0];
            _storyBoard = story;

        }
        
        
        // TODO: make monger a view controller
        GKSMeshMonger *monger = [GKSMeshMonger sharedMeshMonger];
        monger.managedObjectContext = self.managedObjectContext;
    }
    return self;
}

- (instancetype)initWithType:(NSString *)typeName error:(NSError *__autoreleasing  _Nullable *)outError
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        if ([typeName isEqual:@"com.xephyr.gekos"]) {
            _storyBoard = [self makeEmptyStoryBoard];
        }

    }
    return self;
}

- (void)addPlayThings:(NSManagedObjectContext *)moc scene:(SceneEntity *)scene {
    BOOL playing = YES;
    if (playing) {
        NSMutableSet *actors = [[NSMutableSet alloc] init];
        GKSfloat rad = 0.0;
        for (int i=1; i<8; i++) {
            GKSfloat locX = 0.0;
            GKSfloat locY = i%2;
            GKSfloat locZ = -2.0 * i;
            
            ActorEntity *actorEntity = [NSEntityDescription insertNewObjectForEntityForName:@"ActorEntity" inManagedObjectContext:moc];
            actorEntity.kind  = (i%2) ? kCubeKind : kPyramidKind;
            actorEntity.locX = locX;
            actorEntity.locY = locY;
            actorEntity.locZ = locZ;
            actorEntity.scaleX = 1.0;
            actorEntity.scaleY = 1.0;
            actorEntity.scaleZ = 1.0;
            actorEntity.name =  [[NSUUID UUID] UUIDString];
            actorEntity.toScene = scene;
            [actors addObject:actorEntity];
            actorEntity.lineColor = [NSColor greenColor];
            
            rad += 35;
        }
        scene.toActors = actors;
    }
}

- (void)addCamera:(NSDictionary *)defaults moc:(NSManagedObjectContext *)moc scene:(SceneEntity *)scene {
    NSDictionary *cameraSettings = [defaults valueForKey:@"cameraDefaults"];
    CameraEntity *camera = [NSEntityDescription insertNewObjectForEntityForName:@"CameraEntity" inManagedObjectContext:moc];
    
    camera.positionX = [[cameraSettings valueForKey:@"posX"] doubleValue];
    camera.positionY = [[cameraSettings valueForKey:@"posY"] doubleValue];
    camera.positionZ = [[cameraSettings valueForKey:@"posZ"] doubleValue];
    
    camera.lookX = [[cameraSettings valueForKey:@"lookX"] doubleValue];
    camera.lookY = [[cameraSettings valueForKey:@"lookY"] doubleValue];
    camera.lookZ = [[cameraSettings valueForKey:@"lookZ"] doubleValue];
    
    camera.upX = [[cameraSettings valueForKey:@"upX"] doubleValue];
    camera.upY = [[cameraSettings valueForKey:@"upY"] doubleValue];
    camera.upZ = [[cameraSettings valueForKey:@"upZ"] doubleValue];
    
    camera.yaw = [[cameraSettings valueForKey:@"yaw"] doubleValue];
    camera.pitch = [[cameraSettings valueForKey:@"pitch"] doubleValue];
    camera.roll = [[cameraSettings valueForKey:@"roll"] doubleValue];
    
    camera.far = [[cameraSettings valueForKey:@"far"] doubleValue];
    camera.near = [[cameraSettings valueForKey:@"near"] doubleValue];
    camera.focalLength = [[cameraSettings valueForKey:@"focalLength"] doubleValue];
    
    camera.projectionType = [[cameraSettings valueForKey:@"projectionType"] intValue];
    
    camera.toScene = scene;
    scene.toCamera = camera;
}





- (StoryBoardEntity *)makeEmptyStoryBoard {
    NSManagedObjectContext *moc = [self managedObjectContext];
    _content = [[GKSContent alloc] initWithManagedObjectContext:moc];
    
    NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"]];
    
    StoryBoardEntity *story = [NSEntityDescription insertNewObjectForEntityForName:@"StoryBoardEntity" inManagedObjectContext:moc];
    
    NSDictionary *storyDefaults = [defaults valueForKey:@"storyDefaults"];
    NSString *title = [storyDefaults valueForKey:@"storyTitle"];;
    NSString *desc = [storyDefaults valueForKey:@"storyDescription"];
    story.storyTitle = title;
    story.storyDescription = desc;

    // add one scene to a set
//    NSMutableSet *toScenes = [story valueForKey:@"toScenes"];
    NSMutableSet *sceneSetOne = [[NSMutableSet alloc] init];
    SceneEntity *scene = [NSEntityDescription insertNewObjectForEntityForName:@"SceneEntity" inManagedObjectContext:moc];
    scene.title = @"Scene 1";
    scene.sceneType = @"START";
    scene.volumeMinX = [[[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMinX] doubleValue];
    scene.volumeMaxX = [[[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMaxX] doubleValue];
    scene.volumeMinY = [[[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMinY] doubleValue];
    scene.volumeMaxY = [[[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMaxY] doubleValue];
    scene.volumeMinZ = [[[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMinZ] doubleValue];
    scene.volumeMaxZ = [[[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMaxZ] doubleValue];
    
    // Load default background color for this scene
    NSError *error;
    NSData *colorData = [[NSUserDefaults standardUserDefaults] dataForKey:gksPrefBackgroundColor];
    if (colorData != nil) {
        NSColor *sceneBackColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:colorData error:&error];
        scene.backgroundColor = sceneBackColor;
    }
    else {
        scene.backgroundColor = [NSColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    }
    [sceneSetOne addObject:scene];

    scene.toStoryBoard = story;
    story.toScenes = sceneSetOne;
    

    [self addCamera:defaults moc:moc scene:scene];
    
    GKSMeshMonger *monger = [GKSMeshMonger sharedMeshMonger];
    monger.managedObjectContext = self.managedObjectContext;
    
    // fill meshes
    NSArray *meshes = [monger meshList];
    for (GKSMeshRep *mesh in meshes) {
        MeshEntity *meshEnt = [NSEntityDescription insertNewObjectForEntityForName:@"MeshEntity" inManagedObjectContext:moc];
        meshEnt.meshID = mesh.meshId.intValue;
        meshEnt.meshName = mesh.meshName;
        meshEnt.offString = mesh.offString;
    }
    

    
    
    // TODO: remove when done with playing
    [self addPlayThings:moc scene:scene];
    
    
    [moc processPendingChanges];
    [[moc undoManager] removeAllActions];
    [self updateChangeCount:NSChangeCleared];

    return story;
}

+ (BOOL)autosavesInPlace {
    return YES;
}

- (void)makeWindowControllers {
    GKSWindowController *windowController = [[GKSWindowController alloc] initWithWindowNibName:@"GKSDocument"];
    [self addWindowController:windowController];
    
    // No need to specify nib file if it has the same name as the class
    GKSContentViewController *contentController = [[GKSContentViewController alloc] init];
    
    contentController.representedObject = self.content;
    windowController.contentViewController = contentController;
}

/*
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError *__autoreleasing  _Nullable *)outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error if you return NO.
    // Alternatively, you could remove this method and override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you do, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    
    
    [NSException raise:@"UnimplementedMethod" format:@"%@ is unimplemented", NSStringFromSelector(_cmd)];
    
    
    return NO;

}
*/

//
//- (GKSmesh_3 *)readModelFromURL:(NSURL*)URL;
//{
//    GKSmesh_3 *mesh = nil;
//    NSError *error;
//
//    NSString *meshString = [[NSString alloc] initWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:&error];
//
//    if (meshString != nil) {
//        NSLog(@"Parse Mesh string %@", meshString);
//        GKSMeshParser *parser = [GKSMeshParser sharedMeshParser];
//        mesh = [parser parseOFFMeshFile:URL error:&error];
//
//        if (mesh) {
//
//            // TODO: do this elsewhere
//
//            GKSvector3d loc = GKSMakeVector(0.0, 0.0, 0.0);
//            GKSvector3d rot = GKSMakeVector(0.0, 0.0, 0.0);
//            GKSvector3d sca = GKSMakeVector(1.0, 1.0, 1.0);
//            GKS3DObject *customMeshObj = [[GKS3DObject alloc] initWithMesh:mesh atLocation:loc withRotation:rot andScale:sca];
//            [self.content.sceneController add3DObject:customMeshObj];
//
//        }
//    }
//    return  mesh;
//}

// TODO: enable when done with core data setup
/*
- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError *__autoreleasing  _Nullable *)error
{
    BOOL hasRead = NO;
    GKSmesh_3 *mesh = nil;
    
    if ([typeName isEqual:@"com.xephyr.off"]) {
        NSLog(@"OFF file to read %@", absoluteURL);
        NSString *meshString = [[NSString alloc] initWithContentsOfURL:absoluteURL encoding:NSUTF8StringEncoding error:error];
        if (meshString != nil) {
            GKSMeshParser *parser = [GKSMeshParser sharedMeshParser];
            mesh = [parser parseOFFMeshString:meshString error:error];
            if (mesh) {
                
                // TODO: mesh monger is too buried and this could all be move there
                // add new mesh to monger
                GKSMeshMonger *monger = [GKSMeshMonger sharedMeshMonger];
                
                NSNumber *meshID = [monger nextID];
                GKSMeshRep *meshRep = [[GKSMeshRep alloc] initWithID:meshID andMeshPtr:mesh];
                [monger addMeshRep:meshRep];
                
                
                // TODO: object add should happen elsewhere
                GKSvector3d loc = GKSMakeVector(0.0, 0.0, 0.0);
                GKSvector3d rot = GKSMakeVector(0.0, 0.0, 0.0);
                GKSvector3d sca = GKSMakeVector(1.0, 1.0, 1.0);
                
                // TODO: pass mesh here
                GKS3DObjectRep *objectRep = [[GKS3DObjectRep alloc] initWithKind:meshID.intValue atLocation:loc withRotation:rot andScale:sca];
                
                // TODO: fragile
                GKSSceneRep *theScene = [self.content.storyBoard sceneOne];
                [theScene add3DObjectRep:objectRep withMesh:mesh];
                
                
            }
            hasRead = YES;
        }
    }
    else if ([typeName isEqual:@"com.xephyr.json"]) {
//        model = [self.content readModelFromJsonData:data];
    }
    
    return hasRead;

}
 */


@end
