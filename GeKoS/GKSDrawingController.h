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

@property (assign)GKScontext3DPtr context;

- (void)refresh;
- (GKSlimits_2)getPortLimits;


@end

NS_ASSUME_NONNULL_END
