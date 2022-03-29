//
//  GKSDrawingController.m
//  GeKoS
//
//  Created by Alex Popadich on 3/6/22.
//

#import "GKSDrawingController.h"
#include "gks/gks.h"


@implementation GKSDrawingController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    

}

- (void)viewDidLayout {
    [super viewDidLayout];
    
    // Do view geometry here
    // TODO: only adjust when view resizes
    NSRect myRect = self.view.bounds;
    gks_trans_adjust_device_viewport(myRect.origin.x, myRect.size.width, myRect.origin.y, myRect.size.height);
}

@end
