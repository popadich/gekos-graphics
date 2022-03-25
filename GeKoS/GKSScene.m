//
//  GKSScene.m
//  gks-cocoa
//
//  Created by Alex Popadich on 7/31/21.
//

#import "GKSScene.h"
#import "GKSConstants.h"

@interface GKSScene () {
    float seg_vect[3];
}



@end


@implementation GKSScene

- (instancetype)initWithCamera:(GKSCameraRep *)aCamera
{
    self = [super init];
    if (self) {
        // initialize scene array
        _objectList = [[NSMutableArray alloc] init];
        
        _worldVolumeMinX  = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMinX];
        _worldVolumeMaxX = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMaxX];
        _worldVolumeMinY = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMinY];
        _worldVolumeMaxY = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMaxY];
        _worldVolumeMinZ = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMinZ];
        _worldVolumeMaxZ = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMaxZ];
        
        NSError* error;
        NSColor* aColor;
        
        NSData* theData = [[NSUserDefaults standardUserDefaults] dataForKey:gksPrefBackgroundColor];
        if (theData != nil){
            aColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:theData error:&error];
            if (error.code == noErr) {
                self.worldBackColor = aColor;
            }
        }
        theData = [[NSUserDefaults standardUserDefaults] dataForKey:gksPrefPenColor];
        if (theData != nil){
            aColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:theData error:&error];
            if (error.code == noErr) {
                self.worldLineColor = aColor;
            }
        };
        theData = [[NSUserDefaults standardUserDefaults] dataForKey:gksPrefFillColor];
        if (theData != nil) {
            aColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:theData error:&error];
            if (error.code == noErr) {
                self.worldFillColor = aColor;
            }
        }
        self.camera = aCamera;
    }
    return self;
}

- (void) addObjectRep:(GKS3DObjectRep*) anObjectRep
{
    NSLog(@"3D Object of kind: %ld \n ScaleX: %lf \n TransX: %lf\n TransY: %lf\n TransZ: %lf", anObjectRep.objectKind.integerValue, anObjectRep.scaleX.floatValue, anObjectRep.transX.floatValue, anObjectRep.transY.floatValue, anObjectRep.transZ.floatValue);
    
    [self.objectList addObject:anObjectRep];
}




@end
