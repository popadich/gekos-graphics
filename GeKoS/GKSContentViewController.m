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
#import "GKS3DObjectRep.h"
#import "GKSScene.h"

@interface GKSContentViewController ()

@property (nonatomic, strong) GKSCameraRep* cameraRep;
@property (nonatomic, weak) IBOutlet NSView* cameraView;
@property (nonatomic, strong) IBOutlet GKSCameraController* cameraViewController;


@property (nonatomic, strong) GKS3DObjectRep* object3DRep;
@property (nonatomic, strong) GKSScene* worldScene;

@end

@implementation GKSContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    
    // Can't use replace subview because constraints in parent view are lost
    NSView* cameraSubView = self.cameraViewController.view;
    cameraSubView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cameraView addSubview:cameraSubView];

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
    self.cameraRep.positionZ = @2.0;
    
    
    NSNumber *distance =  [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefPerspectiveDistance];
    self.cameraRep.focalLength = distance;
    
    NSNumber *prtype =  [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefProjectionType];
    self.cameraRep.projectionType = prtype;

    // Add an 3D object representation to try the transformation matrices
    self.object3DRep =  [[GKS3DObjectRep alloc] init];
    self.worldScene = [[GKSScene alloc] initWithCamera:self.cameraRep];

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
    GKSfloat r_min = 0.0;              // r_min = WindowRect.left;
    GKSfloat r_max = 400.0;            // r_max = WindowRect.right;
    GKSfloat s_min = 0.0;              // s_min = WindowRect.bottom;
    GKSfloat s_max = 400.0;            // s_max = WindowRect.top;
    gks_trans_create_transform_at_idx(0, r_min, r_max, s_min, s_max, world_volume);

    
    
}

- (void)awakeFromNib {
    self.cameraRep = [[GKSCameraRep alloc] init];

    self.cameraViewController.representedObject = self.cameraRep;

}


@end
