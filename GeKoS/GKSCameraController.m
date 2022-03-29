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
static void *CameraPositionContext = &CameraPositionContext;


@implementation GKSCameraController


void logMatrix(GKSmatrix_3 M) {
    NSLog(@"uHat: %1.3lf, %1.3lf, %1.3lf, %1.3lf", M[0][0], M[0][1], M[0][2], M[0][3] );
    NSLog(@"vHat: %1.3lf, %1.3lf, %1.3lf, %1.3lf", M[1][0], M[1][1], M[1][2], M[1][3] );
    NSLog(@"Dir : %1.3lf, %1.3lf, %1.3lf, %1.3lf", M[2][0], M[2][1], M[2][2], M[2][3] );
    NSLog(@"Homo: %1.3lf, %1.3lf, %1.3lf, %1.3lf\n.", M[3][0], M[3][1], M[3][2], M[3][3] );
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    GKSCameraRep *camera = (GKSCameraRep *)self.representedObject;
    if (camera) {
        self.camera = camera;
        [self cameraDefaultSettings:camera];
        [self registerAsObserverForCamera];
    }

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
        
        theCamera.roll  = @0.0;
        theCamera.pitch = @0.0;
        theCamera.yaw   = @0.0;
        
        theCamera.lookX = @0.0;
        theCamera.lookY = @0.0;
        theCamera.lookZ = @0.0;
        
        NSNumber *prType =  [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefProjectionType];
        
        theCamera.projectionType = prType;
        [self cameraSetProjectionType:prType];
        [self cameraSetViewMatrixG];
    }

}


- (void)registerAsObserverForCamera
{
    GKSCameraRep *camera = self.camera;

    [camera addObserver:self forKeyPath:@"positionX" options:NSKeyValueObservingOptionNew context:CameraPositionContext];
    [camera addObserver:self forKeyPath:@"positionY" options:NSKeyValueObservingOptionNew context:CameraPositionContext];
    [camera addObserver:self forKeyPath:@"positionZ" options:NSKeyValueObservingOptionNew context:CameraPositionContext];

    [camera addObserver:self forKeyPath:@"upX" options:NSKeyValueObservingOptionNew context:CameraPositionContext];
    [camera addObserver:self forKeyPath:@"upY" options:NSKeyValueObservingOptionNew context:CameraPositionContext];
    [camera addObserver:self forKeyPath:@"upZ" options:NSKeyValueObservingOptionNew context:CameraPositionContext];
    
    [camera addObserver:self forKeyPath:@"yaw" options:NSKeyValueObservingOptionNew context:CameraRotationContext];
    [camera addObserver:self forKeyPath:@"pitch" options:NSKeyValueObservingOptionNew context:CameraRotationContext];
    [camera addObserver:self forKeyPath:@"roll" options:NSKeyValueObservingOptionNew context:CameraRotationContext];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == CameraPositionContext) {
        [self cameraSetViewMatrixG];
        [self adjustHead];
        
    } else if (context == CameraRotationContext) {
        [self cameraSetEulerG];
        [self adjustHead];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark USER Interaction

- (void)setHeadFocus:(NSNumber *)focal;
{
    // increase focal length on head by a bit, so that the
    // head is visible in its frame.
    double focal_length = [focal doubleValue] + head_size_adjust;
    NSNumber *fl = [NSNumber numberWithDouble:focal_length];
    self.headView.headFocalLength = fl;
    [self.headView setNeedsDisplay:YES];

}

- (void)adjustHead {
    self.headView.headYaw = self.camera.yaw;

    // reverse the roll value because x-axis is coming out at us and a positive rotation
    // from that refererence appears as a negative rotation of our head. The head is
    // oriented as if looking along the negative x-axis direction.
    self.headView.headPitch = [NSNumber numberWithDouble:(-1 * [self.camera.pitch doubleValue])];
    self.headView.headRoll = [NSNumber numberWithDouble:(-1 * [self.camera.roll doubleValue])];
    
    [self.headView setNeedsDisplay:YES];
}


// MARK: IBACTIONS

- (IBAction)doChangeProjectionType:(id)sender;
{
    NSInteger projectionType = [sender selectedTag];
    NSNumber *prType = [NSNumber numberWithInteger:projectionType];
    [self cameraSetProjectionType:prType];
}

- (IBAction)doChangeFocalLength:(id)sender
{
    if ([sender isKindOfClass:[NSSlider class]]) {
        NSNumber* slide = [sender objectValue];
        [self setHeadFocus:slide];              // Head
        [self cameraSetProjectionMatrixG];      // this is a bit overkill,
                                                // create a method for setting focal length
                                                // alone and recompute existing projection matrix
    }
}

- (IBAction)doChangeNearFar:(id)sender
{
    if ([sender isKindOfClass:[NSTextField class]]) {
        if ([sender tag] == 1 || [sender tag] == 2) {
            [self cameraSetProjectionMatrixG];
        }
    }
}

- (IBAction)doCameraReset:(id)sender
{
    GKSCameraRep *camera = self.camera;
    [self cameraDefaultSettings:camera];
    [self setHeadFocus:camera.focalLength];
    [self adjustHead];
}



// MARK: Projection Matrix Interactions

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

- (void)cameraSetProjectionMatrixG {
    GKSCameraRep *camera = self.camera;
    if (camera != nil) {
        NSNumber *prType = camera.projectionType;
        [self cameraSetProjectionType:prType];
    }
    
}


// MARK: View Matrix Interactions


// This uses the Look At point, camera Location, and Up vector to
// compute and set the global view matrix in the C library.
//  LOOK, POS, UP
- (void)camerSetViewLookAtG {
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


// This uses the view direction vector, camera Location and Up vector to
// compute and set the global view matrix in the C library.
// DIR, POS, UP
- (void)cameraSetViewMatrixG {
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

- (void)cameraSetEulerTheta:(NSNumber *)yawNum eulerPhi:(NSNumber *)pitchNum eulerPsi:(NSNumber *)rollNum atPosition:(GKSvector3d)pos
{
    GKSmatrix_3 earth_coords = {1.0, 0.0, 0.0, 0.0,
                             0.0, 1.0, 0.0, 0.0,
                             0.0, 0.0, -1.0, 0.0,
                             0.0, 0.0, 0.0, 1.0
    };
        
    GKSmatrix_3 matrixEuler;
    GKSmatrix_3 translationMatrix;
    GKSmatrix_3 model_coords;
    GKSmatrix_3 result;
    gks_create_identity_matrix_3(model_coords);

    GKSfloat psi = -yawNum.doubleValue;
    GKSfloat theta = pitchNum.doubleValue;
    GKSfloat phi = rollNum.doubleValue ;
    
    // maybe theta needs be negative? Or control min and max switched?
    gks_create_identity_matrix_3(matrixEuler);
    gks_create_z_rotation_matrix_3(phi, matrixEuler);
    gks_accumulate_y_rotation_matrix_3(psi, matrixEuler);
    gks_accumulate_x_rotation_matrix_3(theta, matrixEuler);
    
//    NSLog(@"Euler");
//    logMatrix(matrixEuler);
    
    gks_multiply_matrix_3(matrixEuler, earth_coords, model_coords);
    
//    NSLog(@"Model");
//    logMatrix(model_coords);

    gks_create_translation_matrix_3(-pos.crd.x, -pos.crd.y, -pos.crd.z, translationMatrix);

//    NSLog(@"Translation");
//    logMatrix(translationMatrix);
    
    gks_multiply_matrix_3(model_coords, translationMatrix, result);
    
//    NSLog(@"Result");
//    logMatrix(result);
    
    gks_set_view_matrix(result);
    
    // set the UI values
    NSNumber *uhatx = [NSNumber numberWithDouble:result[0][0]];
    NSNumber *uhaty = [NSNumber numberWithDouble:result[0][1]];
    NSNumber *uhatz = [NSNumber numberWithDouble:result[0][2]];
    
    NSNumber *vhatx = [NSNumber numberWithDouble:result[1][0]];
    NSNumber *vhaty = [NSNumber numberWithDouble:result[1][1]];
    NSNumber *vhatz = [NSNumber numberWithDouble:result[1][2]];
    
    NSNumber *dirx = [NSNumber numberWithDouble:result[2][0]];
    NSNumber *diry = [NSNumber numberWithDouble:result[2][1]];
    NSNumber *dirz = [NSNumber numberWithDouble:result[2][2]];
    
    [self.camera setValue:uhatx forKey:@"uHatX"];
    [self.camera setValue:uhaty forKey:@"uHatY"];
    [self.camera setValue:uhatz forKey:@"uHatZ"];
    
    [self.camera setValue:vhatx forKey:@"vHatX"];
    [self.camera setValue:vhaty forKey:@"vHatY"];
    [self.camera setValue:vhatz forKey:@"vHatZ"];
    
    self.camera.dirX = dirx;
    self.camera.dirY = diry;
    self.camera.dirZ = dirz;


}

// This uses the rotation angles, and camera Location to
// compute and set the global view matrix in the C library.
//
- (void)cameraSetEulerG {
    GKSCameraRep *camera = self.camera;
    if (camera) {
        NSNumber *yawNum = self.camera.yaw;
        NSNumber *pitchNum = self.camera.pitch;
        NSNumber *rollNum = self.camera.roll;
        
        GKSvector3d position = [self.camera positionVector];
        [self cameraSetEulerTheta:yawNum eulerPhi:pitchNum eulerPsi:rollNum atPosition:position];
    }
    
}


@end
