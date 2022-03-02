//
//  GKSCameraView.m
//  GeKoS
//
//  Created by Alex Popadich on 3/2/22.
//

#import "GKSCameraView.h"

@implementation GKSCameraView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
//    [[NSColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.9] set];
    NSColor *maizeBlue = [NSColor colorWithRed:0.0 green:39.0/255.0 blue:76.0/255.0 alpha:1.0];
    [maizeBlue set];
    [NSBezierPath fillRect:dirtyRect];
}

@end
