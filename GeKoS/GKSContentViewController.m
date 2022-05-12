//
//  GKSContentViewController.m
//  GeKoS
//
//  Created by Alex Popadich on 2/23/22.
//

#import "GKSContentViewController.h"
#import "GKSConstants.h"
#import "GKSContent.h"
#import "GKSCameraRep.h"
#import "GKSMeshMonger.h"
#import "GKS3DActor.h"
#import "GKSSceneController.h"
#import "GKSMeshParser.h"
#import "Document+CoreDataModel.h"


#define GKS_MAX_VANTAGE_PTS 6

@interface GKSContentViewController ()

@property (nonatomic, weak) IBOutlet NSView* cameraCustomView;
@property (weak) IBOutlet NSArrayController *actorArrayController;
@property (weak) IBOutlet NSArrayController *sceneArrayController;
@property (weak) IBOutlet NSArrayController *meshArrayController;

@property (strong) GKSContent *itsContent;

@property (strong) NSColor* contentLineColor;
@property (strong) NSColor* contentFillColor;

@property (assign) NSInteger currentVPIndex;
@property (strong) NSMutableArray *vantagePoints;

@property (strong) id currentSceneId;

@end



static void *volumeSceneContext = &volumeSceneContext;
static void *worldDataContext = &worldDataContext;

@implementation GKSContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.

    // Can't use replace subview because constraints in parent view are lost
    NSView* cameraSubView = self.cameraViewController.view;
    cameraSubView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cameraCustomView addSubview:cameraSubView];

    NSDictionary *viewsDictionary = @{@"newView":cameraSubView};

    NSString *hFormatString = @"H:|-0-[newView]-0-|";
    NSString *vFormatString = @"V:|-[newView]-|";

    NSArray *horzConstraints = [NSLayoutConstraint constraintsWithVisualFormat:hFormatString options:0 metrics:nil views:viewsDictionary];
    NSArray *vertConstraints = [NSLayoutConstraint constraintsWithVisualFormat:vFormatString options:0 metrics:nil views:viewsDictionary];
    
    // add constraints
    [self.view addConstraints:horzConstraints];
    [self.view addConstraints:vertConstraints];

    [self.drawingViewController drawingSetViewRectG];
    [self.sceneController setWorldVolumeG];

    
    
    NSError *error = nil;
    NSArray *results = nil;
    
    NSFetchRequest *fetchMeshesRequest = [MeshEntity fetchRequest];
    results = [self.managedObjectContext executeFetchRequest:fetchMeshesRequest error:&error];
    if (!results) {
        NSLog(@"Error fetching meshes objects: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    for (MeshEntity *meshEnt in results) {
        NSString* meshName = meshEnt.meshName;
        NSNumber* meshID = [NSNumber numberWithInt:meshEnt.meshID];
        NSString* meshOffString = meshEnt.offString;
        GKSMeshParser *parser = [GKSMeshParser sharedMeshParser];
        GKSmesh_3* mesh_ptr = [parser parseOFFMeshString:meshOffString error:&error];

        GKSMeshRep *meshRep = [[GKSMeshRep alloc] initWithID:meshID andName:meshName andMeshPtr:mesh_ptr andOffString:meshOffString];
        [self.itsContent.theMonger addMeshRepToMongerMenu:meshRep];

    }
    

    
      // Stage actors for all Actor entities
      NSFetchRequest *fetchStoryRequest = [StoryBoardEntity fetchRequest];
      results = [self.managedObjectContext executeFetchRequest:fetchStoryRequest error:&error];
      if (!results) {
          NSLog(@"Error fetching storyboard objects: %@\n%@", [error localizedDescription], [error userInfo]);
          abort();
      }
      if (results.count == 1) {
          StoryBoardEntity *story = [results objectAtIndex:0];
          self.itsContent.theStory = story;

      }
    
    
    
    
    
    
    
    
    // Set all vantage points to the same default values
    self.currentVPIndex = 0;
    self.vantagePoints = [[NSMutableArray alloc] initWithCapacity:GKS_MAX_VANTAGE_PTS];
    for (GKSint vantage_idx=0; vantage_idx<GKS_MAX_VANTAGE_PTS; vantage_idx++) {
        NSDictionary *vantageProperties = [self gatherVantage];
        [self.vantagePoints addObject:vantageProperties];
    }

    [self setIsCenteredObject:@NO];
    [self setMakeKinds:@(kCubeKind)];
    [self registerAsObserverForScene];
    
    // notifications come after camera values have been set
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraMovedNotification:) name:@"cameraMoved" object:nil];
    
}

- (void)awakeFromNib {
    
    // content should be populated by the document read methods
    GKSContent *content = self.representedObject;
    self.managedObjectContext = content.managedObjectContext;
 
    // set the scene controller's scene, part of an initializer maybe?
    GKSSceneRep *sceneRep = content.theScene;
    NSAssert(sceneRep != nil, @"scene rep must exist");
    self.sceneController.scene = sceneRep;
    self.sceneController.theMonger = content.theMonger;
    
//    self.cameraViewController.representedObject = content.theCamera;
    self.cameraViewController.camera = content.theCamera;
    self.drawingViewController.representedObject = sceneRep;

    
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

    // Load Default Options for Content View
    BOOL cullFlag = [[NSUserDefaults standardUserDefaults] boolForKey:gksPrefFrustumCullFlag];
    [self.sceneController setFrustumCulling:cullFlag];
    
    self.currentSceneId = nil;
    self.itsContent = content;

}

- (void)dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.sceneController removeObserver:self forKeyPath:@"worldBackColor" context:worldDataContext];
    [self.sceneController removeObserver:self forKeyPath:@"worldFillColor" context:worldDataContext];
    [self.sceneController removeObserver:self forKeyPath:@"worldLineColor" context:worldDataContext];
}


- (void) cameraMovedNotification:(NSNotification *) notification
{
    // [notification name] should always be @"cameraMoved", (if) not needed.
    // If this method is used for observing other notifications, then (if) needed.

    if ([[notification name] isEqualToString:@"cameraMoved"]) {
//        NSDictionary *userInfo = notification.userInfo;
//        NSString *moveType = [userInfo objectForKey:@"moveType"];
//        [self.sceneController transformAllObjects];
//        [self.drawingViewController.view setNeedsDisplay:YES];
        [self showScene];
    }
}


- (void)registerAsObserverForScene
{
    GKSSceneController *sceneController = self.sceneController;

    [sceneController addObserver:self forKeyPath:@"worldBackColor" options:NSKeyValueObservingOptionNew context:worldDataContext];
    [sceneController addObserver:self forKeyPath:@"worldFillColor" options:NSKeyValueObservingOptionNew context:worldDataContext];
    [sceneController addObserver:self forKeyPath:@"worldLineColor" options:NSKeyValueObservingOptionNew context:worldDataContext];

}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == worldDataContext) {
        [self.drawingViewController.view setNeedsDisplay:YES];

        NSString *changeType = @"Data change to world objects";
        NSLog(@"World Change: %@", changeType);
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[NSTableView class]]) {
        if ([notification.object tag] == 1) {            
            id selectionProxy = [self.sceneArrayController selection];
            NSInteger selectedObjectCount = [[self.sceneArrayController selectedObjects] count];
            if (selectedObjectCount == 1) {
                SceneEntity *sceneEnt = [selectionProxy valueForKey:@"self"];
                
                if (sceneEnt != nil) {
                    if (sceneEnt.objectID != self.currentSceneId) {
                        CameraEntity *camEnt = sceneEnt.toCamera;
                        self.cameraViewController.representedObject = camEnt;

                        NSSet *actorEnts = [sceneEnt toActors];
                        [self.sceneController castSetOfActors:actorEnts];
                        self.currentSceneId = sceneEnt.objectID;

                    }

                }
                
            }
            [self showScene];
        }
    }
    
}


- (void)showScene {
    [self.sceneController transformAllObjects];
    [self.drawingViewController refresh];
}


// MARK: ACTIONS

- (IBAction)updateVantage:(id)sender
{
    
    if ([sender isKindOfClass:[NSButton class]]) {
        
        // store current vantage properties for later
        NSInteger currentButonTag = self.currentVPIndex;
        NSDictionary *currentVantageProperties = [self gatherVantage];
        [self.vantagePoints replaceObjectAtIndex:currentButonTag withObject:currentVantageProperties];
        
        // restore new vantage point properties to application model objects
        GKSint newButtonTag = (GKSint)[sender tag];
        NSDictionary *vantage = [self.vantagePoints objectAtIndex:newButtonTag];
        
        GKSCameraRep *camera = self.itsContent.theCamera;
        
        camera.yaw = [vantage valueForKey:@"yaw"];
        camera.pitch = [vantage valueForKey:@"pitch"];
        camera.roll = [vantage valueForKey:@"roll"];
        
        camera.positionX = [vantage valueForKey:@"positionX"];
        camera.positionY = [vantage valueForKey:@"positionY"];
        camera.positionZ = [vantage valueForKey:@"positionZ"];
        
        camera.upX = [vantage valueForKey:@"upX"];
        camera.upY = [vantage valueForKey:@"upY"];
        camera.upZ = [vantage valueForKey:@"upZ"];
        
        camera.focalLength = [vantage valueForKey:@"focalLength"];
        camera.near = [vantage valueForKey:@"near"];
        camera.far = [vantage valueForKey:@"far"];
        camera.projectionType = [vantage valueForKey:@"projectionType"];
        
        self.currentVPIndex = newButtonTag;

        [self.sceneController setWorldVolumeG];
        [self showScene];
        
    }
     
}


- (IBAction)performVolumeResizeQuick:(id)sender
{
    [self.sceneController setWorldVolumeG];
    [self showScene];


}

- (IBAction)performAddSelectedToScene:(id)sender
{
    
    NSArray *objects = [self.meshArrayController selectedObjects];
    
    NSAssert(objects.count == 1, @"One mesh must be selected");
    
    if (objects.count == 1) {
        MeshEntity *meshEntity = [objects objectAtIndex:0];
        GKSint kind = meshEntity.meshID;
//        NSLog(@"Add mesh KIND: %d",kind);
        self.makeKinds = @(kind);
        [self performAddQuick:self];
    }
     
}

- (IBAction)performAddQuick:(id)sender {

    ActorEntity *actorEntity = [NSEntityDescription insertNewObjectForEntityForName:@"ActorEntity" inManagedObjectContext:self.managedObjectContext];
    actorEntity.kind  = self.makeKinds.intValue;
    actorEntity.locX = 0.0;
    actorEntity.locY = 0.0;
    actorEntity.locZ = 0.0;
    actorEntity.rotX = 0.0;
    actorEntity.rotY = 0.0;
    actorEntity.rotZ = 0.0;
    actorEntity.scaleX = 1.0;
    actorEntity.scaleY = 1.0;
    actorEntity.scaleZ = 1.0;
    NSString *newID = [[NSUUID UUID] UUIDString];
    actorEntity.name = newID;
    actorEntity.lineColor = self.contentLineColor;
    
    // get unique identifier for actor entity
    GKS3DActor *actor = [self.sceneController castActorFromEnt:actorEntity];
    [self.sceneController.actorWhitePages setObject:actor forKey:actorEntity.name];
    [self.sceneController.scene stageActor:actor];
    
    [self.actorArrayController addObject:actorEntity];

    [self showScene];

}

- (IBAction)performDeleteQuick:(id)sender {

    NSArray *objects = [self.actorArrayController selectedObjects];
        
    if (objects.count == 1) {
        ActorEntity *actorEntity = [objects objectAtIndex:0];

        // Pull the actor first. this should be a method on scenecontroller
        NSMutableSet *actors = self.sceneController.scene.toActors;
            
        NSString *actorName = actorEntity.name;
        GKS3DActor *actorPull = [self.sceneController.actorWhitePages objectForKey:actorName];
        
        NSAssert(actorPull != nil, @"actor object missing");
        [actors removeObject:actorPull];
    

        // remove selected actor entity
        [self.actorArrayController removeObject:actorEntity];
        [self showScene];
    }

}

- (IBAction)performUpdateQuick:(id)sender {

    NSArray *objects = [self.actorArrayController selectedObjects];
    
    NSAssert(objects.count == 1, @"One selection is mandatory");
    
    if (objects.count == 1) {
        ActorEntity *actEntity = [objects objectAtIndex:0];

        GKSvector3d pos = GKSMakeVector(actEntity.locX, actEntity.locY, actEntity.locZ);
        GKSvector3d rot = GKSMakeVector(actEntity.rotX, actEntity.rotY, actEntity.rotZ);
        GKSvector3d sca = GKSMakeVector(actEntity.scaleX, actEntity.scaleY, actEntity.scaleZ);
        
        NSString *actorName = actEntity.name;
        GKS3DActor *found3DActor = [self.sceneController.actorWhitePages objectForKey:actorName];
//        found3DActor = ( GKS3DActor *)actEntity.transientActor;
        [found3DActor setPosition:pos];
        [found3DActor setRotation:rot];
        [found3DActor setScaling:sca];
        
        found3DActor.lineColor = actEntity.lineColor;
        
        [found3DActor stageUpdateActor];

        [self showScene];
    }
}


- (IBAction)performLookQuick:(id)sender {
    [self.cameraViewController cameraSetViewLookAtG];
    [self showScene];
}


- (IBAction)performRenderQuick:(id)sender {
    GKSMeshMonger *monger = self.itsContent.theMonger;
    GKSMeshRep *meshRep = [monger getMeshRep:@3];
    GKSmesh_3 *mesh_ptr = meshRep.meshPtr;
    NSString *meshOffString = [monger convertMeshToOffString:mesh_ptr];

    NSLog(@"%@",meshOffString);


    [self showScene];
    
}

- (IBAction)setCenterObjects:(id)sender {
    
    if ([sender isKindOfClass:[NSButton class]]) {
        BOOL state = [sender state];
        
        if (state == NSOnState) {
            setMeshCenteredFlag(true);
        }
        
        if (state == NSOffState) {
            setMeshCenteredFlag(false);
        }       
    }
}


// MARK: Sorting

- (NSArray *)meshSortDescriptors
{
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"meshID" ascending:YES];
    return [NSArray arrayWithObject:sd];
    
}

- (NSArray *)sceneSortDescriptors
{
    NSSortDescriptor *sortBySceneTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    NSArray *sorts = [NSArray arrayWithObject:sortBySceneTitle];
    return sorts;
}

- (NSArray *)actorSortDescriptors
{
    NSSortDescriptor *sortByActorZ = [NSSortDescriptor sortDescriptorWithKey:@"locZ" ascending:NO];
    NSArray *sorts = [NSArray arrayWithObject:sortByActorZ];
    return sorts;
}


// MARK: OPEN/SAVE PANEL

- (IBAction)importDocument:(id)sender {

    NSOpenPanel* panel = [NSOpenPanel openPanel];
    panel.allowsMultipleSelection = NO;
    
    NSArray *contentArray = @[@"com.xephyr.off"];
    [panel setAllowedFileTypes:contentArray];

    
    // This method displays the panel and returns immediately.
    // The completion handler is called when the user selects an
    // item or cancels the panel.
    [panel beginWithCompletionHandler:^(NSInteger result){
        if (result == NSModalResponseOK) {
            NSURL* theURL = [[panel URLs] objectAtIndex:0];
            NSError *error;
     
            // load the mesh
            NSString *fileOffString = [[NSString alloc] initWithContentsOfURL:theURL encoding:NSUTF8StringEncoding error:&error];
            GKSMeshParser *parser = [GKSMeshParser sharedMeshParser];
            GKSmesh_3* mesh_ptr = [parser parseOFFMeshString:fileOffString error:&error];
            if (mesh_ptr != NULL) {
                
                GKSMeshMonger *monger = self.itsContent.theMonger;
                
                NSNumber *meshID = [monger nextID];
                NSString *theName = [[[[theURL path] lastPathComponent] stringByDeletingPathExtension] capitalizedString];
                GKSMeshRep *meshRep = [[GKSMeshRep alloc] initWithID:meshID andName:theName andMeshPtr:mesh_ptr andOffString:fileOffString];
                meshRep.meshName = [[[[theURL path] lastPathComponent] stringByDeletingPathExtension] capitalizedString];
                [monger insertMeshRep:meshRep intoMoc:self.managedObjectContext];
                
                
                [self.drawingViewController refresh];
                
            }
        }
    }];
}


- (NSDictionary *)gatherVantage
{
    NSDictionary *vantage = nil;
    GKSCameraRep *camera = self.cameraViewController.camera;
    
    NSMutableDictionary *collector = [[NSMutableDictionary alloc] init];
    [collector setValue:camera.upX forKey:@"upX"];
    [collector setValue:camera.upY forKey:@"upY"];
    [collector setValue:camera.upZ forKey:@"upZ"];

    [collector setValue:camera.positionX forKey:@"positionX"];
    [collector setValue:camera.positionY forKey:@"positionY"];
    [collector setValue:camera.positionZ forKey:@"positionZ"];
    
    [collector setValue:camera.yaw forKey:@"yaw"];
    [collector setValue:camera.pitch forKey:@"pitch"];
    [collector setValue:camera.roll forKey:@"roll"];
    
    [collector setValue:camera.focalLength forKey:@"focalLength"];
    [collector setValue:camera.near forKey:@"near"];
    [collector setValue:camera.far forKey:@"far"];
    
    [collector setValue:camera.projectionType forKey:@"projectionType"];
    
    vantage = [NSDictionary dictionaryWithDictionary:collector];
        
    return vantage;
}



@end

/*
@interface NSColorTransformer: NSValueTransformer {}
@end
@implementation NSColorTransformer
+ (Class)transformedValueClass {
    return [NSColor class];
}
+ (BOOL)allowsReverseTransformation {
    return YES;
}
- (id)transformedValue:(id)value {
    
    NSColor *theColor = nil;
    NSError *error;
    NSData *colorData = value;
    if (colorData != nil) {
        theColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:colorData error:&error];
    }

    return (value == nil) ? nil : theColor;
}

- (id)reverseTransformedValue:(id)value
{
    if (value == nil) return nil;
    
    NSData *colorData = nil;
    NSError *error;
    if(![value isKindOfClass:[NSColor class]]) {
        [NSException raise:NSInternalInconsistencyException format:@"Value (%@) is not an NSColor instance", [value class]];
    }
        
    colorData = [NSKeyedArchiver archivedDataWithRootObject:value requiringSecureCoding:YES error:&error];
    
    
    return colorData;
}

@end

*/
