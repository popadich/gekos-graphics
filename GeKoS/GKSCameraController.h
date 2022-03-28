//
//  GKSCameraController.h
//  GeKoS
//
//  Created by Alex Popadich on 3/2/22.
//

#import <Cocoa/Cocoa.h>
#import "GKSHeadView.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKSCameraController : NSViewController

- (void)cameraSetViewMatrixG;
- (void)camerSetViewLookAtG;

- (void)cameraSetProjectionType:(NSNumber *)projectionType;
- (void)cameraSetProjectionMatrixG;

@end

NS_ASSUME_NONNULL_END
