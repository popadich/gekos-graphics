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
#import "ActorEntity+CoreDataClass.h"
#import "MeshEntity+CoreDataClass.h"

@interface GKSDocument ()
@end

@implementation GKSDocument


// TODO: make this the designated init
- (instancetype)init {
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        
        _content = [[GKSContent alloc] initWithManagedObjectContext:self.managedObjectContext];

    }
    return self;
}

- (instancetype)initWithType:(NSString *)typeName error:(NSError *__autoreleasing  _Nullable *)outError
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        if ([typeName isEqualToString:@"com.xephyr.gekos"]) {
            _content = [[GKSContent alloc] initWithManagedObjectContext:self.managedObjectContext];
            [self insertEmptyStoryBoardIntoMoc:self.managedObjectContext];
        }

    }
    return self;
}

- (void)addPlayThings:(NSManagedObjectContext *)moc scene:(SceneEntity *)scene {

    
        GKSfloat rad = 0.0;
        for (int i=1; i<9; i++) {
            GKSfloat locX = i%2 * 5;
            GKSfloat locY = 0.0;
            GKSfloat locZ = -2.0 * i;
            
            ActorEntity *actorEntity = [NSEntityDescription insertNewObjectForEntityForName:@"ActorEntity" inManagedObjectContext:moc];
            actorEntity.kind  = kCubeKind;
            actorEntity.locX = locX;
            actorEntity.locY = locY;
            actorEntity.locZ = locZ;
            actorEntity.scaleX = 1.0;
            actorEntity.scaleY = 1.0;
            actorEntity.scaleZ = 1.0;
            actorEntity.actorID =  [NSUUID UUID];
            actorEntity.lineColor = [NSColor greenColor];
            
            [scene addToActorsObject:actorEntity];
            rad += 35;
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





static SceneEntity *addSceneOne(NSManagedObjectContext *moc, StoryBoardEntity *story) {
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
    return scene;
}

- (StoryBoardEntity *)insertEmptyStoryBoardIntoMoc:(NSManagedObjectContext *)moc {
    
    NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"]];
    
    StoryBoardEntity *story = [NSEntityDescription insertNewObjectForEntityForName:@"StoryBoardEntity" inManagedObjectContext:moc];
    
    NSDictionary *storyDefaults = [defaults valueForKey:@"storyDefaults"];
    NSString *title = [storyDefaults valueForKey:@"storyTitle"];
    NSString *desc = [storyDefaults valueForKey:@"storyDescription"];
    story.storyTitle = title;
    story.storyDescription = desc;

    // add one scene to a story
    SceneEntity * scene = addSceneOne(moc, story);
    
    // add one camera to the scene
    [self addCamera:defaults moc:moc scene:scene];
    
    
    // Populate base meshes from Defaults and add them to the monger
    NSArray* meshDefaults = [defaults valueForKey:@"meshDefaults"];
    NSMutableSet *meshEntities = [[NSMutableSet alloc] init];
    for (NSDictionary *meshDict in meshDefaults) {
        MeshEntity *meshEnt = [NSEntityDescription insertNewObjectForEntityForName:@"MeshEntity" inManagedObjectContext:moc];
        
        NSNumber* meshID = [meshDict valueForKey:@"meshID"];
        meshEnt.meshID = meshID.intValue;
        meshEnt.meshName = meshDict[@"meshName"];
        meshEnt.offString = [meshDict valueForKey:@"meshOffString"];
        NSNumber *polygonCount = [meshDict valueForKey:@"polygonCount"];
        NSNumber *edgeCount = [meshDict valueForKey:@"edgeCount"];
        NSNumber *vertexCount = [meshDict valueForKey:@"vertexCount"];
        meshEnt.vertexCount = vertexCount.intValue;
        meshEnt.polygonCount = polygonCount.intValue;
        meshEnt.edgeCount = edgeCount.intValue;
        meshEnt.volumeMinX = [[meshDict valueForKey:@"volumeMinX"] doubleValue];
        meshEnt.volumeMinY = [[meshDict valueForKey:@"volumeMinY"] doubleValue];
        meshEnt.volumeMinZ = [[meshDict valueForKey:@"volumeMinZ"] doubleValue];
        meshEnt.volumeMaxX = [[meshDict valueForKey:@"volumeMaxX"] doubleValue];
        meshEnt.volumeMaxY = [[meshDict valueForKey:@"volumeMaxY"] doubleValue];
        meshEnt.volumeMaxZ = [[meshDict valueForKey:@"volumeMaxZ"] doubleValue];

        
        [meshEntities addObject:meshEnt];
        
    }

    [story addToMeshes:meshEntities];
    
    
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

/*
- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError *__autoreleasing  _Nullable *)error
{
    BOOL hasRead = NO;
//    if ([typeName isEqual:@"com.xephyr.off"]) {
//        NSLog(@"OFF file to read %@", absoluteURL);
//    }
//    else if ([typeName isEqual:@"com.xephyr.json"]) {
//        model = [self.content readModelFromJsonData:data];
//    }
    
    return hasRead;

}
*/


@end
