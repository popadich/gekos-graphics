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

@property (nonatomic, strong) NSNumber* upTilt;
@property (nonatomic, strong) NSNumber* planePitch;
@property (nonatomic, strong) NSNumber* planeYaw;

@property (weak)IBOutlet GKSHeadView *headView;

@end

NS_ASSUME_NONNULL_END
