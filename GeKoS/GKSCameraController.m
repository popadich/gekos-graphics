//
//  GKSCameraController.m
//  GeKoS
//
//  Created by Alex Popadich on 3/2/22.
//

#import "GKSCameraController.h"
#include "gks/gks.h"

@interface GKSCameraController ()



@end

@implementation GKSCameraController

#pragma mark BASECLASS

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    NSLog(@"Observer Custom View Did Load! Says the Controller.");
    self.upTilt = @0.0;
    self.planePitch = @0.0;
    self.planeYaw = @0.0;
    
}


#pragma mark User Interaction

// FIXME: Adjust up vector VUP to be at right angle to VPN
// I think that can be accomplished by just truncating the Z component of the
// transformation. Or for now pretend like it doesn't exist. Should check to
// see if the up vector is a unit vector. Maybe normalis it?

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
    
    [self.representedObject setValue:[NSNumber numberWithDouble:comp.x] forKey:@"upX"];
    [self.representedObject setValue:[NSNumber numberWithDouble:comp.y] forKey:@"upY"];
    [self.representedObject setValue:[NSNumber numberWithDouble:comp.z] forKey:@"upZ"];
}

- (IBAction)changeTilt:(id)sender
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
        double phi = DEG_TO_RAD * [self.upTilt doubleValue];

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
        [self doTilt:[self.upTilt doubleValue]];
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
        double phi = DEG_TO_RAD * [self.upTilt doubleValue];

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
        [self doTilt:[self.upTilt doubleValue]];

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
