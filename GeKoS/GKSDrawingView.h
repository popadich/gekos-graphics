//
//  GKSDrawingView.h
//  GeKoS
//
//  Created by Alex Popadich on 2/24/22.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKSDrawingView : NSView

@property (nonatomic, copy) NSColor *backgroundColor;
@property (nonatomic, assign) BOOL visibleSurfaceOnly;

@end

NS_ASSUME_NONNULL_END
