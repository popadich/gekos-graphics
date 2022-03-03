//
//  GKSContentViewController.m
//  GeKoS
//
//  Created by Alex Popadich on 2/23/22.
//

#import "GKSContentViewController.h"
#import "GKSCameraRep.h"
#import "GKSCameraController.h"
#import "GKSConstants.h"

@interface GKSContentViewController ()

@property (nonatomic, strong) GKSCameraRep* cameraRep;
@property (nonatomic, weak) IBOutlet NSView* cameraView;
@property (nonatomic, strong) IBOutlet GKSCameraController* cameraViewController;

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
    NSNumber *distance =  [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefPerspectiveDistance];
    self.cameraRep.focalLength = distance;
    
    NSNumber *prtype =  [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefProjectionType];
    self.cameraRep.projectionType = prtype;

    
}

- (void)awakeFromNib {
    self.cameraRep = [[GKSCameraRep alloc] init];

    self.cameraViewController.representedObject = self.cameraRep;

}


@end
