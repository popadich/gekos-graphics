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


@interface GKSContentViewController ()

@property (nonatomic, weak) IBOutlet NSView* cameraCustomView;

@property (strong) NSColor* contentLineColor;
@property (strong) NSColor* contentFillColor;

@property (nonatomic, strong) GKSCameraRep* cameraRep;
@property (nonatomic, strong) GKS3DObjectRep* object3DRep;
@property (nonatomic, strong) GKSScene* theScene;

@end

static void *volumeSceneContext = &volumeSceneContext;
static void *worldDataContext = &worldDataContext;

@implementation GKSContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    // init gks
    // this needs to be done early in the application lifecycle
    gks_init();
    
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

    
    NSError *error;
    NSData *colorData = [[NSUserDefaults standardUserDefaults] dataForKey:gksPrefPenColor];
    if (colorData != nil) {
        self.contentLineColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:colorData error:&error];
    }
    colorData = [[NSUserDefaults standardUserDefaults] dataForKey:gksPrefFillColor];
    if (colorData != nil) {
        self.contentFillColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:colorData error:&error];
    }
    
    // This gives a volume bounds to the GKS 3D world, also add
    // functions to adjust this volume and maybe initialize there.
    GKSlimits_3 world_volume = [self.theScene worldVolumeLimits];
    
    // esoteric calls to set world volume
    // this seems very cumbersome;
    NSView *drawView = self.drawingViewController.view;
    NSRect viewRect = drawView.frame;
    
    GKSlimits_2 port_rect;
    port_rect.xmin = viewRect.origin.x;
    port_rect.xmax = viewRect.size.width;
    port_rect.ymin = viewRect.origin.y;
    port_rect.ymax = viewRect.size.height;
    
    // Set normalization value transform from world to camera to view coordinates
    // needs to be called when either view port rect or world volume changes.
    gks_trans_store_at_idx(0, port_rect, world_volume);
    
    // Store one 3D object representation to act as a data entry buffer;
    // the data is used to create the actual 3D object added to the 3D world
    //
    self.object3DRep =  [[GKS3DObjectRep alloc] init];
    self.object3DRep.lineColor = self.contentLineColor;
    self.object3DRep.fillColor = self.contentFillColor;

    [self setIsCenteredObject:@NO];
    
    [self registerAsObserverForScene];
        
    // notifications come after camera values have been set
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraMovedNotification:) name:@"cameraMoved" object:nil];
    
}

- (void)awakeFromNib {
    // content should be populated by the document read methods
    GKSContent *content = self.representedObject;
    
    GKSScene *scene = content.theScene;
    GKSCameraRep *scene_camera = scene.camera;
    
    self.cameraRep = scene_camera;
    self.cameraViewController.representedObject = self.cameraRep;

    self.theScene = scene;
    self.drawingViewController.representedObject = self.theScene;

    
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
    // TODO: verify
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
    
    GKSobjectKind kind = objRep.objectKind.intValue;
    GKSmesh_3 *theMesh = MeshOfKind(kind);
    GKSvector3d loc = [objRep positionVector];
    GKSvector3d rot = [objRep rotationVector];
    GKSvector3d sca = [objRep scaleVector];

    GKS3DObject *newGuy = [[GKS3DObject alloc] initWithMesh:theMesh atLocation:loc withRotation:rot andScale:sca];

    newGuy.lineColor = objRep.lineColor;
    newGuy.fillColor = objRep.fillColor;
    
    [newGuy computeAction];               // is this the time?

    [self.theScene add3DObject:newGuy];
    
}


- (IBAction)performVolumeResizeQuick:(id)sender
{
    // very esoteric calls here, make this simpler
    GKSlimits_3 volume = [self.theScene worldVolumeLimits];
    
    //TODO: remove hard coded index
    gks_trans_adjust_world_volume(0, &volume);
    
    [self.theScene transformAllObjects];
    [self.drawingViewController.view setNeedsDisplay:YES];
//        NSLog(@"Scene Change: %lf, %lf, %lf, %lf, %lf, %lf", volume.xmin, volume.xmax, volume.ymin, volume.ymax, volume.zmin, volume.zmax);

}

- (IBAction)performAddQuick:(id)sender {

    // Add 3d object to the object list
    // some other controller needs to handle this?
    [self addObjectRepToScene:self.object3DRep];
    
    [self.drawingViewController.view setNeedsDisplay:YES];

}

- (IBAction)performDeleteQuick:(id)sender {
    
    [self.theScene deleteLast3DObject];
    [self.drawingViewController.view setNeedsDisplay:YES];

}


- (IBAction)performLookQuick:(id)sender {
    
    [self.cameraViewController camerSetViewLookAtG];
    [self.theScene transformAllObjects];
    [self.drawingViewController.view setNeedsDisplay:YES];
}


- (IBAction)performUpdateQuick:(id)sender {
    
    [self.theScene transformAllObjects];
    [self.drawingViewController.view setNeedsDisplay:YES];
}

@end
