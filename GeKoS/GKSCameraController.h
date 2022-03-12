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

@property (strong)IBOutlet NSNumber *useLookAtFlag;

- (void)cameraSetViewMatrixG;
- (void)cameraSetCenterOfProjectionG;

@end

NS_ASSUME_NONNULL_END
