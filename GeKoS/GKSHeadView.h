//
//  GKSHeadView.h
//  GeKoS
//
//  Created by Alex Popadich on 3/3/22.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

#define    SCALE        60.0

@interface GKSHeadView : NSView

@property (nonatomic, weak) NSNumber* headRoll;
@property (nonatomic, weak) NSNumber* headPitch;
@property (nonatomic, weak) NSNumber* headYaw;
@property (nonatomic, weak) NSNumber* headFocalLength;

@end

NS_ASSUME_NONNULL_END
