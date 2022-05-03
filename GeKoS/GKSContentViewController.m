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
#import "GKS3DObjectRep.h"
#import "GKS3DActor.h"
#import "GKSSceneController.h"
#import "GKSMeshParser.h"
#import "ActorEntity+CoreDataClass.h"


#define GKS_MAX_VANTAGE_PTS 6

@interface GKSContentViewController ()

@property (nonatomic, weak) IBOutlet NSView* cameraCustomView;
@property (weak) IBOutlet NSArrayController *objectArrayController;
@property (weak) IBOutlet NSArrayController *actorArrayController;

@property (strong) GKSContent *itsContent;

@property (strong) NSColor* contentLineColor;
@property (strong) NSColor* contentFillColor;

@property (assign) NSInteger currentVPIndex;
@property (strong) NSMutableArray *vantagePoints;


@property (strong) NSMutableSet *currentActorSet;

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

    // Set all vantage points to the same default values
    self.currentVPIndex = 0;
    self.vantagePoints = [[NSMutableArray alloc] initWithCapacity:GKS_MAX_VANTAGE_PTS];
    for (GKSint vantage_idx=0; vantage_idx<GKS_MAX_VANTAGE_PTS; vantage_idx++) {
        NSDictionary *vantageProperties = [self gatherVantage];
        [self.vantagePoints addObject:vantageProperties];
    }

    
    [self setIsCenteredObject:@YES];
    [self setMakeKinds:@(kPyramidKind)];
    [self registerAsObserverForScene];
    

    // Stage actors for all Actor entities
    NSFetchRequest *request = [ActorEntity fetchRequest];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (!results) {
        NSLog(@"Error fetching Employee objects: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    for (ActorEntity *act in results) {
        [self.sceneController stageActorForEnt:act];
    }
        
    // notifications come after camera values have been set
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraMovedNotification:) name:@"cameraMoved" object:nil];
    
}

- (void)awakeFromNib {
    
    // content should be populated by the document read methods
    GKSContent *content = self.representedObject;
    GKSStoryBoardRep *storyBoard = content.storyBoard;
    self.managedObjectContext = content.managedObjectContext;

    [self willChangeValueForKey:@"itsStoryBoard"];
    self.itsStoryBoard = storyBoard;
    [self didChangeValueForKey:@"itsStoryBoard"];

 
    // set the scene controller's scene, part of an initializer maybe?
    GKSSceneRep *sceneOne = [storyBoard sceneOne];
    self.sceneController.scene = sceneOne;
    self.currentActorSet = sceneOne.toActors;
    
    self.cameraViewController.representedObject = sceneOne.toCamera;
    self.drawingViewController.representedObject = sceneOne;

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
    
    self.itsContent = content;

}

- (void)viewDidLayout {

    // TODO: make sure all matrices have been initialized and set
    [self.sceneController transformAllObjects];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void) cameraMovedNotification:(NSNotification *) notification
{
    // [notification name] should always be @"cameraMoved", (if) not needed.
    // If this method is used for observing other notifications, then (if) needed.

    if ([[notification name] isEqualToString:@"cameraMoved"]) {
//        NSDictionary *userInfo = notification.userInfo;
//        NSString *moveType = [userInfo objectForKey:@"moveType"];
        [self.sceneController transformAllObjects];
        [self.drawingViewController.view setNeedsDisplay:YES];
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

// Add a 3d object to the scene/world
- (void)addObjectRepToScene
{
    
    GKSvector3d loc = GKSMakeVector(0.0, 0.0, 0.0);
    GKSvector3d rot = GKSMakeVector(0.0, 0.0, 0.0);
    GKSvector3d sca = GKSMakeVector(1.0, 1.0, 1.0);

    GKS3DObjectRep *newObjectRep = [[GKS3DObjectRep alloc] initWithKind:self.makeKinds.intValue atLocation:loc withRotation:rot andScale:sca];

    newObjectRep.fillColor = self.contentFillColor;
    newObjectRep.lineColor = self.contentLineColor;
    [self.sceneController add3DObjectRep:newObjectRep];
    [self.sceneController stageActorForRep:newObjectRep];
    
    [self.drawingViewController refresh];
     
}

- (void)addActorEntToScene
{
    ActorEntity *actor = [NSEntityDescription insertNewObjectForEntityForName:@"ActorEntity" inManagedObjectContext:self.managedObjectContext];
    actor.kind  = self.makeKinds.intValue;
    actor.locX = 0.0;
    actor.locY = 0.0;
    actor.locZ = 0.0;
    actor.rotX = 0.0;
    actor.rotY = 0.0;
    actor.rotZ = 0.0;
    actor.scaleX = 1.0;
    actor.scaleY = 1.0;
    actor.scaleZ = 1.0;
    actor.name = [NSString stringWithFormat:@"new actor"];
    
    [self.sceneController stageActorForEnt:actor];
    [self.actorArrayController addObject:actor];
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
        
        GKSSceneRep *scene = self.sceneController.scene;
        GKSCameraRep *camera = scene.toCamera;
        
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
        
        [self.sceneController setWorldVolumeG];
        [self.sceneController transformAllObjects];
        [self.drawingViewController refresh];
        self.currentVPIndex = newButtonTag;
    }
}

- (IBAction)performVolumeResizeQuick:(id)sender
{
    [self.sceneController setWorldVolumeG];
    [self.sceneController transformAllObjects];
    [self.drawingViewController refresh];

}

- (IBAction)performAddQuick:(id)sender {

    // Add 3d object to the object list
    // some other controller needs to handle this?
//    [self addObjectRepToScene];
    [self addActorEntToScene];
    
    [self.drawingViewController refresh];

}

- (IBAction)performDeleteQuick:(id)sender {

    NSArray *objects = [self.actorArrayController selectedObjects];
    
    NSAssert(objects.count == 1, @"One selection is mandatory");
    
    if (objects.count == 1) {
        ActorEntity *act = [objects objectAtIndex:0];

        // Pull the actor first
        [self.sceneController unstageActorEnt:act];
        
        // removes selected object
        [self.actorArrayController removeObject:act];
        [self.drawingViewController refresh];
    }

}

- (IBAction)performUpdateQuick:(id)sender {

    NSArray *objects = [self.objectArrayController selectedObjects];
    
    NSAssert(objects.count == 1, @"One selection is mandatory");
    
    if (objects.count == 1) {
        GKS3DObjectRep *objectRep = [objects objectAtIndex:0];
        //    GKS3DActor *selectedActor = [self.objectArrayController.selection valueForKey:@"actorObject"];
        GKS3DActor *selectedActor = objectRep.actorObject;
        
        GKSvector3d pos = objectRep.positionVector;
        GKSvector3d rot = objectRep.rotationVector;
        GKSvector3d sca = objectRep.scaleVector;
        
        [selectedActor setPosition:pos];
        [selectedActor setRotation:rot];
        [selectedActor setScaling:sca];
        
        [selectedActor stageUpdateActor];

        [self.sceneController transformAllObjects];
        [self.drawingViewController refresh];
    }
    
    

}


- (IBAction)performLookQuick:(id)sender {
    
    [self.cameraViewController cameraSetViewLookAtG];
    [self.sceneController transformAllObjects];
    [self.drawingViewController refresh];
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
            GKSMeshParser *parser = [GKSMeshParser sharedMeshParser];
            GKSmesh_3* mesh_ptr = [parser parseOFFMeshFile:theURL error:&error];
            if (mesh_ptr != NULL) {
                
                GKSMeshMonger *monger = [GKSMeshMonger sharedMeshMonger];
                
                NSNumber *meshID = [monger nextID];
                GKSMeshRep *meshRep = [[GKSMeshRep alloc] initWithID:meshID andMeshPtr:mesh_ptr];
                [monger addMeshRep:meshRep];
                
                // TODO: this is a cube
                GKS3DObjectRep *objRep = [[GKS3DObjectRep alloc] init];
                objRep.kind = meshID;
                [self.sceneController add3DObjectRep:objRep];
                
                [self.drawingViewController refresh];
                
            }
        }
    }];
}

- (NSDictionary *)gatherVantage
{
    NSDictionary *vantage = nil;
    GKSSceneRep *scene = self.sceneController.scene;
    GKSCameraRep *camera = scene.toCamera;
    
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
