//
//  GKSContentViewController.m
//  GeKoS
//
//  Created by Alex Popadich on 2/23/22.
//

#import "GKSContentViewController.h"
#import "GKSConstants.h"
#import "GKSCameraRep.h"
#import "GKSCameraController.h"
#import "GKSDrawingController.h"
#import "GKS3DObjectRep.h"
#import "GKSScene.h"


@interface GKSContentViewController ()

@property (nonatomic, strong) GKSCameraRep* cameraRep;
@property (nonatomic, weak) IBOutlet NSView* cameraCustomView;
@property (nonatomic, strong) IBOutlet GKSCameraController* cameraViewController;
@property (nonatomic, strong) IBOutlet GKSDrawingController* drawingViewController;


@property (nonatomic, strong) GKS3DObjectRep* object3DRep;
@property (nonatomic, strong) GKSScene* worldScene;

@end


static void *ObserverDistanceContext = &ObserverDistanceContext;
static void *ObserverPoistionContext = &ObserverPoistionContext;
static void *ObserverPlaneNormalContext = &ObserverPlaneNormalContext;


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
    
    self.cameraRep.positionX = @0.0;
    self.cameraRep.positionY = @0.0;
    self.cameraRep.positionZ = @-2.0;
    
    NSNumber *distance =  [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefPerspectiveDistance];
    self.cameraRep.focalLength = distance;
    
    NSNumber *prtype =  [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefProjectionType];
    self.cameraRep.projectionType = prtype;
    
    if (prtype.intValue == kOrthogonalProjection) {
        gks_set_orthogonal_projection();
    }
    else if (prtype.intValue == kPerspectiveProjection) {
        gks_set_perspective_projection();
        gks_set_perspective_depth([distance doubleValue]);
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
    
    // Store one 3D object representation to test the transformation matrices
    self.object3DRep =  [[GKS3DObjectRep alloc] init];
    
    [self.cameraViewController cameraSetViewMatrixG];

    [self registerAsObserverForCamera];
}

- (void)awakeFromNib {
    self.cameraRep = [[GKSCameraRep alloc] init];
    self.cameraViewController.representedObject = self.cameraRep;
    
    // TODO: this should come from a document
    self.worldScene = [[GKSScene alloc] initWithCamera:self.cameraRep];
    self.drawingViewController.representedObject = self.worldScene;
}


- (void)registerAsObserverForCamera
{
    GKSCameraRep *camera = self.cameraRep;
    [camera addObserver:self forKeyPath:@"focalLength" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:ObserverDistanceContext];
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
    if (context == ObserverDistanceContext) {
        NSLog(@"%@", keyPath);
        [self.cameraViewController cameraSetCenterOfProjectionG];
        [self.drawingViewController.view setNeedsDisplay:YES];
    }
    else if (context == ObserverPlaneNormalContext) {
        [self.cameraViewController cameraSetViewMatrixG];
        [self.drawingViewController.view setNeedsDisplay:YES];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

// Object List Stuff

- (void)addObjectToRootOfKind:(GKSint)objectKind lineColor:(const GKScolor *)lineColor rotate:(const GKSpoint_3 *)rotate scale:(const GKSpoint_3 *)scale trans:(const GKSpoint_3 *)trans {
    
    GKS3DObjectRep* objRep = [[GKS3DObjectRep alloc] init];
    
    objRep.objectKind = [NSNumber numberWithInt:objectKind];
    
    objRep.lineColor = [NSColor colorWithRed:lineColor->red green:lineColor->green blue:lineColor->blue alpha:lineColor->alpha];
    objRep.transX = [NSNumber numberWithDouble:trans->x];
    objRep.transY = [NSNumber numberWithDouble:trans->y];
    objRep.transZ = [NSNumber numberWithDouble:trans->z];
    objRep.scaleX = [NSNumber numberWithDouble:scale->x];
    objRep.scaleY = [NSNumber numberWithDouble:scale->y];
    objRep.scaleZ = [NSNumber numberWithDouble:scale->z];
    objRep.rotX = [NSNumber numberWithDouble:rotate->x];
    objRep.rotY = [NSNumber numberWithDouble:rotate->y];
    objRep.rotZ = [NSNumber numberWithDouble:rotate->z];
    
    [self.worldScene addObjectRep:objRep];

}



- (void)addObject3DOfKind:(NSInteger)addTag {
    GKScolor lineColor;
    NSColor* theColor = self.worldScene.worldLineColor;
    
    lineColor.red = [theColor redComponent];
    lineColor.green = [theColor greenComponent];
    lineColor.blue = [theColor blueComponent];
    lineColor.alpha = [theColor alphaComponent];
    

    if (addTag==kCubeKind) {
        GKSpoint_3 trans; GKSpoint_3 scale; GKSpoint_3 rotate;
        
        trans.x=-0.5; trans.y=-0.5; trans.z=-0.5; trans.w=1.0;
        scale.x=1.0; scale.y=1.0; scale.z=1.0; scale.w=1.0;
        rotate.x=0.0; rotate.y=0.0; rotate.z=0.0; rotate.w=1.0;

        GKSobject_3 *objPtr = CubeMesh();
        
        // add a 3d object to the c model world
        gks_objarr_add(kCubeKind, objPtr, trans, scale, rotate, lineColor);
        free(objPtr);  //free object it is copied when added
        
        // add a 3d object to the object GUI world
        [self addObjectToRootOfKind:kCubeKind lineColor:&lineColor rotate:&rotate scale:&scale trans:&trans];
    }
    
    if (addTag==kSphereKind) {
        GKSpoint_3 trans; GKSpoint_3 scale; GKSpoint_3 rotate;
        trans.x=0.0; trans.y=0.0; trans.z=0.0; trans.w=1.0;
        scale.x=1.0; scale.y=1.0; scale.z=1.0; scale.w=1.0;
        rotate.x=0.0; rotate.y=0.0; rotate.z=0.0; rotate.w=1.0;

        GKSobject_3 *objPtr = SphereMesh();

        // add a 3d object to the c model world
        gks_objarr_add(kSphereKind, objPtr, trans, scale, rotate, lineColor);
        free(objPtr);  //free object it is copied when added

        // add a 3d object to the object GUI world
        [self addObjectToRootOfKind:kSphereKind lineColor:&lineColor rotate:&rotate scale:&scale trans:&trans];
    }
    
    if (addTag==kPyramidKind) {
        GKSpoint_3 trans; GKSpoint_3 scale; GKSpoint_3 rotate;
        trans.x=-0.5; trans.y=-0.5; trans.z=-0.5; trans.w=1.0;
        scale.x=1.0; scale.y=1.0; scale.z=1.0; scale.w=1.0;
        rotate.x=0.0; rotate.y=0.0; rotate.z=0.0; rotate.w=1.0;
        GKSobject_3 *objPtr = PyramidMesh();

        // add a 3d object to the c model world
        gks_objarr_add(kPyramidKind, objPtr, trans, scale, rotate, lineColor);
        free(objPtr);  //free object it is copied when added

        // add a 3d object to the object GUI world
        [self addObjectToRootOfKind:kPyramidKind lineColor:&lineColor rotate:&rotate scale:&scale trans:&trans];
    }
    
}


- (IBAction)performAddQuick:(id)sender {
    NSInteger addTag = [sender tag];
    NSLog(@"Quick Add Object From Menu Tag: %ld",addTag);

    // Add 3d object to the object list
    // some other controller needs to handle this?
    
    [self addObject3DOfKind:kPyramidKind];
    [self.drawingViewController.view setNeedsDisplay:YES];

}

- (IBAction)performUpdateQuick:(id)sender {
    NSInteger addTag = [sender tag];
    NSLog(@"Quick Update Object From Menu Tag: %ld",addTag);
    
    [self.cameraViewController cameraDoLookAt];
    
    [self.drawingViewController.view setNeedsDisplay:YES];
}

@end
