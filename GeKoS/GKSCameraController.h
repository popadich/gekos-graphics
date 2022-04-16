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

- (IBAction)doCameraReset:(id)sender;

- (void)cameraSetViewMatrixG;
- (void)cameraSetViewLookAtG;

- (void)cameraSetProjectionType:(NSNumber *)projectionType;
- (void)cameraSetProjectionTypeG;

@end

NS_ASSUME_NONNULL_END
