//
//  GKSDrawingController.m
//  GeKoS
//
//  Created by Alex Popadich on 3/6/22.
//

#import "GKSDrawingController.h"
#import "GKSCameraRep.h"
#import "GKSScene.h"

@interface GKSDrawingController ()

@end

@implementation GKSDrawingController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    NSLog(@"Drawing Controller Here! Ready to go.");
    
    NSLog(@"theScene (representedObject) should not be set, so it is: %@ ", self.representedObject);
    
}

- (void)setCenterOfProjection {
    GKSScene *scene = self.representedObject;
    GKSCameraRep *camera = scene.camera;
    if (camera != nil) {
        NSNumber *prtype = camera.projectionType;
        if (prtype.intValue == kPerspectiveProjection) {
            //Set perspective distance
            double distance = [camera.focalLength doubleValue];
            gks_set_perspective_depth(distance);
        }
    }
}

- (void)sceneChange {
    NSLog(@"Scene has changed. Update some local settings.");
    GKSScene *scene = self.representedObject;
    if (scene != nil) {
        GKSDrawingView* theView = (GKSDrawingView*)self.view;
        theView.backgroundColor = scene.worldBackColor;
        theView.lineColor = scene.worldLineColor;
        theView.fillColor = scene.worldFillColor;
    }
}

- (void)cameraChange {
    GKSmatrix_3    aViewMatrix;
    
    GKSScene *scene = self.representedObject;
    GKSCameraRep *camera = scene.camera;
    BOOL useLookAtPoint = YES; //TODO: hard coded value must be replaced
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
        GKSpoint_3 normal_vector;
        normal_vector.x = [camera.dirX doubleValue];
        normal_vector.y = [camera.dirY doubleValue];
        normal_vector.z = [camera.dirZ doubleValue];
        
        //Set View Reference Point
        GKSpoint_3 cam_ref;
        cam_ref.x = [camera.positionX doubleValue];
        cam_ref.y = [camera.positionY doubleValue];
        cam_ref.z = [camera.positionZ doubleValue];
        
        if (useLookAtPoint) {
            gks_compute_look_at_matrix(cam_ref.x, cam_ref.y, cam_ref.z, normal_vector.x, normal_vector.y, normal_vector.z, up_vector.x, up_vector.y, up_vector.z, aViewMatrix);
        } else {
            gks_create_view_matrix(cam_ref.x, cam_ref.y, cam_ref.z, normal_vector.x, normal_vector.y, normal_vector.z, up_vector.x, up_vector.y, up_vector.z, aViewMatrix);
        }
        gks_set_view_matrix(aViewMatrix);
        
        [self setCenterOfProjection];
    }
}


- (void)setHiddenSurface:(BOOL) flag
{
    // stub method need access to drawing view property
    GKSDrawingView* drawview = (GKSDrawingView*)self.view;
    drawview.showSurface = flag;
}







- (void)registerAsObserverForObserver:(GKSCameraRep *)camera
{
    NSLog(@"A funny method name.");
}

@end
