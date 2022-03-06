//
//  GKSCameraController.m
//  GeKoS
//
//  Created by Alex Popadich on 3/2/22.
//

#import "GKSCameraController.h"
#import "GKSCameraRep.h"
#include "gks/gks.h"

@interface GKSCameraController () {
    GKSpoint_3 up_vect;
}

@property (strong)GKSCameraRep *camera;
@property (weak)IBOutlet GKSHeadView *headView;

@end

static void *CameraFocalLengthContext = &CameraFocalLengthContext;
static void *CameraRotationContext = &CameraRotationContext;


@implementation GKSCameraController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    up_vect.x = 0.0;
    up_vect.y = 1.0;
    up_vect.z = 0.0;
    
    GKSCameraRep *camera = self.representedObject;
    // observe focal length of camera
    [self registerAsObserverForCamera:camera];
    self.camera = camera;

}


- (void)registerAsObserverForCamera:(GKSCameraRep*)camera
{
    [camera addObserver:self
              forKeyPath:@"focalLength"
                 options:(NSKeyValueObservingOptionNew |
                          NSKeyValueObservingOptionOld)
                 context:CameraFocalLengthContext];

    [camera addObserver:self
              forKeyPath:@"yaw"
                 options:(NSKeyValueObservingOptionNew |
                          NSKeyValueObservingOptionOld)
                 context:CameraRotationContext];
    [camera addObserver:self
              forKeyPath:@"pitch"
                 options:(NSKeyValueObservingOptionNew |
                          NSKeyValueObservingOptionOld)
                 context:CameraRotationContext];
    [camera addObserver:self
              forKeyPath:@"roll"
                 options:(NSKeyValueObservingOptionNew |
                          NSKeyValueObservingOptionOld)
                 context:CameraRotationContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (context == CameraFocalLengthContext) {
        // Do something with focal length value
        NSNumber *newLength = [change valueForKey:@"new"];
        [self setFocus:newLength];
    } else if (context == CameraRotationContext) {
        NSNumber *newValue = [change valueForKey:@"new"];
        if ([keyPath isEqualToString:@"yaw"]) {
            [self adjustCameraWithYaw:newValue];
        }
        else if ([keyPath isEqualToString:@"pitch"]) {
            [self adjustCameraWithPitch:newValue];
        }
        else if([keyPath isEqualToString:@"roll"]) {
            [self adjustCameraWithRoll:newValue];
        }
    } else {
        // Any unrecognized context must belong to super
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                               context:context];
    }
}


#pragma mark User Interaction

- (void)setFocus:(NSNumber *)focal;
{
    self.headView.headFocalLength = focal;
    [self.headView setNeedsDisplay:YES];

}

- (void)adjustCameraWithYaw:(NSNumber *)angle
{
    [self changeYaw:angle];
    [self adjustHead];
}

- (void)adjustCameraWithPitch:(NSNumber *)angle
{
    [self changePitch:angle];
    [self adjustHead];
}

- (void)adjustCameraWithRoll:(NSNumber *)angle
{
    [self changeRoll:angle];
    [self adjustHead];
}

- (void)adjustHead {
    self.headView.headYaw = self.camera.yaw;
    self.headView.headPitch = self.camera.pitch;

    // reverse the roll value because x-axis is coming out at us and a positive rotation
    // from that refererence appears as a negative rotation of our head. The head is
    // oriented as if looking along the negative x-axis direction.
    double angle =  -1 * [self.camera.roll doubleValue];
    self.headView.headRoll = [NSNumber numberWithDouble:angle];
    
    [self.headView setNeedsDisplay:YES];
}

- (void)changeRoll:(NSNumber *)angle
{
    GKSpoint_3 comp;
    GKSmatrix_3 T;

    double theta = [self.camera.yaw doubleValue];
    double psi = [self.camera.pitch doubleValue];
    double phi = [angle doubleValue];

    gks_set_identity_matrix_3(T);
    gks_create_z_rotation_matrix_3(-phi, T);
    gks_accumulate_x_rotation_matrix_3(-psi, T);
    gks_accumulate_y_rotation_matrix_3(theta, T);

    gks_transform_point_3(T, &up_vect, &comp);
    
    [self.representedObject setValue:[NSNumber numberWithDouble:comp.x] forKey:@"vHatX"];
    [self.representedObject setValue:[NSNumber numberWithDouble:comp.y] forKey:@"vHatY"];
    [self.representedObject setValue:[NSNumber numberWithDouble:comp.z] forKey:@"vHatZ"];
}

- (void)changePitch:(NSNumber *)angle
{
    GKSpoint_3 comp;
    GKSmatrix_3 T;
    
    double psi = [angle doubleValue];
    double theta = [self.camera.yaw doubleValue];
    double phi = [self.camera.roll doubleValue];

    // maybe theta needs be negative? Or control min and max switched?
    gks_set_identity_matrix_3(T);
    gks_create_y_rotation_matrix_3(theta, T);
    gks_accumulate_x_rotation_matrix_3(-psi, T);
    gks_accumulate_z_rotation_matrix_3(phi, T);
    gks_transform_point_3(T, &up_vect, &comp);
    
    [self.representedObject setValue:[NSNumber numberWithDouble:comp.x] forKey:@"dirX"];
    [self.representedObject setValue:[NSNumber numberWithDouble:comp.y] forKey:@"dirY"];
    [self.representedObject setValue:[NSNumber numberWithDouble:comp.z] forKey:@"dirZ"];

}

- (void)changeYaw:(NSNumber *)angle
{
    GKSpoint_3 comp;
    GKSmatrix_3 T;

    double theta = [angle doubleValue];
    double psi = [self.camera.pitch doubleValue];
    double phi = [self.camera.roll doubleValue];

    // maybe theta needs be negative? Or control min and max switched?
    gks_set_identity_matrix_3(T);
    gks_create_y_rotation_matrix_3(theta, T);
    gks_accumulate_x_rotation_matrix_3(-psi, T);
    gks_accumulate_z_rotation_matrix_3(phi, T);
    gks_transform_point_3(T, &up_vect, &comp);

    [self.representedObject setValue:[NSNumber numberWithDouble:comp.x] forKey:@"dirX"];
    [self.representedObject setValue:[NSNumber numberWithDouble:comp.y] forKey:@"dirY"];
    [self.representedObject setValue:[NSNumber numberWithDouble:comp.z] forKey:@"dirZ"];

}

- (IBAction)changeVisibleSurface:(id)sender
{
    if ([sender isKindOfClass:[NSButton class]]) {
        bool onState = [sender state];
        //gks_objarr_set_hidden_surface_removal(onState);
        NSLog(@"Visible Surfaces Only: %d", onState);
    }
}

@end
