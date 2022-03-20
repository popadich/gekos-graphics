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

- (void)cameraClampViewMatrixG;
- (void)cameraSetCenterOfProjectionG;
- (void)cameraDoLookAtG;

// direct action
- (void)cameraSetProjectionType:(NSInteger)projectionType;
- (IBAction)changeProjectionType:(id)sender;

@end

NS_ASSUME_NONNULL_END
