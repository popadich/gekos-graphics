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

@property (nonatomic, strong) NSNumber* headRoll;
@property (nonatomic, strong) NSNumber* headPitch;
@property (nonatomic, strong) NSNumber* headYaw;
@property (nonatomic, strong) NSNumber* headFocalLength;

@end

NS_ASSUME_NONNULL_END
