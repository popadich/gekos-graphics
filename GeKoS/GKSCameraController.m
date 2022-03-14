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
    
    self.useLookAtFlag = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefLookAtPoint];
    
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
    GKSpoint_3 vector_y = {0.0, 1.0, 0.0, 1.0};  // unit vector along the y-axis

    GKSpoint_3 comp;
    GKSmatrix_3 T;

    double theta = [self.camera.yaw doubleValue];
    double psi = [self.camera.pitch doubleValue];
    double phi = [angle doubleValue];

    gks_set_identity_matrix_3(T);
    gks_create_z_rotation_matrix_3(-phi, T);
    gks_accumulate_x_rotation_matrix_3(-psi, T);
    gks_accumulate_y_rotation_matrix_3(theta, T);

    gks_transform_point_3(T, &vector_y, &comp);
    
    [self.representedObject setValue:[NSNumber numberWithDouble:comp.x] forKey:@"dirX"];
    [self.representedObject setValue:[NSNumber numberWithDouble:comp.y] forKey:@"dirY"];
    [self.representedObject setValue:[NSNumber numberWithDouble:comp.z] forKey:@"dirZ"];
}

- (void)changePitch:(NSNumber *)angle
{
    GKSpoint_3 vector_z = {0.0, 0.0, 1.0, 1.0};  // unit vector along the z-axis

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
    gks_transform_point_3(T, &vector_z, &comp);
    
    [self.representedObject setValue:[NSNumber numberWithDouble:comp.x] forKey:@"dirX"];
    [self.representedObject setValue:[NSNumber numberWithDouble:comp.y] forKey:@"dirY"];
    [self.representedObject setValue:[NSNumber numberWithDouble:comp.z] forKey:@"dirZ"];

}

- (void)changeYaw:(NSNumber *)angle
{
    GKSpoint_3 vector_z = {0.0, 0.0, 1.0, 1.0};  // unit vector along the z-axis

    GKSpoint_3 trans_point;
    GKSmatrix_3 T;

    double theta = [angle doubleValue];
    double psi = [self.camera.pitch doubleValue];
    double phi = [self.camera.roll doubleValue];

    // maybe theta needs be negative? Or control min and max switched?
    gks_set_identity_matrix_3(T);
    gks_create_y_rotation_matrix_3(theta, T);
    gks_accumulate_x_rotation_matrix_3(-psi, T);
    gks_accumulate_z_rotation_matrix_3(phi, T);
    gks_transform_point_3(T, &vector_z, &trans_point);

    [self.representedObject setValue:[NSNumber numberWithDouble:trans_point.x] forKey:@"dirX"];
    [self.representedObject setValue:[NSNumber numberWithDouble:trans_point.y] forKey:@"dirY"];
    [self.representedObject setValue:[NSNumber numberWithDouble:trans_point.z] forKey:@"dirZ"];

}

- (IBAction)changeVisibleSurface:(id)sender
{
    if ([sender isKindOfClass:[NSButton class]]) {
        bool onState = [sender state];
        //gks_objarr_set_hidden_surface_removal(onState);
        NSLog(@"Visible Surfaces Only: %d", onState);
    }
}



- (IBAction)cameraReset:(id)sender
{
    GKSCameraRep *camera = self.camera;
    
    if (camera) {
        camera.upX = @0.0;
        camera.upY = @1.0;
        camera.upZ = @0.0;
        camera.positionX = @0.0;
        camera.positionY = @0.0;
        camera.positionZ = @2.0;
        camera.dirX = @0.0;
        camera.dirY = @0.0;
        camera.dirZ = @-1.0;
    }

    camera.focalLength = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefPerspectiveDistance];
    
    self.camera.roll = @0.0;
    self.camera.pitch = @0.0;
    self.camera.yaw = @0.0;
    
}



//MARK: LIBRARY interactions

- (void)cameraSetCenterOfProjectionG {
    GKSCameraRep *camera = self.camera;
    if (camera != nil) {
        NSNumber *prtype = camera.projectionType;
        if (prtype.intValue == kPerspective) {
            //Set perspective distance
            double distance = [camera.focalLength doubleValue];
            gks_set_perspective_depth(distance);
        }
    }
}


- (void)cameraDoLookAt {
    GKSCameraRep *camera = self.camera;

    if (camera != nil) {
        //
        // init 3D camera view and window viewport
        // sets up aView matrix based on VRP, VPN and VUP
        //Set View Up Vector
        GKSvector3d up_vector;
        up_vector.crd.x = [camera.upX doubleValue];
        up_vector.crd.y = [camera.upY doubleValue];
        up_vector.crd.z = [camera.upZ doubleValue];
        
        //Set View Plane Normal
        // the view plane is like a tv screen in front of your face.
        // this vector sets the normal to that "screen". The plane is
        // actually an infinite plane.
        GKSvector3d look_at;
        look_at.crd.x = [camera.lookX doubleValue];
        look_at.crd.y = [camera.lookY doubleValue];
        look_at.crd.z = [camera.lookZ doubleValue];
        
        //Set View Reference Point
        GKSvector3d pos;
        pos.crd.x = [camera.positionX doubleValue];
        pos.crd.y = [camera.positionY doubleValue];
        pos.crd.z = [camera.positionZ doubleValue];
        
        GKSvector3d dir_vector;
        gks_compute_dir_vector(pos, look_at, &dir_vector);
        camera.dirX = @(dir_vector.crd.x);
        camera.dirY = @(dir_vector.crd.y);
        camera.dirZ = @(dir_vector.crd.z);
        
        GKSmatrix_3    aViewMatrix;
        gks_compute_camera_look_at_matrix(pos.crd.x, pos.crd.y, pos.crd.z,
                                          look_at.crd.x, look_at.crd.y, look_at.crd.z,
                                          up_vector.crd.x, up_vector.crd.y, up_vector.crd.z,
                                          aViewMatrix);
        gks_set_view_matrix(aViewMatrix);

        [self cameraSetCenterOfProjectionG];
    }
}

- (void)cameraSetViewMatrixG {
    GKSmatrix_3    aViewMatrix;
    
    GKSCameraRep *camera = self.camera;
    
    if (camera != nil) {
        //
        // init 3D camera view and window viewport
        // sets up aView matrix based on VRP, VPN and VUP
        //Set View Up Vector
        GKSpoint_3 up_vector;
        up_vector.x = [camera.upX doubleValue];
        up_vector.y = [camera.upY doubleValue];
        up_vector.z = [camera.upZ doubleValue];
        
        //Set View Plane Normal
        // the view plane is like a tv screen in front of your face.
        // this vector sets the normal to that "screen". The plane is
        // actually an infinite plane.
        GKSpoint_3 dir_vector;
        dir_vector.x = [camera.dirX doubleValue];
        dir_vector.y = [camera.dirY doubleValue];
        dir_vector.z = [camera.dirZ doubleValue];
        
        //Set View Reference Point
        GKSpoint_3 position;
        position.x = [camera.positionX doubleValue];
        position.y = [camera.positionY doubleValue];
        position.z = [camera.positionZ doubleValue];
        
        gks_create_camera_view_matrix(position.x, position.y, position.z, dir_vector.x, dir_vector.y, dir_vector.z, up_vector.x, up_vector.y, up_vector.z, aViewMatrix);
        
        gks_set_view_matrix(aViewMatrix);
        
        [self cameraSetCenterOfProjectionG];
    }
}


@end
