//
//  GKSCameraController.m
//  GeKoS
//
//  Created by Alex Popadich on 3/2/22.
//

#import "GKSCameraController.h"
#import "GKSConstants.h"
#import "GKSContent.h"
#import "GKSCameraRep.h"


static double head_size_adjust = 1.0;

@interface GKSCameraController ()

@property (weak)IBOutlet GKSHeadView *headView;

@end

static void *CameraRotationContext = &CameraRotationContext;
static void *CameraPositionContext = &CameraPositionContext;
static void *CameraProjectionContext = &CameraProjectionContext;
static void *CameraFocusContext = &CameraFocusContext;


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
    
    // use values from camera entity to initialize cameraRep
//    CameraEntity *cameraEnt = (CameraEntity *)self.representedObject;

    GKSCameraRep *cameraRep = self.camera;
    if (cameraRep != nil) {
        [self resetCamera:cameraRep];
        [self registerAsObserverForCamera];
    }
}


- (void) dealloc
{
    GKSCameraRep *camera = self.camera;
    [camera removeObserver:self forKeyPath:@"positionX" context:CameraPositionContext];
    [camera removeObserver:self forKeyPath:@"positionY" context:CameraPositionContext];
    [camera removeObserver:self forKeyPath:@"positionZ" context:CameraPositionContext];

    [camera removeObserver:self forKeyPath:@"upX" context:CameraPositionContext];
    [camera removeObserver:self forKeyPath:@"upY" context:CameraPositionContext];
    [camera removeObserver:self forKeyPath:@"upZ" context:CameraPositionContext];

    [camera removeObserver:self forKeyPath:@"yaw" context:CameraRotationContext];
    [camera removeObserver:self forKeyPath:@"pitch" context:CameraRotationContext];
    [camera removeObserver:self forKeyPath:@"roll" context:CameraRotationContext];

    [camera removeObserver:self forKeyPath:@"focalLength" context:CameraFocusContext];
    [camera removeObserver:self forKeyPath:@"near" context:CameraFocusContext];
    [camera removeObserver:self forKeyPath:@"far" context:CameraFocusContext];

    [camera removeObserver:self forKeyPath:@"projectionType" context:CameraProjectionContext];
}


- (void) resetCamera:(GKSCameraRep *)theCamera
{
    if (theCamera) {
        [theCamera zeroSettings];
        [self cameraSetProjectionType:theCamera.projectionType];
        [self cameraSetViewMatrixG];
    }

}


// copy values from camera entity to camera rep an app model object.
- (void) gripCamera;
{
    GKSCameraRep *cameraRep = self.camera;
    CameraEntity *cameraEnt = (CameraEntity *)self.representedObject;
    if ( cameraRep != nil && cameraEnt != nil ) {
        self.camera.lookX = [cameraEnt valueForKey:@"lookX"];
        self.camera.lookY = [cameraEnt valueForKey:@"lookY"];
        self.camera.lookZ = [cameraEnt valueForKey:@"lookZ"];
        self.camera.projectionType = [cameraEnt valueForKey:@"projectionType"];
        self.camera.focalLength = [cameraEnt valueForKey:@"focalLength"];
        self.camera.near = [cameraEnt valueForKey:@"near"];
        self.camera.far = [cameraEnt valueForKey:@"far"];
        self.camera.upX = [cameraEnt valueForKey:@"upX"];
        self.camera.upY = [cameraEnt valueForKey:@"upY"];
        self.camera.upZ = [cameraEnt valueForKey:@"upZ"];
        self.camera.positionX = [cameraEnt valueForKey:@"positionX"];
        self.camera.positionY = [cameraEnt valueForKey:@"positionY"];
        self.camera.positionZ = [cameraEnt valueForKey:@"positionZ"];
        self.camera.yaw = [cameraEnt valueForKey:@"yaw"];
        self.camera.pitch = [cameraEnt valueForKey:@"pitch"];
        self.camera.roll = [cameraEnt valueForKey:@"roll"];
    }
//    [self cameraSetProjectionType:[cameraEnt valueForKey:@"projectionType"]];
//    [self cameraSetProjectionTypeG];
//    [self cameraSetViewMatrixG];
//    [self adjustHead];
//    
//    NSString *moveType = @"Location";  // TODO: use defined const
//    [self notifyAllConcerned:moveType];
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
    
    [camera addObserver:self forKeyPath:@"projectionType" options:NSKeyValueObservingOptionNew context:CameraProjectionContext];
    
    [camera addObserver:self forKeyPath:@"focalLength" options:NSKeyValueObservingOptionNew context:CameraFocusContext];

    [camera addObserver:self forKeyPath:@"near" options:NSKeyValueObservingOptionNew context:CameraFocusContext];

    [camera addObserver:self forKeyPath:@"far" options:NSKeyValueObservingOptionNew context:CameraFocusContext];

}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == CameraPositionContext) {
        [self cameraSetViewMatrixG];
        [self adjustHead];
        
        NSString *moveType = @"Location";  // TODO: use defined const
        [self notifyAllConcerned:moveType];
    
    } else if (context == CameraRotationContext) {
        [self cameraSetEulerG];
        [self adjustHead];
        
        NSString *moveType = @"Rotation";  // TODO: use defined const
        [self notifyAllConcerned:moveType];
        
    } else if (context == CameraProjectionContext) {
        
        NSNumber *nprType = change[NSKeyValueChangeNewKey];
        [self cameraSetProjectionType:nprType];
        
        NSString *moveType = @"Projection";  // TODO: use defined const
        [self notifyAllConcerned:moveType];
        
    } else if (context == CameraFocusContext) {
        [self cameraSetProjectionTypeG];
        
        NSString *moveType = @"Focus";  // TODO: use defined const
        [self notifyAllConcerned:moveType];
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

//
//- (IBAction)setCameraFocus:(id)sender
//{
//    if ([sender isKindOfClass:[NSSlider class]]) {
//        NSSlider *slider = sender;
//        NSNumber *sliderValue = [slider objectValue];
//        self.camera.focalLength =  sliderValue;
//        [self cameraSetProjectionTypeG];
//    }
//}
//
//- (IBAction)setCameraLocation:(id)sender
//{
//    if ([sender isKindOfClass:[NSTextField class]]) {
//        NSTextField *textField = sender;
//        if (textField.tag == 1) {
//            NSLog(@"Location Camera X Change");
//            self.camera.positionX = [textField objectValue];
//        } else if (textField.tag == 2) {
//            NSLog(@"Location Camera Y Change");
//            self.camera.positionY = [textField objectValue];
//        } else if (textField.tag == 3) {
//            self.camera.positionZ = [textField objectValue];
//        }
//        [self cameraSetViewMatrixG];
//        [self adjustHead];
//
//        NSString *moveType = @"Location";  // TODO: use defined const
//        [self notifyAllConcerned:moveType];
//    }
//}

- (void)notifyAllConcerned:(NSString *)moveType {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:moveType forKey:@"moveType"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cameraMoved" object:self userInfo:userInfo];
}



// MARK: Actions

- (IBAction)doCameraReset:(id)sender
{
    GKSCameraRep *camera = self.camera;
    [self resetCamera:camera];
    [self setHeadFocus:camera.focalLength];
    [self adjustHead];
    
}



// MARK: Projection Matrix Interactions

- (void)cameraSetProjectionType:(NSNumber *)prType {
    GKSCameraRep *camera = self.camera;
    if (camera != nil) {
        NSInteger projectionType = [prType integerValue];
        if (projectionType == kOrthogonalProjection) {
            gks_projection_set_orthogonal(camera.context);
        }
        else if (projectionType == kPerspectiveSimple) {
            //Set perspective distance
            double distance = [camera.focalLength doubleValue];
            gks_projection_set_simple(camera.context, distance);
        }
        else if (projectionType == kPerspective) {
            double distance = [camera.focalLength doubleValue];
            double alpha = 90.0 - (90.0 * distance / 100.0) + 0.1;
            double near = [camera.near doubleValue];
            double far = [camera.far doubleValue];
            gks_projection_set_perspective(camera.context, alpha, near, far);
        }
        else if (projectionType == kAlternate) {
            double distance = [camera.focalLength doubleValue];
            double alpha = 90.0 - (90.0 * distance / 100.0) + 0.1;
            double near = [camera.near doubleValue];
            double far = [camera.far doubleValue];
            gks_projection_set_alternate(camera.context, alpha, near, far);
        }
    }
}

- (void)cameraSetProjectionTypeG {
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
- (void)cameraSetViewLookAtG {
    GKSCameraRep *camera = self.camera;

    if (camera != nil) {
        GKSmatrix_3    aViewMatrix;
        
        GKSvector3d up_vector = GKSMakeVector(camera.upX.doubleValue, camera.upY.doubleValue, camera.upZ.doubleValue);
        
        GKSvector3d look_at = GKSMakeVector(camera.lookX.doubleValue, camera.lookY.doubleValue, camera.lookZ.doubleValue);
        
        GKSvector3d pos = GKSMakeVector(camera.positionX.doubleValue, camera.positionY.doubleValue, camera.positionZ.doubleValue);
        
        GKSvector3d dir_vector;
        gks_view_look_unit(look_at, pos, &dir_vector);

        // Set Camera View Matrix
        gks_view_matrix_compute(camera.context, pos, dir_vector, up_vector, aViewMatrix);
        gks_view_matrix_set(camera.context, aViewMatrix);

        
        // Set UI values
        NSNumber *uhatx = [NSNumber numberWithDouble:aViewMatrix[0][0]];
        NSNumber *uhaty = [NSNumber numberWithDouble:aViewMatrix[0][1]];
        NSNumber *uhatz = [NSNumber numberWithDouble:aViewMatrix[0][2]];

        NSNumber *vhatx = [NSNumber numberWithDouble:aViewMatrix[1][0]];
        NSNumber *vhaty = [NSNumber numberWithDouble:aViewMatrix[1][1]];
        NSNumber *vhatz = [NSNumber numberWithDouble:aViewMatrix[1][2]];
        
        [camera setValue:@(dir_vector.crd.x) forKey:@"dirX"];
        [camera setValue:@(dir_vector.crd.y) forKey:@"dirY"];
        [camera setValue:@(dir_vector.crd.z) forKey:@"dirZ"];
        
        [camera setValue:uhatx forKey:@"uHatX"];
        [camera setValue:uhaty forKey:@"uHatY"];
        [camera setValue:uhatz forKey:@"uHatZ"];
        
        [camera setValue:vhatx forKey:@"vHatX"];
        [camera setValue:vhaty forKey:@"vHatY"];
        [camera setValue:vhatz forKey:@"vHatZ"];

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

        gks_view_matrix_compute(camera.context, position, dir_vector, up_vector, aViewMatrix);
        gks_view_matrix_set(camera.context, aViewMatrix);
        
        
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
    
    
    // TODO: move to library
    gks_create_identity_matrix_3(matrixEuler);
    gks_create_z_rotation_matrix_3(phi, matrixEuler);
    gks_accumulate_y_rotation_matrix_3(psi, matrixEuler);
    gks_accumulate_x_rotation_matrix_3(theta, matrixEuler);
    
    gks_matrix_multiply_3(matrixEuler, earth_coords, model_coords);
    gks_create_translation_matrix_3(-pos.crd.x, -pos.crd.y, -pos.crd.z, translationMatrix);
    gks_matrix_multiply_3(model_coords, translationMatrix, result);
    gks_view_matrix_set(self.camera.context, result);
    
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
