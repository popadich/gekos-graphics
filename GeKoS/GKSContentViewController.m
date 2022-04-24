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
#import "GKS3DObject.h"
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
@property (strong) NSMutableArray *vantageViews;


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
    self.vantageViews = [[NSMutableArray alloc] initWithCapacity:GKS_MAX_VANTAGE_PTS];
    for (GKSint vantage_idx=0; vantage_idx<GKS_MAX_VANTAGE_PTS; vantage_idx++) {
        NSDictionary *vantageProperties = [self gatherVantage];
        [self.vantageViews addObject:vantageProperties];
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
            [object3DRep rotateX:0.0 Y:rad Z:0.0];
            [self.sceneController add3DObjectRep:object3DRep];

            rad += DEG_TO_RAD * 35;
        }
    }
    
        
    // notifications come after camera values have been set
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraMovedNotification:) name:@"cameraMoved" object:nil];
    
}

- (void)awakeFromNib {
    
    // content should be populated by the document read methods
    GKSContent *content = self.representedObject;
    
    self.itsContent = content;
    
    // allocate scenes array and add scenes (only one)
    self.toScenes = [[NSMutableArray alloc] init];
    [self.toScenes addObject:content.scene];

    // set the current scene on the scene controller
    self.sceneController.scene = content.scene;
    
    // TODO: monger singleton?
    self.sceneController.monger = content.meshMonger;


    
    GKSCameraRep *scene_camera = content.camera;

    self.cameraRep = scene_camera;
    self.cameraViewController.representedObject = scene_camera;

    // TODO: pass a sceneRep instead
    self.drawingViewController.representedObject = content.scene;

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
        [self.vantageViews replaceObjectAtIndex:currentTag withObject:currentVantageProperties];
        
        GKSint newTag = (GKSint)[sender tag];
        
        
        NSDictionary *vantage = [self.vantageViews objectAtIndex:newTag];
        
        NSNumber *yaw = [vantage valueForKey:@"yaw"];
        NSNumber *pitch = [vantage valueForKey:@"pitch"];
        NSNumber *roll = [vantage valueForKey:@"roll"];

        NSNumber *positionX = [vantage valueForKey:@"positionX"];
        NSNumber *positionY = [vantage valueForKey:@"positionY"];
        NSNumber *positionZ = [vantage valueForKey:@"positionZ"];

        NSNumber *upX = [vantage valueForKey:@"upX"];
        NSNumber *upY = [vantage valueForKey:@"upY"];
        NSNumber *upZ = [vantage valueForKey:@"upZ"];
        
        NSNumber *focalLength = [vantage valueForKey:@"focalLength"];
        NSNumber *near = [vantage valueForKey:@"near"];
        NSNumber *far = [vantage valueForKey:@"far"];
        
        NSNumber *projectionType = [vantage valueForKey:@"projectionType"];

        self.cameraRep.yaw = yaw;
        self.cameraRep.pitch = pitch;
        self.cameraRep.roll = roll;
        
        self.cameraRep.positionX = positionX;
        self.cameraRep.positionY = positionY;
        self.cameraRep.positionZ = positionZ;
        
        self.cameraRep.upX = upX;
        self.cameraRep.upY = upY;
        self.cameraRep.upZ = upZ;
        
        self.cameraRep.focalLength = focalLength;
        self.cameraRep.near = near;
        self.cameraRep.far = far;
        self.cameraRep.projectionType = projectionType;

        self.sceneController.worldVolumeMinX = [vantage valueForKey:@"worldVolumeMinX"];
        self.sceneController.worldVolumeMinY = [vantage valueForKey:@"worldVolumeMinY"];
        self.sceneController.worldVolumeMinZ = [vantage valueForKey:@"worldVolumeMinZ"];
        self.sceneController.worldVolumeMaxX = [vantage valueForKey:@"worldVolumeMaxX"];
        self.sceneController.worldVolumeMaxY = [vantage valueForKey:@"worldVolumeMaxY"];
        self.sceneController.worldVolumeMaxZ = [vantage valueForKey:@"worldVolumeMaxZ"];

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
                
                NSNumber *meshID = [self.sceneController.monger nextID];
                GKSMeshRep *meshRep = [[GKSMeshRep alloc] initWithID:meshID andMeshPtr:mesh_ptr];
                [self.sceneController.monger addMeshRep:meshRep];
                
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
    GKSSceneController *sceneController = self.sceneController;
    
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
    
    [collector setValue:sceneController.worldVolumeMinX forKey:@"worldVolumeMinX"];
    [collector setValue:sceneController.worldVolumeMinY forKey:@"worldVolumeMinY"];
    [collector setValue:sceneController.worldVolumeMinZ forKey:@"worldVolumeMinZ"];

    [collector setValue:sceneController.worldVolumeMaxX forKey:@"worldVolumeMaxX"];
    [collector setValue:sceneController.worldVolumeMaxY forKey:@"worldVolumeMaxY"];
    [collector setValue:sceneController.worldVolumeMaxZ forKey:@"worldVolumeMaxZ"];

    vantage = [NSDictionary dictionaryWithDictionary:collector];
        
    return vantage;
}


@end
