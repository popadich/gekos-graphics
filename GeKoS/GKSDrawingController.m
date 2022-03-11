//
//  GKSDrawingController.m
//  GeKoS
//
//  Created by Alex Popadich on 3/6/22.
//

#import "GKSDrawingController.h"
#import "GKSConstants.h"
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

- (void)setHiddenSurface:(BOOL) flag
{
    // stub method need access to drawing view property
    GKSDrawingView* drawview = (GKSDrawingView*)self.view;
    drawview.visibleSurfaceOnly = flag;
}


@end
