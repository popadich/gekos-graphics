//
//  GKSDrawingController.m
//  GeKoS
//
//  Created by Alex Popadich on 3/6/22.
//

#import "GKSDrawingController.h"
#import "GKSSceneRep.h"
#include "gks.h"

@interface GKSDrawingController ()

@property (strong)GKSSceneRep *scene;

@end

@implementation GKSDrawingController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    GKSSceneRep *scene = (GKSSceneRep *)self.representedObject;
    
    GKSDrawingView *drawingView = (GKSDrawingView *)self.view;
    drawingView.scene = scene;
    self.scene = scene;
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

    gks_norms_set_device_viewport(self.scene.context, &new_limits);
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
    gks_norms_set_device_viewport(self.scene.context, &port_rect); // get a controller to do this
}

@end
