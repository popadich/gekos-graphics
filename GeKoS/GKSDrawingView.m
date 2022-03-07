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
}
@property (nonatomic, assign) CGFloat itemLineWidth;

@end


@implementation GKSDrawingView

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
    theData = [[NSUserDefaults standardUserDefaults] dataForKey:gksPrefFillColor];
    if (theData != nil) {
        aColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:theData error:&error];
        if (error.code == noErr) {
            self.fillColor = aColor;
        }
        
    }
    theData = [[NSUserDefaults standardUserDefaults] dataForKey:gksPrefPenColor];
    if (theData != nil) {
        aColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:theData error:&error];
        if (error.code == noErr) {
            self.lineColor = aColor;
        }
    }
    
    bluePrintBlueColor = [NSColor colorWithRed:0.066 green:0.510 blue:0.910 alpha:1.0];
    maizeColor = [NSColor colorWithRed:1.0 green:203.0/255.0 blue:5.0/255.0 alpha:1.0];
    _showSurface = NO;
    _itemLineWidth = 1.0;
}


struct mystery_data {
    int op_num;
    bool hiddenLineRemovalFlag;
    char name[32];
    void* ns_bezier_path;
};

static void my_polyline_cb(GKSint polygonID, GKSint num_pt, GKSvertexArrPtr trans_array, GKSDCArrPtr dc_array, GKSnormalArrPtr norms, GKScolor *lineColor, bool hiddenSurfaceRemoveFlag, void* userdata)
{
    int             vertexID;
    GKSpoint_2      dc;             // device coordinate
    GKSint          r0, s0;

    NSBezierPath* polyPath = [NSBezierPath bezierPath];
    
    // set pen color to object color
    NSColor* aColor = [NSColor colorWithRed:lineColor->red green:lineColor->green blue:lineColor->blue alpha:lineColor->alpha];
    [aColor setStroke];

    // restore point 0
//    vrc = trans_array[0];
    
    // restore device coordinate
    dc = dc_array[0];
    r0 = dc.x;
    s0 = dc.y;
    
    // MoveTo call on Cocoa object
    [polyPath moveToPoint:NSMakePoint(r0, s0)];
    
    for (vertexID=1; vertexID<num_pt; vertexID++) {

        // restore transformed point
//        vrc = trans_array[vertexID];
        
        // restore device coordinate
        dc = dc_array[vertexID];
        
        // LineTo call on Cocoa object
        [polyPath lineToPoint:NSMakePoint(dc.x, dc.y)];
    }
    // LineTo call on Cocoa object
    [polyPath lineToPoint:NSMakePoint(r0, s0)];
    
    // this might be smarter at mesh instantiation
    // and then just transform normal vectors with the rest of
    // the vertices.
    // restore the normal for polygon
    GKSpoint_3 normal_vector = norms[polygonID];
    
    // Primitive surface removal in order to test normal vectors
    //hiddenSurfaceRemoveFlag = mr_data->hiddenLineRemovalFlag;
    if (hiddenSurfaceRemoveFlag) {
        if (normal_vector.z > 0) {
            // Stroke and Fill call on Cocoa object
            // colors get set in GKSDrawingView:  - (void)drawRect
            [polyPath fill];
            [polyPath stroke];
        }
    }
    else {
        [polyPath stroke];
    }
}



- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Callback registration. Look into putting this in the awake method.
    struct mystery_data polylinedata = {3, NO, "polyliner", NULL};
    polylinedata.hiddenLineRemovalFlag = self.showSurface;
    localpolyline_cb_register(my_polyline_cb, &polylinedata);
    
    
    // Drawing code here.
    // erase the background by drawing background color
    [maizeColor set];
    [NSBezierPath fillRect:dirtyRect];
    
    NSRect blueprintBox = NSInsetRect(self.bounds, 20.0, 20.0);
    gks_trans_adjust_device_viewport(blueprintBox.origin.x, blueprintBox.size.width, blueprintBox.origin.y, blueprintBox.size.height);
    
    [self.backgroundColor set];
    NSBezierPath *boxPath = [NSBezierPath bezierPathWithRect:blueprintBox];
    [NSBezierPath fillRect:blueprintBox];
    
    [NSColor.whiteColor set];
    [boxPath setLineWidth:self.itemLineWidth];
    [boxPath stroke];
    
    // render objects
    [self.lineColor setStroke];
    [self.fillColor setFill];
    // @TODO: use context or pass data?
    // instead of using a callback function above
    gks_objarr_draw_list();

}

@end
