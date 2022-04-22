//
//  GKSDrawingController.h
//  GeKoS
//
//  Created by Alex Popadich on 3/6/22.
//

#import <Cocoa/Cocoa.h>
#import "GKSDrawingView.h"

NS_ASSUME_NONNULL_BEGIN


@interface GKSDrawingController : NSViewController

- (void)refresh;
- (GKSlimits_2)getPortLimits;

- (void)drawingSetViewRectG;

@end

NS_ASSUME_NONNULL_END
