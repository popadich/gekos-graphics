//
//  GKSDrawingView.m
//  GeKoS
//
//  Created by Alex Popadich on 2/24/22.
//

#import "GKSDrawingView.h"

@interface GKSDrawingView () {
    NSColor *bluePrintBlueColor;
    NSColor *maizeColor;
}
@property (nonatomic, assign) CGFloat itemLineWidth;

@end


@implementation GKSDrawingView

- (void)awakeFromNib {
    bluePrintBlueColor = [NSColor colorWithRed:0.066 green:0.510 blue:0.910 alpha:1.0];
    maizeColor = [NSColor colorWithRed:1.0 green:203.0/255.0 blue:5.0/255.0 alpha:1.0];
    self.backgroundColor = bluePrintBlueColor;
    _showSurface = NO;
    _itemLineWidth = 1.0;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    // erase the background by drawing background color
    [maizeColor set];
    [NSBezierPath fillRect:dirtyRect];
    
    NSRect blueprintBox = NSInsetRect(self.bounds, 20.0, 20.0);
    
    [self.backgroundColor set];
    NSBezierPath *boxPath = [NSBezierPath bezierPathWithRect:blueprintBox];
    [NSBezierPath fillRect:blueprintBox];
    
    [NSColor.whiteColor set];
    [boxPath setLineWidth:self.itemLineWidth];
    [boxPath stroke];

}

@end