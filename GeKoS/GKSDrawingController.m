//
//  GKSDrawingController.m
//  GeKoS
//
//  Created by Alex Popadich on 3/6/22.
//

#import "GKSDrawingController.h"
#import "GKSScene.h"
#include "gks/gks.h"

@interface GKSDrawingController ()

@property (strong)GKSScene *theScene;

@end

@implementation GKSDrawingController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    GKSScene *scene = self.representedObject;
    GKSDrawingView *drawView = (GKSDrawingView *)self.view;
    drawView.scene = scene;
    self.theScene = scene;

}

- (void)viewDidLayout {
    [super viewDidLayout];
    
    // Do view geometry here
    // TODO: adjust when view resizes
    NSRect myRect = self.view.bounds;
    // TODO: view tranform index is set to zero
    gks_trans_adjust_device_viewport(0, myRect.origin.x, myRect.size.width, myRect.origin.y, myRect.size.height);
}

@end
