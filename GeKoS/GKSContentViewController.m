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
#import "GKSCameraController.h"
#import "GKSDrawingController.h"
#import "GKS3DObjectRep.h"
#import "GKSScene.h"


@interface GKSContentViewController ()

@property (nonatomic, weak) IBOutlet NSView* cameraCustomView;
@property (strong) IBOutlet NSColorWell* contentLineColor;
@property (strong) IBOutlet NSColorWell* contentFillColor;
@property (nonatomic, strong) IBOutlet GKSCameraController* cameraViewController;
@property (nonatomic, strong) IBOutlet GKSDrawingController* drawingViewController;


@property (nonatomic, strong) GKSCameraRep* cameraRep;
@property (nonatomic, strong) GKS3DObjectRep* object3DRep;
@property (nonatomic, strong) GKSScene* worldScene;

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

    
    // Set perspective distance, projection type and other camera properties.
    // Use default values settings and preferences here
    self.cameraRep.upX = @0;
    self.cameraRep.upY = @1.0;
    self.cameraRep.upZ = @0;
    
    self.cameraRep.positionX = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefCameraLocX];
    self.cameraRep.positionY = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefCameraLocY];
    self.cameraRep.positionZ = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefCameraLocZ];
    
    NSNumber *focalLength =  [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefPerspectiveDistance];
    self.cameraRep.focalLength = focalLength;
    
    self.cameraRep.near = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefNearPlaneDistance];
    self.cameraRep.far = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefFarPlaneDistance];
    
    NSNumber *prtype =  [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefProjectionType];
    self.cameraRep.projectionType = prtype;
    
    // TODO: method with projection type needed
    // need a method to explicitly set the projection type on the camera controller
    [self.cameraViewController cameraSetProjectionType:[prtype integerValue]];

    
    NSError *error;
    NSData *colorData = [[NSUserDefaults standardUserDefaults] dataForKey:gksPrefPenColor];
    if (colorData != nil) {
        self.contentLineColor.color = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:colorData error:&error];
    }
    colorData = [[NSUserDefaults standardUserDefaults] dataForKey:gksPrefFillColor];
    if (colorData != nil) {
        self.contentFillColor.color = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:colorData error:&error];
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
    
    // Store one 3D object representation to act as a data entry buffer
    self.object3DRep =  [[GKS3DObjectRep alloc] init];
    
    [self.cameraViewController cameraClampViewMatrixG];

    [self registerAsObserverForCamera];
}

- (void)awakeFromNib {
    // content should be populated by the document read methods
    GKSContent *content = self.representedObject;
    
    GKSScene *scene = content.theScene;
    GKSCameraRep *scene_camera = scene.camera;
    
    self.cameraRep = scene_camera;
    self.cameraViewController.representedObject = self.cameraRep;

    self.worldScene = scene;
    self.drawingViewController.representedObject = self.worldScene;
}


- (void)registerAsObserverForCamera
{
    GKSCameraRep *camera = self.cameraRep;
    [camera addObserver:self forKeyPath:@"focalLength" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:ObserverProjectionContext];
    [camera addObserver:self forKeyPath:@"positionX" options:NSKeyValueObservingOptionNew context:ObserverPlaneNormalContext];
    [camera addObserver:self forKeyPath:@"positionY" options:NSKeyValueObservingOptionNew context:ObserverPlaneNormalContext];
    [camera addObserver:self forKeyPath:@"positionZ" options:NSKeyValueObservingOptionNew context:ObserverPlaneNormalContext];
    [camera addObserver:self forKeyPath:@"dirX" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:ObserverPlaneNormalContext];
    [camera addObserver:self forKeyPath:@"dirY" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:ObserverPlaneNormalContext];
    [camera addObserver:self forKeyPath:@"dirZ" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:ObserverPlaneNormalContext];
    [camera addObserver:self forKeyPath:@"upX" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:ObserverPlaneNormalContext];
    [camera addObserver:self forKeyPath:@"upY" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:ObserverPlaneNormalContext];
    [camera addObserver:self forKeyPath:@"upZ" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:ObserverPlaneNormalContext];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == ObserverPlaneNormalContext) {
        [self.cameraViewController cameraClampViewMatrixG];
        [self.drawingViewController.view setNeedsDisplay:YES];
    }
    else if (context == ObserverProjectionContext) {
        // this is for focal length changes only, go direct!
        [self.cameraViewController cameraSetCenterOfProjectionG];
        [self.drawingViewController.view setNeedsDisplay:YES];
        
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

// Object List Stuff

- (BOOL)addObject3DKind:(ObjectKind)kind atLocation:(GKSvector3d)loc withRotation:(GKSvector3d)rot andScale:(GKSvector3d)sca
{
    BOOL didAdd = NO;
    GKSobject_3 *objPtr = NULL;
    
    GKScolor lineColor;
    NSColor* theColor = self.contentLineColor.color;
    lineColor.red = [theColor redComponent];
    lineColor.green = [theColor greenComponent];
    lineColor.blue = [theColor blueComponent];
    lineColor.alpha = [theColor alphaComponent];
    GKScolor fillColor;
    theColor = self.contentFillColor.color;
    fillColor.red = [theColor redComponent];
    fillColor.green = [theColor greenComponent];
    fillColor.blue = [theColor blueComponent];
    fillColor.alpha = [theColor alphaComponent];
    
    GKSvector3d trans; GKSvector3d scale; GKSvector3d rotate;
    trans = loc;
    scale = sca;
    rotate = rot;
    
    switch (kind) {
        case kCubeKind:
            objPtr = CubeMesh();
            break;
        case kSphereKind:
            objPtr = SphereMesh();
            break;
        case kPyramidKind:
            objPtr = PyramidMesh();
            break;
        case kHouseKind:
            objPtr = HouseMesh();
            break;
            
        default:
            break;
    }
    
    if (objPtr != NULL) {
        // add a 3d object to the c model world
        if (gks_objarr_add(kind, objPtr, trans, scale, rotate, lineColor, fillColor)) {
            free(objPtr);  //free object it is copied when added
            didAdd = YES;
        }
    }
    return didAdd;
}


// add a 3d object to the object GUI world
- (void)addObjectToListOfKind:(ObjectKind)objectKind atLocation:(GKSvector3d)location withRotation:(GKSvector3d)rotate andScale:(GKSvector3d)scale
{
    GKS3DObjectRep* objRep = [[GKS3DObjectRep alloc] init];
    
    // TODO: make a copy?
    objRep.objectKind = [NSNumber numberWithInt:objectKind];
    objRep.transX = [NSNumber numberWithDouble:location.crd.x];
    objRep.transY = [NSNumber numberWithDouble:location.crd.y];
    objRep.transZ = [NSNumber numberWithDouble:location.crd.z];
    objRep.scaleX = [NSNumber numberWithDouble:scale.crd.x];
    objRep.scaleY = [NSNumber numberWithDouble:scale.crd.y];
    objRep.scaleZ = [NSNumber numberWithDouble:scale.crd.z];
    objRep.rotX = [NSNumber numberWithDouble:rotate.crd.x];
    objRep.rotY = [NSNumber numberWithDouble:rotate.crd.y];
    objRep.rotZ = [NSNumber numberWithDouble:rotate.crd.z];

    if ([self addObject3DKind:objectKind atLocation:location withRotation:objRep.rotationVector andScale:objRep.scaleVector]) {
        // add object representation to mutable array
        [self.worldScene addObjectRep:objRep];
    }
    else
        NSBeep();
    
}


- (IBAction)performAddQuick:(id)sender {

    // Add 3d object to the object list
    // some other controller needs to handle this?
    NSInteger kind = [self.object3DRep.objectKind integerValue];
    GKSvector3d position = self.object3DRep.positionVector;
    GKSvector3d rotation = self.object3DRep.rotationVector;
    GKSvector3d scaling = self.object3DRep.scaleVector;
    [self addObjectToListOfKind:(ObjectKind)kind atLocation:position withRotation:rotation andScale:scaling];
    [self.drawingViewController.view setNeedsDisplay:YES];

}

- (IBAction)performDeleteQuick:(id)sender {
    gks_objarr_delete_last();
    [self.drawingViewController.view setNeedsDisplay:YES];

}

- (IBAction)performUpdateQuick:(id)sender {
    
    [self.cameraViewController cameraClampViewMatrixG];
    [self.drawingViewController.view setNeedsDisplay:YES];
}

@end
