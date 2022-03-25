//
//  GKSCameraController.m
//  GeKoS
//
//  Created by Alex Popadich on 3/2/22.
//

#import "GKSCameraController.h"
#import "GKSConstants.h"
#import "GKSCameraRep.h"
#include "gks/gks.h"

static double head_size_adjust = 1.0;

@interface GKSCameraController ()

@property (strong)GKSCameraRep *camera;
@property (weak)IBOutlet GKSHeadView *headView;

@end

static void *CameraRotationContext = &CameraRotationContext;


@implementation GKSCameraController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.camera = self.representedObject;
    
    [self cameraDefaultSettings:self.representedObject];

    // focal length for head view
    [self setFocus:@1.0];    // do not change
}


- (void) cameraDefaultSettings:(GKSCameraRep *)theCamera
{
    if (theCamera) {
        theCamera.upX = @0.0;
        theCamera.upY = @1.0;
        theCamera.upZ = @0.0;
        theCamera.positionX = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefCameraLocX];
        theCamera.positionY = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefCameraLocY];
        theCamera.positionZ = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefCameraLocZ];
        theCamera.dirX = @0.0;
        theCamera.dirY = @0.0;
        theCamera.dirZ = @-1.0;
    
        theCamera.focalLength = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefPerspectiveDistance];
        theCamera.near = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefNearPlaneDistance];
        theCamera.far = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefFarPlaneDistance];
        
        theCamera.roll = @0.0;
        theCamera.pitch = @0.0;
        theCamera.yaw = @0.0;
        
        NSNumber *prType =  [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefProjectionType];
        
        theCamera.projectionType = prType;
        [self cameraSetProjectionType:prType];
    }

}


#pragma mark USER Interaction

- (void)setFocus:(NSNumber *)focal;
{
    // increase focal length on head by a bit, so that the
    // head is visible in its frame.
    double focal_length = [focal doubleValue] + head_size_adjust;
    NSNumber *fl = [NSNumber numberWithDouble:focal_length];
    self.headView.headFocalLength = fl;
    [self.headView setNeedsDisplay:YES];

}

- (void)adjustCameraWithYaw:(NSNumber *)angle
{
    [self adjustYawToAngle:angle];
    [self adjustHead];
}

- (void)adjustCameraWithPitch:(NSNumber *)angle
{
    [self adjustPitchToAngle:angle];
    [self adjustHead];
}

- (void)adjustCameraWithRoll:(NSNumber *)angle
{
    [self adjustRollToAngle:angle];
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

- (void)adjustRollToAngle:(NSNumber *)angle
{
    GKSvector3d vector_y = {0.0, 0.0, -1.0, 1.0};  // unit vector along the y-axis

    GKSvector3d trans_point;
    GKSmatrix_3 T;

    double theta = [self.camera.yaw doubleValue];
    double psi = [self.camera.pitch doubleValue];
    double phi = [angle doubleValue];

    gks_create_identity_matrix_3(T);
    gks_create_z_rotation_matrix_3(-phi, T);
    gks_accumulate_x_rotation_matrix_3(-psi, T);
    gks_accumulate_y_rotation_matrix_3(theta, T);

    gks_transform_point(T, vector_y, &trans_point);
    
    [self.representedObject setValue:[NSNumber numberWithDouble:trans_point.crd.x] forKey:@"dirX"];
    [self.representedObject setValue:[NSNumber numberWithDouble:trans_point.crd.y] forKey:@"dirY"];
    [self.representedObject setValue:[NSNumber numberWithDouble:trans_point.crd.z] forKey:@"dirZ"];
}

- (void)adjustPitchToAngle:(NSNumber *)angle
{
    GKSvector3d vector_z = {0.0, 0.0, -1.0, 1.0};  // unit vector along the z-axis

    GKSvector3d trans_point;
    GKSmatrix_3 T;
    
    double psi = [angle doubleValue];
    double theta = [self.camera.yaw doubleValue];
    double phi = [self.camera.roll doubleValue];

    // maybe theta needs be negative? Or control min and max switched?
    gks_create_identity_matrix_3(T);
    gks_create_z_rotation_matrix_3(-phi, T);
    gks_accumulate_x_rotation_matrix_3(-psi, T);
    gks_accumulate_y_rotation_matrix_3(theta, T);
    gks_transform_point(T, vector_z, &trans_point);
    
    self.camera.dirX = [NSNumber numberWithDouble:trans_point.crd.x];
    self.camera.dirY = [NSNumber numberWithDouble:trans_point.crd.y];
    self.camera.dirZ = [NSNumber numberWithDouble:trans_point.crd.z];

}

- (void)adjustYawToAngle:(NSNumber *)angle
{
    GKSvector3d vector_z = {0.0, 0.0, -1.0, 1.0};  // unit co-linear with z-axis

    GKSvector3d trans_point;
    GKSmatrix_3 T;

    double theta = [angle doubleValue];
    double psi = [self.camera.pitch doubleValue];
    double phi = [self.camera.roll doubleValue];

    // maybe theta needs be negative? Or control min and max switched?
    gks_create_identity_matrix_3(T);
    gks_create_y_rotation_matrix_3(-theta, T);
    gks_accumulate_x_rotation_matrix_3(-psi, T);
    gks_accumulate_z_rotation_matrix_3(phi, T);
    
    // is this a 3x3 operation?
    gks_transform_vector_3(T, vector_z, &trans_point);
    
    self.camera.dirX = [NSNumber numberWithDouble:trans_point.crd.x];
    self.camera.dirY = [NSNumber numberWithDouble:trans_point.crd.y];
    self.camera.dirZ = [NSNumber numberWithDouble:trans_point.crd.z];

}


- (IBAction)changeVisibleSurface:(id)sender
{
    if ([sender isKindOfClass:[NSButton class]]) {
        bool onState = [sender state];
        //gks_objarr_set_hidden_surface_removal(onState);
        NSLog(@"Visible Surfaces Only: %d", onState);
    }
}

- (IBAction)changeProjectionType:(id)sender;
{
    NSInteger projectionType = [sender selectedTag];
    NSNumber *prType = [NSNumber numberWithInteger:projectionType];
    [self cameraSetProjectionType:prType];
}

- (IBAction)doChangeYaw:(id)sender
{
    if ([sender isKindOfClass:[NSSlider class]]) {
        NSNumber* slide = [sender objectValue];
        [self adjustCameraWithYaw:slide];
    }
}

- (IBAction)doChangePitch:(id)sender
{
    if ([sender isKindOfClass:[NSSlider class]]) {
        NSNumber *sliderValue = [sender objectValue];
        [self adjustCameraWithPitch:sliderValue];
    }
}

- (IBAction)doChangeRoll:(id)sender
{
    if ([sender isKindOfClass:[NSSlider class]]) {
        NSNumber *sliderValue = [sender objectValue];
        [self adjustCameraWithRoll:sliderValue];
    }
}

- (IBAction)doCameraReset:(id)sender
{
    GKSCameraRep *camera = self.camera;
    [self cameraDefaultSettings:camera];
}



//MARK: Projection Matrix Interactions

- (void)cameraSetProjectionType:(NSNumber *)prType {
    GKSCameraRep *camera = self.camera;
    if (camera != nil) {
        NSInteger projectionType = [prType integerValue];
        if (projectionType == kOrthogonalProjection) {
            gks_set_orthogonal_projection();
        }
        else if (projectionType == kPerspectiveSimple) {
            //Set perspective distance
            double distance = [camera.focalLength doubleValue];
            gks_set_perspective_simple(distance);
        }
        else if (projectionType == kPerspective) {
            double distance = [camera.focalLength doubleValue];
            double alpha = 90.0 - (90.0 * distance / 100.0) + 0.1;
            double near = [camera.near doubleValue];
            double far = [camera.far doubleValue];
            gks_set_perspective_projection(alpha, near, far);
        }
        else if (projectionType == kAxonometric) {
            double distance = [camera.focalLength doubleValue];
            double alpha = 90.0 - (90.0 * distance / 100.0) + 0.1;
            double near = [camera.near doubleValue];
            double far = [camera.far doubleValue];
            gks_set_perspective_alternate(alpha, near, far);
        }
    }
}

- (void)cameraFixProjectionMatrix {
    GKSCameraRep *camera = self.camera;
    if (camera != nil) {
        NSNumber *prType = camera.projectionType;
        [self cameraSetProjectionType:prType];
    }
    
}


// MARK: View Matrix Interactions
- (void)cameraDoLookAtG {
    GKSCameraRep *camera = self.camera;

    if (camera != nil) {
        GKSmatrix_3    aViewMatrix;
        
        GKSvector3d up_vector = GKSMakeVector(camera.upX.doubleValue, camera.upY.doubleValue, camera.upZ.doubleValue);
        
        GKSvector3d look_at = GKSMakeVector(camera.lookX.doubleValue, camera.lookY.doubleValue, camera.lookZ.doubleValue);
        
        GKSvector3d pos = GKSMakeVector(camera.positionX.doubleValue, camera.positionY.doubleValue, camera.positionZ.doubleValue);
        
        GKSvector3d dir_vector = GKSMakeVector(0.0, 0.0, 0.0);
        gks_gen_dir_vector(pos, look_at, &dir_vector);

        // Set Camera View Matrix
        gks_gen_view_matrix(pos, dir_vector, up_vector, aViewMatrix);
        gks_set_view_matrix(aViewMatrix);
        
//        NSLog(@"uHat: %lf, %lf, %lf, %lf", aViewMatrix[0][0], aViewMatrix[0][1], aViewMatrix[0][2], aViewMatrix[0][3] );
//        NSLog(@"vHat: %lf, %lf, %lf, %lf", aViewMatrix[1][0], aViewMatrix[1][1], aViewMatrix[1][2], aViewMatrix[1][3] );
//        NSLog(@"Dir : %lf, %lf, %lf, %lf", aViewMatrix[2][0], aViewMatrix[2][1], aViewMatrix[2][2], aViewMatrix[2][3] );
//        NSLog(@"Homo: %lf, %lf, %lf, %lf\n.", aViewMatrix[3][0], aViewMatrix[3][1], aViewMatrix[3][2], aViewMatrix[3][3] );

        
        // Set UI values
        NSNumber *uhatx = [NSNumber numberWithDouble:aViewMatrix[0][0]];
        NSNumber *uhaty = [NSNumber numberWithDouble:aViewMatrix[0][1]];
        NSNumber *uhatz = [NSNumber numberWithDouble:aViewMatrix[0][2]];

        NSNumber *vhatx = [NSNumber numberWithDouble:aViewMatrix[1][0]];
        NSNumber *vhaty = [NSNumber numberWithDouble:aViewMatrix[1][1]];
        NSNumber *vhatz = [NSNumber numberWithDouble:aViewMatrix[1][2]];
        
        camera.dirX = @(dir_vector.crd.x);
        camera.dirY = @(dir_vector.crd.y);
        camera.dirZ = @(dir_vector.crd.z);
        
        [self.camera setValue:uhatx forKey:@"uHatX"];
        [self.camera setValue:uhaty forKey:@"uHatY"];
        [self.camera setValue:uhatz forKey:@"uHatZ"];
        
        [self.camera setValue:vhatx forKey:@"vHatX"];
        [self.camera setValue:vhaty forKey:@"vHatY"];
        [self.camera setValue:vhatz forKey:@"vHatZ"];

    }
}

- (void)cameraFixViewMatrix {
    GKSmatrix_3    aViewMatrix;
    
    GKSCameraRep *camera = self.camera;
    
    if (camera != nil) {
        GKSvector3d up_vector = GKSMakeVector(camera.upX.doubleValue, camera.upY.doubleValue, camera.upZ.doubleValue);

        GKSvector3d dir_vector = GKSMakeVector(camera.dirX.doubleValue, camera.dirY.doubleValue, camera.dirZ.doubleValue);

        GKSvector3d position = GKSMakeVector(camera.positionX.doubleValue, camera.positionY.doubleValue, camera.positionZ.doubleValue);

        gks_gen_view_matrix(position, dir_vector, up_vector, aViewMatrix);
        gks_set_view_matrix(aViewMatrix);
        
        
        // Set UI values
        NSNumber *uhatx = [NSNumber numberWithDouble:aViewMatrix[0][0]];
        NSNumber *uhaty = [NSNumber numberWithDouble:aViewMatrix[0][1]];
        NSNumber *uhatz = [NSNumber numberWithDouble:aViewMatrix[0][2]];

        NSNumber *vhatx = [NSNumber numberWithDouble:aViewMatrix[1][0]];
        NSNumber *vhaty = [NSNumber numberWithDouble:aViewMatrix[1][1]];
        NSNumber *vhatz = [NSNumber numberWithDouble:aViewMatrix[1][2]];
        
        [self.camera setValue:uhatx forKey:@"uHatX"];
        [self.camera setValue:uhaty forKey:@"uHatY"];
        [self.camera setValue:uhatz forKey:@"uHatZ"];
        
        [self.camera setValue:vhatx forKey:@"vHatX"];
        [self.camera setValue:vhaty forKey:@"vHatY"];
        [self.camera setValue:vhatz forKey:@"vHatZ"];

    }
}


@end
