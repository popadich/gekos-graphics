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

- (void)cameraFixViewMatrix;
- (void)cameraDoLookAtG;

- (void)cameraSetProjectionType:(NSNumber *)projectionType;
- (void)cameraFixProjectionMatrix;

@end

NS_ASSUME_NONNULL_END
