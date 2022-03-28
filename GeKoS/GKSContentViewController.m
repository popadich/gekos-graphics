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
    
    // TODO: obects need to be added not copied
    // Store one 3D object representation to act as a data entry buffer
    // which is copied when the object is actually added to the 3D world
    self.object3DRep =  [[GKS3DObjectRep alloc] init];
    self.object3DRep.lineColor = self.contentLineColor.color;
    self.object3DRep.fillColor = self.contentFillColor.color;

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
    
    // populate c data arrays
    for (GKS3DObjectRep *objRep in scene.objectList) {
        [self addObject3DStruct:objRep];
    }
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
        [self.drawingViewController.view setNeedsDisplay:YES];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

// Object List Stuff
- (BOOL)addObject3DStruct:(GKS3DObjectRep *)objRep
{
    GKSactor anActor;
    BOOL didAdd = NO;
    BOOL isCentered = [self.isCenteredObject boolValue];
    GKSobject_3 *mesh_object_ptr = NULL;
    
    GKSobjectKind kind = (GKSobjectKind)[objRep.objectKind integerValue];
    switch (kind) {
        case kCubeKind:
            mesh_object_ptr = CubeMesh(isCentered);
            break;
        case kSphereKind:
            mesh_object_ptr = SphereMesh(isCentered);
            break;
        case kPyramidKind:
            mesh_object_ptr = PyramidMesh(isCentered);
            break;
        case kHouseKind:
            mesh_object_ptr = HouseMesh(isCentered);
            break;
        default:
            break;
    }
    
    if (mesh_object_ptr != NULL) {
        
        // TODO: objectRep should do this
        // Collect objectRep data as GKS c primitive types
        GKSvector3d position = [objRep positionVector];
        GKSvector3d rotation = [objRep rotationVector];
        GKSvector3d scale = [objRep scaleVector];
        
        CGFloat r,g,b,a;
        NSColor* theColor = objRep.lineColor;
        [theColor getRed:&r green:&g blue:&b alpha:&a];
        GKScolor line_color = {r,g,b,a};
        theColor = objRep.fillColor;
        [theColor getRed:&r green:&g blue:&b alpha:&a];
        GKScolor fill_color = {r,g,b,a};
        
        // the Actor
        anActor.kind = kind;
        anActor.hidden = objRep.hidden.boolValue;
        anActor.mesh_object = *mesh_object_ptr;
        anActor.priority = objRep.priority.doubleValue;
        anActor.scale_vector = scale;
        anActor.rotate_vector = rotation;
        anActor.translate_vector = position;
        anActor.line_color = line_color;
        anActor.fill_color = fill_color;
        
        
        // add a 3d object to the c model world
        if (gks_objarr_actor_add(anActor)){
            free(mesh_object_ptr);  //free object it is copied when added
            didAdd = YES;
        }
    }
    return didAdd;
}


// add a 3d object to the object GUI world
- (void)addObject3DToList:(GKS3DObjectRep *)templateObject
{
    GKS3DObjectRep *object3D = [templateObject copy];

    // try to add to c data structures
    if ([self addObject3DStruct:object3D]) {
        // add object representation to mutable array
        [self.theScene addObjectRep:object3D];
    }
    else
        NSBeep();
}


- (IBAction)performAddQuick:(id)sender {

    // Add 3d object to the object list
    // some other controller needs to handle this?
    [self addObject3DToList:self.object3DRep];
    [self.drawingViewController.view setNeedsDisplay:YES];

}

- (IBAction)performDeleteQuick:(id)sender {
    gks_objarr_delete_last();
    [self.drawingViewController.view setNeedsDisplay:YES];

}

- (IBAction)performUpdateQuick:(id)sender {
    
    [self.cameraViewController camerSetViewLookAtG];
    [self.drawingViewController.view setNeedsDisplay:YES];
}

@end
