//
//  GKSDrawingView.m
//  GeKoS
//
//  Created by Alex Popadich on 2/24/22.
//

#import "GKSDrawingView.h"
#import "GKSConstants.h"

#include "gks/gks.h"

@interface GKSDrawingView () {
    NSColor *bluePrintBlueColor;
    NSColor *maizeColor;
    NSColor *andBlueColor;

}
@property (nonatomic, assign) CGFloat itemLineWidth;


// TODO: part of call back
struct mystery_data {
    int op_num;
    bool hiddenLineRemovalFlag;
    char name[32];
    void* ns_bezier_path;
};


@end


@implementation GKSDrawingView

- (BOOL)isFlipped {
    return NO;
}

- (void)redDot {
    BOOL isDot = NO;
    
    if (isDot) {
        NSPoint redDotPoint = NSMakePoint(80.0, 50.0);
        NSRect dotRect = NSMakeRect(redDotPoint.x, redDotPoint.y, 12, 12.0);
        NSBezierPath *redDot = [NSBezierPath bezierPathWithOvalInRect:dotRect];
        [[NSColor redColor] setFill];
        [redDot fill];
    }
}

- (void)awakeFromNib {
    
    NSError* error;
    NSColor* aColor;
    
    NSData* theData =[[NSUserDefaults standardUserDefaults] dataForKey:gksPrefBackgroundColor];
    if (theData != nil) {
        aColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:theData error:&error];
        if (error.code == noErr) {
            self.backgroundColor = aColor;
        }
    }
    
    bluePrintBlueColor = [NSColor colorWithRed:0.066 green:0.510 blue:0.910 alpha:1.0];
    maizeColor = [NSColor colorWithRed:1.0 green:203.0/255.0 blue:5.0/255.0 alpha:1.0];
    andBlueColor = [NSColor colorWithRed:0.0 green:39.0/255.0 blue:76.0/255.0 alpha:1.0];
    _itemLineWidth = 1.0;
    
    
    // TODO: get rid of this
    // Callback registration.
    struct mystery_data polylinedata = {3, NO, "polyliner", NULL};
    localpolyline_cb_register(my_polyline_cb, &polylinedata);
    
}


// TODO: No callback
// Pass drawing context forward or pass transformed data back
// instead of using a callback function.
static void my_polyline_cb(GKSint polygonID, GKSint num_pt, GKSDCArrPtr dc_array, GKScolor *lineColor, void* userdata)
{
    // set pen color to object color
    NSColor* aColor = [NSColor colorWithRed:lineColor->red green:lineColor->green blue:lineColor->blue alpha:lineColor->alpha];
    [aColor setStroke];

    // dc_array holds pre-computed device coordinates
    GKSpoint_2 dc = dc_array[0]; // device coordinate
    NSBezierPath* polyPath = [NSBezierPath bezierPath];
    [polyPath moveToPoint:NSMakePoint(dc.x, dc.y)];
    for (int vertexID=1; vertexID<num_pt; vertexID++) {
        dc = dc_array[vertexID];
        [polyPath lineToPoint:NSMakePoint(dc.x, dc.y)];
    }
    [polyPath closePath];
    [polyPath stroke];
    
}



- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    [maizeColor set];
    [NSBezierPath fillRect:dirtyRect];

    [self.backgroundColor set];
    NSRect blueprintBox = NSInsetRect(self.bounds, 20.0, 20.0);
    NSBezierPath *boxPath = [NSBezierPath bezierPathWithRect:blueprintBox];
    [NSBezierPath fillRect:blueprintBox];
    
    [NSColor.whiteColor set];
    [boxPath setLineWidth:self.itemLineWidth];
    [boxPath stroke];
    
    // tracking dot for coordinate settings
    [self redDot];
    
    // TODO: split up the compute and draw
    for (GKS3DObject *obj in self.scene.objectList) {
//        [obj computeAction];
        
        // all transforms completed, draw computed coords
        // maybe draw native here?
        [obj drawActor];
        
    }
    
}

@end
