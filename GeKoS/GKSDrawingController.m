//
//  GKSDrawingController.m
//  GeKoS
//
//  Created by Alex Popadich on 3/6/22.
//

#import "GKSDrawingController.h"
#import "GKSSceneController.h"
#include "gks/gks.h"

@interface GKSDrawingController ()

@property (strong)GKSSceneController *theScene;

@end

@implementation GKSDrawingController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    GKSSceneController *scene = self.representedObject;
    GKSDrawingView *drawView = (GKSDrawingView *)self.view;
    drawView.scene = scene;
    self.theScene = scene;

}

- (void)viewDidLayout {
    [super viewDidLayout];
    
    // Do view geometry here
    // TODO: adjust when view resizes
    NSRect myRect = self.view.bounds;
    GKSlimits_2 new_limits;
    new_limits.xmin = myRect.origin.x;
    new_limits.ymin = myRect.origin.y;
    new_limits.xmax = myRect.size.width;
    new_limits.ymax = myRect.size.height;

    gks_norms_set_device_viewport(self.context, &new_limits);
}

- (void)refresh {
    [self.view setNeedsDisplay:YES];
}

- (GKSlimits_2)getPortLimits
{
    NSRect myRect = self.view.bounds;
    GKSlimits_2 new_limits;
    new_limits.xmin = myRect.origin.x;
    new_limits.ymin = myRect.origin.y;
    new_limits.xmax = myRect.size.width;
    new_limits.ymax = myRect.size.height;
    return new_limits;
}

- (void)drawingSetViewRectG {
    // Get values world volume from data and device limits from view bounds
    GKSlimits_2 port_rect = [self getPortLimits];
    
    // Set normalization value transforms
    gks_norms_set_device_viewport(self.context, &port_rect); // get a controller to do this
}

@end
