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

#import "GKS3DObjectRep.h"
#import "GKS3DActor.h"
#import "GKSSceneController.h"
#import "GKSMeshParser.h"

#define GKS_MAX_VANTAGE_PTS 6

@interface GKSContentViewController ()

@property (nonatomic, weak) IBOutlet NSView* cameraCustomView;

@property (strong) GKSContent *itsContent;

@property (strong) NSColor* contentLineColor;
@property (strong) NSColor* contentFillColor;

@property (nonatomic, strong) GKSCameraRep* cameraRep;
@property (nonatomic, strong) GKS3DObjectRep* object3DRep;

@property (assign) GKSint currentVantage;
@property (strong) NSMutableArray *vantagePoints;


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
    self.currentVantage = 0;
    self.vantagePoints = [[NSMutableArray alloc] initWithCapacity:GKS_MAX_VANTAGE_PTS];
    for (GKSint vantage_idx=0; vantage_idx<GKS_MAX_VANTAGE_PTS; vantage_idx++) {
        NSDictionary *vantageProperties = [self gatherVantage];
        [self.vantagePoints addObject:vantageProperties];
    }

    
    [self setIsCenteredObject:@YES];
    [self registerAsObserverForScene];
    
    // TODO: remove when done with playing
    BOOL playing = YES;
    if (playing) {
        setMeshCenteredFlag(self.isCenteredObject.boolValue);
        GKSfloat rad = 0.0;
        for (int i=1; i<8; i++) {
            GKS3DObjectRep *object3DRep = [[GKS3DObjectRep alloc] init];
            [object3DRep locateX:0.0 Y:i%2 Z: -2.0 * i];
//            [object3DRep rotateX:0.0 Y:rad Z:0.0];
//            [object3DRep scaleX:(0.5 * i) Y:(0.5 * i) Z:(0.5 * i)];
            [self.sceneController add3DObjectRep:object3DRep];

            rad += 35;
        }
    }
    
        
    // notifications come after camera values have been set
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraMovedNotification:) name:@"cameraMoved" object:nil];
    
}

- (void)awakeFromNib {
    
    // content should be populated by the document read methods
    GKSContent *content = self.representedObject;
    GKSStoryBoardRep *storyBoard = content.storyBoard;

    
    // set scenes array to the story board scenes array
    NSMutableArray *keyScenes = storyBoard.keyScenes;
    [self willChangeValueForKey:@"toScenes"];
    self.toScenes = keyScenes;
    [self didChangeValueForKey:@"toScenes"];

    self.cameraRep = content.camera;

    // set the scene controller's scene, part of an initializer maybe?
    self.sceneController.scene = [storyBoard sceneOne];

    self.cameraViewController.representedObject = content.camera;
    self.drawingViewController.representedObject = [storyBoard sceneOne];


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
    
    
    // Instantiate one 3D object representation to act as a data entry buffer;
    // the data is used to create the actual 3D object added to the 3D world
    // later.
    self.object3DRep =  [[GKS3DObjectRep alloc] init];
    self.object3DRep.lineColor = self.contentLineColor;
    self.object3DRep.fillColor = self.contentFillColor;

    
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
- (void)addObjectRepToScene:(GKS3DObjectRep *)objRep
{
    // use ObjRep to create an Obj3D
    
    // put a copy of the 3d object rep into an array
    GKS3DObjectRep *repCopy = [objRep copy];
    [self.sceneController add3DObjectRep:repCopy];
    
    [self.drawingViewController refresh];
     
}


// MARK: ACTIONS
- (IBAction)updateVantage:(id)sender
{
    if ([sender isKindOfClass:[NSButton class]]) {
        
        GKSint currentTag = self.currentVantage;
        NSDictionary *currentVantageProperties = [self gatherVantage];
        [self.vantagePoints replaceObjectAtIndex:currentTag withObject:currentVantageProperties];
        
        GKSint newTag = (GKSint)[sender tag];
        NSDictionary *vantage = [self.vantagePoints objectAtIndex:newTag];
        
        self.cameraRep.yaw = [vantage valueForKey:@"yaw"];
        self.cameraRep.pitch = [vantage valueForKey:@"pitch"];
        self.cameraRep.roll = [vantage valueForKey:@"roll"];
        
        self.cameraRep.positionX = [vantage valueForKey:@"positionX"];
        self.cameraRep.positionY = [vantage valueForKey:@"positionY"];
        self.cameraRep.positionZ = [vantage valueForKey:@"positionZ"];
        
        self.cameraRep.upX = [vantage valueForKey:@"upX"];
        self.cameraRep.upY = [vantage valueForKey:@"upY"];
        self.cameraRep.upZ = [vantage valueForKey:@"upZ"];
        
        self.cameraRep.focalLength = [vantage valueForKey:@"focalLength"];
        self.cameraRep.near = [vantage valueForKey:@"near"];
        self.cameraRep.far = [vantage valueForKey:@"far"];
        self.cameraRep.projectionType = [vantage valueForKey:@"projectionType"];
        
        [self.sceneController setWorldVolumeG];
        [self.sceneController transformAllObjects];
        [self.drawingViewController refresh];
        self.currentVantage = newTag;
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
    [self addObjectRepToScene:self.object3DRep];
    
    [self.drawingViewController refresh];

}

- (IBAction)performDeleteQuick:(id)sender {
    
    [self.sceneController deleteLastObject];
    [self.drawingViewController refresh];

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
                
                GKS3DObjectRep *repCopy = [self.object3DRep copy];
                repCopy.objectKind = meshID;
                [self.sceneController add3DObjectRep:repCopy];
                
                [self.drawingViewController refresh];
                
            }
        }
    }];
}

- (NSDictionary *)gatherVantage
{
    NSDictionary *vantage = nil;
    GKSCameraRep *camera = self.cameraRep;
    
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
