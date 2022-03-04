//
//  GKSCameraController.m
//  GeKoS
//
//  Created by Alex Popadich on 3/2/22.
//

#import "GKSCameraController.h"
#import "GKSCameraRep.h"
#include "gks/gks.h"

@interface GKSCameraController ()


@end

static void *CameraFocalLengthContext = &CameraFocalLengthContext;

@implementation GKSCameraController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.planeRoll = @0.0;
    self.planePitch = @0.0;
    self.planeYaw = @0.0;
    
    GKSCameraRep *camera = self.representedObject;
    // observe focal length of camera
    [self registerAsObserverForCamera:camera];
}


- (void)registerAsObserverForCamera:(GKSCameraRep*)camera
{
    [camera addObserver:self
              forKeyPath:@"focalLength"
                 options:(NSKeyValueObservingOptionNew |
                          NSKeyValueObservingOptionOld)
                 context:CameraFocalLengthContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (context == CameraFocalLengthContext) {
        // Do something with focal length value
        NSNumber *newLength = [change valueForKey:@"new"];
        [self setFocus:newLength];
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

- (void)doTilt:(double)degrees {
    Gpt_3 vpn = {0.0, 1.0, 0.0};
    Gpt_3 comp;
    Matrix_4 T;

    double theta = DEG_TO_RAD * [self.planeYaw doubleValue];
    double psi = DEG_TO_RAD * [self.planePitch doubleValue];
    double phi = DEG_TO_RAD * degrees;

    gks_set_identity_matrix_3(T);
    gks_create_z_rotation_matrix_3(-phi, T);
    gks_accumulate_x_rotation_matrix_3(-psi, T);
    gks_accumulate_y_rotation_matrix_3(theta, T);

    gks_transform_point_3(T, &vpn, &comp);
    
    [self.representedObject setValue:[NSNumber numberWithDouble:comp.x] forKey:@"vHatX"];
    [self.representedObject setValue:[NSNumber numberWithDouble:comp.y] forKey:@"vHatY"];
    [self.representedObject setValue:[NSNumber numberWithDouble:comp.z] forKey:@"vHatZ"];
    
    self.headView.headYaw = self.planeYaw;
    self.headView.headPitch = self.planePitch;
    self.headView.headRoll = self.planeRoll;
    [self.headView setNeedsDisplay:YES];
}

- (IBAction)changeRoll:(id)sender
{
    if ([sender isKindOfClass:[NSSlider class]]) {
        double degrees = [sender doubleValue];
        [self doTilt:degrees];
    }
}

- (IBAction)changePitch:(id)sender
{
    if ([sender isKindOfClass:[NSSlider class]]) {
        Gpt_3 vpn = {0.0, 0.0, 1.0};
        Gpt_3 comp;
        Matrix_4 T;
        
        double degrees = [sender doubleValue];
        double psi = DEG_TO_RAD * degrees;
        double theta = DEG_TO_RAD * [self.planeYaw doubleValue];
        double phi = DEG_TO_RAD * [self.planeRoll doubleValue];

        // maybe theta needs be negative? Or control min and max switched?
        gks_set_identity_matrix_3(T);
        gks_create_y_rotation_matrix_3(theta, T);
        gks_accumulate_x_rotation_matrix_3(-psi, T);
        gks_accumulate_z_rotation_matrix_3(phi, T);
        gks_transform_point_3(T, &vpn, &comp);
        
        [self.representedObject setValue:[NSNumber numberWithDouble:comp.x] forKey:@"dirX"];
        [self.representedObject setValue:[NSNumber numberWithDouble:comp.y] forKey:@"dirY"];
        [self.representedObject setValue:[NSNumber numberWithDouble:comp.z] forKey:@"dirZ"];
        
        // maybe do a vector cross product (u X n) and compute up vector instead
        [self doTilt:[self.planeRoll doubleValue]];
    }

}

- (IBAction)changeYaw:(id)sender
{
    if ([sender isKindOfClass:[NSSlider class]]) {
        Gpt_3 vpn = {0.0, 0.0, 1.0};
        Gpt_3 comp;
        Matrix_4 T;

        double degrees = [sender doubleValue];
        double theta = DEG_TO_RAD * degrees;
        double psi = DEG_TO_RAD * [self.planePitch doubleValue];
        double phi = DEG_TO_RAD * [self.planeRoll doubleValue];

        // maybe theta needs be negative? Or control min and max switched?
        gks_set_identity_matrix_3(T);
        gks_create_y_rotation_matrix_3(theta, T);
        gks_accumulate_x_rotation_matrix_3(-psi, T);
        gks_accumulate_z_rotation_matrix_3(phi, T);
        gks_transform_point_3(T, &vpn, &comp);

        [self.representedObject setValue:[NSNumber numberWithDouble:comp.x] forKey:@"dirX"];
        [self.representedObject setValue:[NSNumber numberWithDouble:comp.y] forKey:@"dirY"];
        [self.representedObject setValue:[NSNumber numberWithDouble:comp.z] forKey:@"dirZ"];

        // maybe do a vector cross product (u X n) and compute up vector instead
        [self doTilt:[self.planeRoll doubleValue]];

    }
}

- (IBAction)changeHiddenSurface:(id)sender
{
    if ([sender isKindOfClass:[NSButton class]]) {
        bool onState = [sender state];
        //gks_objarr_set_hidden_surface_removal(onState);
        NSLog(@"Visible Surfaces Only: %d", onState);
    }
}

@end
