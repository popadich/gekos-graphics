//
//  GKSHeadView.m
//  GeKoS
//
//  Created by Alex Popadich on 3/3/22.
//

#import "GKSHeadView.h"
#include "gks/gks.h"



@implementation GKSHeadView
//
// The coordinate system for the rotation matrix is:
//
//             z
//             |
//             |
//             /----- y
//            /
//           x
//
//


- (void)drawHead3DAtPoint:(NSPoint)center yaw:(double)yaw pitch:(double)pitch roll:(double)roll focalLenth:(double)fl
{
    static Gpt_3 cube[24] =     {
        { -0.500000, -0.500000, -0.500000 },
        { 0.500000, -0.500000, -0.500000 },
        { 0.500000, 0.500000, -0.500000 },
        { -0.500000, 0.500000, -0.500000 },
        { -0.500000, -0.500000, 0.500000 },
        { 0.500000, -0.500000, 0.500000 },
        { 0.500000, 0.500000, 0.500000 },
        { -0.500000, 0.500000, 0.500000 },
        { -0.500000, -0.500000, -0.500000 },
        { -0.500000, 0.500000, -0.500000 },
        { -0.500000, 0.500000, 0.500000 },
        { -0.500000, -0.500000, 0.500000 },
        { 0.500000, -0.500000, -0.500000 },
        { 0.500000, 0.500000, -0.500000 },
        { 0.500000, 0.500000, 0.500000 },
        { 0.500000, -0.500000, 0.500000 },
        { -0.500000, -0.500000, -0.500000 },
        { -0.500000, -0.500000, 0.500000 },
        { 0.500000, -0.500000, 0.500000 },
        { 0.500000, -0.500000, -0.500000 },
        { 0.500000, 0.500000, -0.500000 },
        { -0.500000, 0.500000, -0.500000 },
        { -0.500000, 0.500000, 0.500000 },
        { 0.500000, 0.500000, 0.500000 }
    };
    
    double      Xeye,Yeye,Zeye;
    CGFloat     screen_x = 0.0;
    CGFloat     screen_y = 0.0;
    NSColor     *foreColor;
    
    // TODO: clean up mess
    double      alpha = roll;
    double      beta = yaw;
    double      gamma = pitch;

    NSBezierPath *cubePath = [[NSBezierPath alloc] init];
    BOOL isFirstTime = YES;
    
    double sg = sin(gamma);
    double sb = sin(beta);
    double sa = sin(alpha);
    double cg = cos(gamma);
    double cb = cos(beta);
    double ca = cos(alpha);

    double r = 1/fl;
    
    NSPoint endPoint = NSMakePoint(0.0, 0.0);
    for (int i=0; i<24; i++) {
        double x = cube[i].x;
        double y = cube[i].y;
        double z = cube[i].z;
        
        // rotation matrix [Rz][Ry][Rz] from wikipedia
        // https://en.wikipedia.org/wiki/Rotation_matrix

        Xeye =  x*ca*cb    + y*(ca*sb*sg-sa*cg)   + z*(ca*sb*cg+sa*sg);
        Yeye =  x*sa*cb    + y*(sa*sb*sg+ca*cg)   + z*(sa*sb*cg-ca*sg);
        Zeye = -x*sb    + y*cb*sg   + z*cb*cg;
        
        // center on screen and apply perspective transformation
        screen_x = center.x + SCALE * (Xeye / (r*Zeye + 1.0));
        screen_y = center.y + SCALE * (Yeye / (r*Zeye + 1.0));
        
        NSPoint screenPoint = NSMakePoint(screen_x, screen_y);

        if (i > 4 && i < 9 ) {
            [cubePath setLineWidth:3.0];
            foreColor = [NSColor redColor];
            [foreColor set];
        }
        else {
            [cubePath setLineWidth:1.0];
            foreColor = [NSColor colorWithRed:25535.0/65535.0 green:0.0 blue:0.0 alpha:1.0];
            [foreColor set];
         }

        if( i%4==0 ) {
            if (isFirstTime) {
                [cubePath moveToPoint:screenPoint];
                isFirstTime = NO;
                endPoint = screenPoint;
            }
            else {
                // stroke current path
                [cubePath lineToPoint:endPoint];
                [cubePath stroke];
                // new path
                cubePath = [[NSBezierPath alloc] init];
                [cubePath moveToPoint:screenPoint];
                endPoint = screenPoint;
            }
        }
        else {
            [cubePath lineToPoint:screenPoint];
        }
        
    }
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    [NSColor.blueColor set];
    [NSBezierPath fillRect:dirtyRect];
    
    // draw head
    NSPoint centerPoint = NSMakePoint(NSMidX(dirtyRect), NSMidY(dirtyRect));
    double turnYaw = [self.headYaw doubleValue] * DEG_TO_RAD;
    double turnPitch = [self.headPitch doubleValue] * DEG_TO_RAD;
    double turnRoll = [self.headRoll doubleValue] * DEG_TO_RAD;
    double fl = [self.headFocalLength doubleValue];
    [self drawHead3DAtPoint:centerPoint yaw:turnYaw pitch:turnPitch roll:turnRoll focalLenth:(double)fl ];

}

@end
