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
#import "GKSScene.h"
#import "GKSMeshParser.h"

#define GKS_MAX_VANTAGE_PTS 6

@interface GKSContentViewController () {
    GKScontext3DPtr context;
}

@property (nonatomic, weak) IBOutlet NSView* cameraCustomView;

@property (strong) GKSContent *theContent;
@property (strong) NSColor* contentLineColor;
@property (strong) NSColor* contentFillColor;

@property (nonatomic, strong) GKSCameraRep* cameraRep;
@property (nonatomic, strong) GKS3DObjectRep* object3DRep;
@property (nonatomic, strong) GKSScene* theScene;

@property (assign) GKSint currentVantage;
@property (strong) NSMutableArray *vantageViews;

@end

static void *volumeSceneContext = &volumeSceneContext;
static void *worldDataContext = &worldDataContext;

@implementation GKSContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    
    // init gks

    
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


    // Get values world volume from data and device limits from view bounds
    GKSlimits_2 port_rect = [self.drawingViewController getPortLimits];
    
    // Set normalization value transforms
    gks_trans_set_device_viewport(&port_rect);
    [self.theScene transformWorldVolume];

    // Set all vantage points to the same default values
    self.currentVantage = 0;
    self.vantageViews = [[NSMutableArray alloc] initWithCapacity:GKS_MAX_VANTAGE_PTS];
    for (GKSint vantage_idx=0; vantage_idx<GKS_MAX_VANTAGE_PTS; vantage_idx++) {
        NSDictionary *vantageProperties = [self gatherVantage];
        [self.vantageViews addObject:vantageProperties];
    }

    
    [self setIsCenteredObject:@NO];
    [self registerAsObserverForScene];
        
    // notifications come after camera values have been set
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraMovedNotification:) name:@"cameraMoved" object:nil];
    
}

- (void)awakeFromNib {
    
    // MARK: INIT GKS
    context = gks_init();
    self.cameraViewController.context = context;

    // content should be populated by the document read methods
    GKSContent *content = self.representedObject;
    GKSScene *scene = content.theScene;
    GKSCameraRep *scene_camera = scene.camera;

    
    self.cameraRep = scene_camera;
    self.cameraViewController.representedObject = self.cameraRep;

    self.theScene = scene;
    self.drawingViewController.representedObject = self.theScene;

    NSError *error;
    NSData *colorData = [[NSUserDefaults standardUserDefaults] dataForKey:gksPrefPenColor];
    if (colorData != nil) {
        self.contentLineColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:colorData error:&error];
    }
    colorData = [[NSUserDefaults standardUserDefaults] dataForKey:gksPrefFillColor];
    if (colorData != nil) {
        self.contentFillColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:colorData error:&error];
    }
    
    // Instantiate one 3D object representation to act as a data entry buffer;
    // the data is used to create the actual 3D object added to the 3D world
    // later.
    self.object3DRep =  [[GKS3DObjectRep alloc] init];
    self.object3DRep.lineColor = self.contentLineColor;
    self.object3DRep.fillColor = self.contentFillColor;
    
    self.theContent = content;

}

- (void)viewDidLayout {

    // TODO: make sure all matrices have been initialized and set
    [self.theScene transformAllObjects];
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
        [self.theScene transformAllObjects];
        [self.drawingViewController.view setNeedsDisplay:YES];
    }
}


- (void)registerAsObserverForScene
{
    GKSScene *scene = self.theScene;

    [scene addObserver:self forKeyPath:@"worldBackColor" options:NSKeyValueObservingOptionNew context:worldDataContext];
    [scene addObserver:self forKeyPath:@"worldFillColor" options:NSKeyValueObservingOptionNew context:worldDataContext];
    [scene addObserver:self forKeyPath:@"worldLineColor" options:NSKeyValueObservingOptionNew context:worldDataContext];

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
    
    GKSkind kind = objRep.objectKind.intValue;
    GKSmesh_3 *theMesh = MeshOfKind(kind);
    
    if (theMesh != NULL) {
        GKSvector3d loc = [objRep positionVector];
        GKSvector3d rot = [objRep rotationVector];
        GKSvector3d sca = [objRep scaleVector];

        GKS3DObject *newGuy = [[GKS3DObject alloc] initWithMesh:theMesh atLocation:loc withRotation:rot andScale:sca];

        newGuy.lineColor = objRep.lineColor;
        newGuy.fillColor = objRep.fillColor;
        
        [newGuy computeAction];               // is this the time?

        [self.theScene add3DObject:newGuy];

        
        // TODO: Remove, for debug only
//        BOOL logFlag = NO;
//        if (logFlag) {
//            GKSmesh_3 *mesh = newGuy.getMeshPointer;
//            for (int i=0; i<mesh->polynum; i++) {
//                GKSint vertexCount = mesh->polygons[i][0];
//                NSLog(@"Mesh polygons: %d", vertexCount);
//                for (int j=0; j<vertexCount; j++) {
//                    // !!!: differs from draw_computed_object_3
//                    // vertex numbers in MESH file start at 1.
//                    // array indices are zero based 0.
//                    // so, -1 from vertex index -> array index.
//                    // 4,3,2,1 -> 3,2,1,0
//                    //
//                    GKSint vertexIndex = mesh->polygons[i][j+1];
//                    NSLog(@"Vertex Index: %d", vertexIndex);
//                }
//                NSLog(@".");
//            }
//        }
    
    }
     
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

        self.theScene.worldVolumeMinX = [vantage valueForKey:@"worldVolumeMinX"];
        self.theScene.worldVolumeMinY = [vantage valueForKey:@"worldVolumeMinY"];
        self.theScene.worldVolumeMinZ = [vantage valueForKey:@"worldVolumeMinZ"];
        self.theScene.worldVolumeMaxX = [vantage valueForKey:@"worldVolumeMaxX"];
        self.theScene.worldVolumeMaxY = [vantage valueForKey:@"worldVolumeMaxY"];
        self.theScene.worldVolumeMaxZ = [vantage valueForKey:@"worldVolumeMaxZ"];

        [self.theScene transformWorldVolume];
        
        [self.theScene transformAllObjects];
        [self.drawingViewController refresh];
        self.currentVantage = newTag;
    }
}

- (IBAction)performVolumeResizeQuick:(id)sender
{
    [self.theScene transformWorldVolume];
    [self.theScene transformAllObjects];
    [self.drawingViewController refresh];

}

- (IBAction)performAddQuick:(id)sender {

    // Add 3d object to the object list
    // some other controller needs to handle this?
    [self addObjectRepToScene:self.object3DRep];
    
    [self.drawingViewController refresh];

}

- (IBAction)performDeleteQuick:(id)sender {
    
    [self.theScene deleteLast3DObject];
    [self.drawingViewController refresh];

}


- (IBAction)performLookQuick:(id)sender {
    
    [self.cameraViewController cameraSetViewLookAtG];
    [self.theScene transformAllObjects];
    [self.drawingViewController refresh];
}


- (IBAction)performUpdateQuick:(id)sender {
    
    [self.theScene transformAllObjects];
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
                
                GKSvector3d loc = [self.object3DRep positionVector];
                GKSvector3d rot = [self.object3DRep rotationVector];
                GKSvector3d sca = [self.object3DRep scaleVector];
                
                GKS3DObject *customObj = [[GKS3DObject alloc] initWithMesh:mesh_ptr atLocation:loc withRotation:rot andScale:sca];

                // copy data from Rep to Obj3D
                customObj.lineColor = [self.object3DRep lineColor];
                customObj.fillColor = [self.object3DRep fillColor];
    
                [customObj computeAction];
                
                [self.theScene add3DObject:customObj];
                [self.drawingViewController refresh];
                
            }
        }
    }];
}

- (NSDictionary *)gatherVantage
{
    NSDictionary *vantage = nil;
    
    GKSCameraRep *camera = self.cameraRep;
    GKSScene *scene = self.theScene;
    
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
    
    [collector setValue:scene.worldVolumeMinX forKey:@"worldVolumeMinX"];
    [collector setValue:scene.worldVolumeMinY forKey:@"worldVolumeMinY"];
    [collector setValue:scene.worldVolumeMinZ forKey:@"worldVolumeMinZ"];

    [collector setValue:scene.worldVolumeMaxX forKey:@"worldVolumeMaxX"];
    [collector setValue:scene.worldVolumeMaxY forKey:@"worldVolumeMaxY"];
    [collector setValue:scene.worldVolumeMaxZ forKey:@"worldVolumeMaxZ"];

    vantage = [NSDictionary dictionaryWithDictionary:collector];
        
    return vantage;
}


@end
