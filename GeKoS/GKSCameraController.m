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

@property (strong)GKSCameraRep *camera;
@property (weak)IBOutlet GKSHeadView *headView;

@end

static void *CameraFocalLengthContext = &CameraFocalLengthContext;


@implementation GKSCameraController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
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

- (void)adjustCamera:(double)angle {
    Gpt_3 vpn = {0.0, 1.0, 0.0};
    Gpt_3 comp;
    Matrix_4 T;

    double theta = [self.camera.yaw doubleValue];
    double psi = [self.camera.pitch doubleValue];
    double phi = angle;

    gks_set_identity_matrix_3(T);
    gks_create_z_rotation_matrix_3(-phi, T);
    gks_accumulate_x_rotation_matrix_3(-psi, T);
    gks_accumulate_y_rotation_matrix_3(theta, T);

    gks_transform_point_3(T, &vpn, &comp);
    
    [self.representedObject setValue:[NSNumber numberWithDouble:comp.x] forKey:@"vHatX"];
    [self.representedObject setValue:[NSNumber numberWithDouble:comp.y] forKey:@"vHatY"];
    [self.representedObject setValue:[NSNumber numberWithDouble:comp.z] forKey:@"vHatZ"];
    
    [self adjustHead];

}

- (IBAction)changeRoll:(id)sender
{
    if ([sender isKindOfClass:[NSSlider class]]) {
        double min = [sender minValue];
        double max = [sender maxValue];
        // reverse the value
        double angle = max + min - [sender doubleValue];
        [self adjustCamera:angle];
    }
}

- (IBAction)changePitch:(id)sender
{
    if ([sender isKindOfClass:[NSSlider class]]) {
        Gpt_3 vpn = {0.0, 0.0, 1.0};
        Gpt_3 comp;
        Matrix_4 T;
        
        double psi = [sender doubleValue];
        double theta = [self.camera.yaw doubleValue];
        double phi = [self.camera.roll doubleValue];

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
        [self adjustCamera:[self.camera.roll doubleValue]];
    }

}

- (IBAction)changeYaw:(id)sender
{
    if ([sender isKindOfClass:[NSSlider class]]) {
        Gpt_3 vpn = {0.0, 0.0, 1.0};
        Gpt_3 comp;
        Matrix_4 T;

        double theta = [sender doubleValue];
        double psi = [self.camera.pitch doubleValue];
        double phi = [self.camera.roll doubleValue];

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
        [self adjustCamera:[self.camera.roll doubleValue]];

    }
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
