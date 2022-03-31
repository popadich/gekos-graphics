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


static void *ObserverPoistionContext = &ObserverPoistionContext;
static void *ObserverPlaneNormalContext = &ObserverPlaneNormalContext;
static void *ObserverProjectionContext = &ObserverProjectionContext;


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
    GKSlimits_3 world_volume;
    world_volume.xmin = [[NSUserDefaults standardUserDefaults] doubleForKey:gksPrefWorldVolumeMinX];
    world_volume.xmax = [[NSUserDefaults standardUserDefaults] doubleForKey:gksPrefWorldVolumeMaxX];
    world_volume.ymin = [[NSUserDefaults standardUserDefaults] doubleForKey:gksPrefWorldVolumeMinY];
    world_volume.ymax = [[NSUserDefaults standardUserDefaults] doubleForKey:gksPrefWorldVolumeMaxY];
    world_volume.zmin = [[NSUserDefaults standardUserDefaults] doubleForKey:gksPrefWorldVolumeMinZ];
    world_volume.zmax = [[NSUserDefaults standardUserDefaults] doubleForKey:gksPrefWorldVolumeMaxZ];
    
    // esoteric calls to set world volume
    // this seems very cumbersome;
    NSView *drawView = self.drawingViewController.view;
    NSRect viewRect = drawView.frame;
    GKSfloat r_min = viewRect.origin.x;              // r_min = WindowRect.left;
    GKSfloat r_max = viewRect.size.width;            // r_max = WindowRect.right;
    GKSfloat s_min = viewRect.origin.y;              // s_min = WindowRect.bottom;
    GKSfloat s_max = viewRect.size.height;            // s_max = WindowRect.top;
    
    // Set normalization value transform from world to camera to view coordinates
    gks_trans_create_transform_at_idx(0, r_min, r_max, s_min, s_max, world_volume);
    
    // Store one 3D object representation to act as a data entry buffer;
    // the data is used to create the actual 3D object added to the 3D world
    //
    self.object3DRep =  [[GKS3DObjectRep alloc] init];
    self.object3DRep.lineColor = self.contentLineColor;
    self.object3DRep.fillColor = self.contentFillColor;

    [self registerAsObserverForCamera];
    [self setIsCenteredObject:@NO];
    
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


- (void)registerAsObserverForCamera
{
    GKSCameraRep *camera = self.cameraRep;
    [camera addObserver:self forKeyPath:@"focalLength" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:ObserverProjectionContext];
    [camera addObserver:self forKeyPath:@"near" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:ObserverProjectionContext];
    [camera addObserver:self forKeyPath:@"far" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:ObserverProjectionContext];
    [camera addObserver:self forKeyPath:@"projectionType" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:ObserverProjectionContext];
    [camera addObserver:self forKeyPath:@"positionX" options:NSKeyValueObservingOptionNew context:ObserverPlaneNormalContext];
    [camera addObserver:self forKeyPath:@"positionY" options:NSKeyValueObservingOptionNew context:ObserverPlaneNormalContext];
    [camera addObserver:self forKeyPath:@"positionZ" options:NSKeyValueObservingOptionNew context:ObserverPlaneNormalContext];
    [camera addObserver:self forKeyPath:@"yaw" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:ObserverPlaneNormalContext];
    [camera addObserver:self forKeyPath:@"pitch" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:ObserverPlaneNormalContext];
    [camera addObserver:self forKeyPath:@"roll" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:ObserverPlaneNormalContext];
    [camera addObserver:self forKeyPath:@"upX" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:ObserverPlaneNormalContext];
    [camera addObserver:self forKeyPath:@"upY" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:ObserverPlaneNormalContext];
    [camera addObserver:self forKeyPath:@"upZ" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:ObserverPlaneNormalContext];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == ObserverPlaneNormalContext || context == ObserverProjectionContext) {
        // FIXME: Does nothing
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


// Add a 3d object to the scene/world
- (void)addObject3DToLists:(GKS3DObjectRep *)objRep
{
    GKS3DObject *object3D = [[GKS3DObject alloc] initWithKind:objRep.objectKind];
    
    // TODO: convenience method?
    // copy data from Rep to Obj3D
    object3D.hidden = objRep.hidden;
    
    object3D.transX = objRep.transX;
    object3D.transY = objRep.transY;
    object3D.transZ = objRep.transZ;

    object3D.rotX = objRep.rotX;
    object3D.rotY = objRep.rotY;
    object3D.rotZ = objRep.rotZ;
    
    object3D.scaleX = objRep.scaleX;
    object3D.scaleY = objRep.scaleY;
    object3D.scaleZ = objRep.scaleZ;

    object3D.lineColor = objRep.lineColor;
    object3D.fillColor = objRep.fillColor;

    [self.theScene add3DObject:object3D];
    
}


- (IBAction)performAddQuick:(id)sender {

    // Add 3d object to the object list
    // some other controller needs to handle this?
    [self addObject3DToLists:self.object3DRep];
    [self.drawingViewController.view setNeedsDisplay:YES];

}

- (IBAction)performDeleteQuick:(id)sender {
    
    [self.theScene deleteLast3DObject];
    [self.drawingViewController.view setNeedsDisplay:YES];

}


- (IBAction)performLookQuick:(id)sender {
    
    [self.cameraViewController camerSetViewLookAtG];
    [self.drawingViewController.view setNeedsDisplay:YES];
}


- (IBAction)performUpdateQuick:(id)sender {
    
    [self.theScene transformAllObjects];
    [self.drawingViewController.view setNeedsDisplay:YES];
}

@end
