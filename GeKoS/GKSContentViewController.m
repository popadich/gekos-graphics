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
#import "MeshEntity+CoreDataClass.h"
#import "GeKoS+CoreDataModel.h"


#define GKS_MAX_VANTAGE_PTS 6

@interface GKSContentViewController ()

@property (nonatomic, weak) IBOutlet NSView* cameraCustomView;
@property (weak) IBOutlet NSArrayController *actorArrayController;
@property (weak) IBOutlet NSArrayController *sceneArrayController;
@property (weak) IBOutlet NSArrayController *meshArrayController;
@property (weak) IBOutlet NSArrayController *storyBoardArrayController;

@property (strong) NSArray *meshSortDescriptors;
@property (strong) NSArray *sceneSortDescriptors;
@property (strong) NSArray *actorSortDescriptors;

@property (strong) GKSContent *itsContent;

@property (strong) NSNumber* makePosX;
@property (strong) NSNumber* makePosY;
@property (strong) NSNumber* makePosZ;
@property (strong) NSNumber* makeRotX;
@property (strong) NSNumber* makeRotY;
@property (strong) NSNumber* makeRotZ;
@property (strong) NSNumber* makeScaleX;
@property (strong) NSNumber* makeScaleY;
@property (strong) NSNumber* makeScaleZ;

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
    
    // Place camera controller view into custom camera view
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
    
    // Fetch the first available story board
    NSError *error = nil;
    NSArray *results = nil;
    NSFetchRequest *fetchStoryRequest = [StoryBoardEntity fetchRequest];
  results = [self.managedObjectContext executeFetchRequest:fetchStoryRequest error:&error];
  if (!results) {
      NSLog(@"Error fetching storyboard objects: %@\n%@", [error localizedDescription], [error userInfo]);
      abort();
  }
  if (results.count == 1) {
      StoryBoardEntity *story = [results objectAtIndex:0];
      // feed the monger with meshes
      for (MeshEntity *meshEnt in story.toMeshes) {
          GKSMeshRep *meshRep = meshEnt.meshPointer;
          [self.itsContent.theMonger addMeshRepToMongerMenu:meshRep];
      }
  }
    
    // Set all vantage points to the same default values
    self.currentVPIndex = 0;
    self.vantagePoints = [[NSMutableArray alloc] initWithCapacity:GKS_MAX_VANTAGE_PTS];
    for (GKSint vantage_idx=0; vantage_idx<GKS_MAX_VANTAGE_PTS; vantage_idx++) {
        NSDictionary *vantageProperties = [self gatherVantage];
        [self.vantagePoints addObject:vantageProperties];
    }
    
    [self setIsCenteredObject:@NO];
    [self setMakePosX:@0.0];
    [self setMakePosY:@0.0];
    [self setMakePosZ:@0.0];
    [self setMakeRotX:@0.0];
    [self setMakeRotY:@0.0];
    [self setMakeRotZ:@0.0];
    [self setMakeScaleX:@1.0];
    [self setMakeScaleY:@1.0];
    [self setMakeScaleZ:@1.0];
    [self registerAsObserverForScene];
    
    // notifications come after camera values have been set
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraMovedNotification:) name:@"cameraMoved" object:nil];
    
    
    // Sorting
    self.meshSortDescriptors = [self makeMeshSortDescriptors];;
    self.sceneSortDescriptors = [self makeSceneSortDescriptors];
    self.actorSortDescriptors = [self makeActorSortDescriptors];
    
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
        
        ActorEntity *actorEntity = [NSEntityDescription insertNewObjectForEntityForName:@"ActorEntity" inManagedObjectContext:self.managedObjectContext];
        actorEntity.kind  = kind;
        actorEntity.locX = self.makePosX.doubleValue;
        actorEntity.locY = self.makePosY.doubleValue;
        actorEntity.locZ = self.makePosZ.doubleValue;
        actorEntity.rotX = self.makeRotX.doubleValue;
        actorEntity.rotY = self.makeRotY.doubleValue;
        actorEntity.rotZ = self.makeRotZ.doubleValue;
        actorEntity.scaleX = self.makeScaleX.doubleValue;
        actorEntity.scaleY = self.makeScaleY.doubleValue;
        actorEntity.scaleZ = self.makeScaleZ.doubleValue;
        actorEntity.actorID = [NSUUID UUID];
        actorEntity.lineColor = self.itsContent.contentLineColor;
        
        
        // TODO: check order
        // looks like all other attributes need to be set first.
        GKS3DActor *actor = actorEntity.transientActor;
        
        // make this part of the init?
        actor.lineColor = actorEntity.lineColor;

        [self.sceneController.scene stageActor:actor];
        
        [self.actorArrayController addObject:actorEntity];
        [self showScene];
    }
     
}


- (IBAction)performDeleteQuick:(id)sender {

    NSArray *objects = [self.actorArrayController selectedObjects];
    NSAssert(objects.count == 1, @"One selection is mandatory");
    
    if (objects.count == 1) {
        ActorEntity *actorEntity = [objects objectAtIndex:0];

        // Pull the actor first. this should be a method on scenecontroller
        NSMutableSet *actors = self.sceneController.scene.toActors;
            
        GKS3DActor *actorPull = actorEntity.transientActor;
        
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
        
        GKS3DActor *found3DActor = actEntity.transientActor;
        
        if (found3DActor != nil) {
            [found3DActor setPosition:pos];
            [found3DActor setRotation:rot];
            [found3DActor setScaling:sca];
            
            found3DActor.lineColor = actEntity.lineColor;
            
            [found3DActor stageUpdateActor];

            [self showScene];
        }
    }
}


- (IBAction)performLookQuick:(id)sender {
    [self.cameraViewController cameraSetViewLookAtG];
    [self showScene];
}


- (IBAction)performRenderQuick:(id)sender {
    GKSMeshMonger *monger = self.itsContent.theMonger;
    GKSmesh_3 *mesh_ptr = SphereMesh();
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

- (NSArray *)makeMeshSortDescriptors
{
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"meshID" ascending:YES];
    return [NSArray arrayWithObject:sd];
    
}

- (NSArray *)makeSceneSortDescriptors
{
    NSSortDescriptor *sortBySceneTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    NSArray *sorts = [NSArray arrayWithObject:sortBySceneTitle];
    return sorts;
}

- (NSArray *)makeActorSortDescriptors
{
    NSSortDescriptor *sortByActorZ = [NSSortDescriptor sortDescriptorWithKey:@"locZ" ascending:YES];
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
    NSArray *selectedStoryArr = [self.storyBoardArrayController selectedObjects];
    if (selectedStoryArr.count == 1) {
        StoryBoardEntity *storyBoardEnt = selectedStoryArr[0];
        [panel beginWithCompletionHandler:^(NSInteger result){
            if (result == NSModalResponseOK) {
                NSURL* theURL = [[panel URLs] objectAtIndex:0];
                NSError *error;
         
                // load the mesh
                NSString *fileOffString = [[NSString alloc] initWithContentsOfURL:theURL encoding:NSUTF8StringEncoding error:&error];

                if (fileOffString != nil) {
                    
                    GKSMeshMonger *monger = self.itsContent.theMonger;
                    NSNumber *meshID = [monger nextID];
                    NSString *theName = [[[[theURL path] lastPathComponent] stringByDeletingPathExtension] capitalizedString];
                    
                    GKSMeshRep *meshRep = [[GKSMeshRep alloc] initWithID:meshID andName:theName andOffString:fileOffString];

                    MeshEntity *meshEnt = [NSEntityDescription insertNewObjectForEntityForName:@"MeshEntity" inManagedObjectContext:self.managedObjectContext];
                    
                    [meshEnt setMeshPointer:meshRep];
                    [storyBoardEnt addToMeshesObject:meshEnt];
                    
                    [monger addMeshRepToMongerMenu:meshRep];
                }
            }
        }];
        
    }

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
