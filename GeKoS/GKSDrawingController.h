//
//  GKSDrawingController.h
//  GeKoS
//
//  Created by Alex Popadich on 3/6/22.
//

#import <Cocoa/Cocoa.h>
#import "GKSDrawingView.h"

NS_ASSUME_NONNULL_BEGIN

@class GKSCameraRep;

@interface GKSDrawingController : NSViewController

- (void)registerAsObserverForObserver:(GKSCameraRep*)camera;
- (void)cameraChange;
- (void)setCenterOfProjection;

@end

NS_ASSUME_NONNULL_END
