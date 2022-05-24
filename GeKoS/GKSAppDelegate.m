//
//  AppDelegate.m
//  GeKoS
//
//  Created by Alex Popadich on 11/30/21.
//

#import "GKSAppDelegate.h"
#import "GKSConstants.h"
#import "NSSecureColorTransformer.h"
#import "GKSPreferences.h"
#import "GKSSceneInspector.h"
#import "GKSContent.h"

#include "gks.h"

@interface GKSAppDelegate ()

@end


@implementation GKSAppDelegate

static NSDictionary *defaultValues() {
    double world_volume[6] = {-1.0, 1.0, -1.0, 1.0, -1.0, 1.0};
    double locX = 0.0;
    double locY = 0.0;
    double locZ = 2.7;

    
    static NSDictionary *dict = nil;
    if (!dict) {
        // some data types require more work to store to defaults.
        NSColor* blueprintColor = [NSColor colorWithRed:0.066 green:0.510 blue:0.910 alpha:1.0];
        NSColor* greypenColor = [NSColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
        NSColor* manillafillColor = [NSColor colorWithRed:1.0 green:1.0 blue:0.8 alpha:1.0];
        
        NSData* worldVolumeData = [NSData dataWithBytes:world_volume length:6*sizeof(double)];
        
        NSError* error = nil;
        
        dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                [NSNumber numberWithInteger:400], gksPrefViewWidth,
                [NSNumber numberWithInteger:400], gksPrefViewHeight,
                [NSNumber numberWithDouble:1.0], gksPrefPerspectiveDistance,
                [NSNumber numberWithInteger:kAlternate], gksPrefProjectionType,
                [NSNumber numberWithDouble:0.1], gksPrefNearPlaneDistance,
                [NSNumber numberWithDouble:100.0], gksPrefFarPlaneDistance,
                [NSNumber numberWithDouble:locX], gksPrefCameraLocX,
                [NSNumber numberWithDouble:locY], gksPrefCameraLocY,
                [NSNumber numberWithDouble:locZ], gksPrefCameraLocZ,
                [NSNumber numberWithBool:NO], gksPrefVisibleSurfaceFlag,
                [NSKeyedArchiver archivedDataWithRootObject:blueprintColor requiringSecureCoding:YES error:&error], gksPrefBackgroundColor,
                [NSKeyedArchiver archivedDataWithRootObject:manillafillColor requiringSecureCoding:YES error:&error], gksPrefFillColor,
                [NSKeyedArchiver archivedDataWithRootObject:greypenColor requiringSecureCoding:YES error:&error], gksPrefPenColor,
                worldVolumeData, gksPrefWorldVolumeData,
                [NSNumber numberWithDouble:world_volume[0]], gksPrefWorldVolumeMinX,
                [NSNumber numberWithDouble:world_volume[1]], gksPrefWorldVolumeMaxX,
                [NSNumber numberWithDouble:world_volume[2]], gksPrefWorldVolumeMinY,
                [NSNumber numberWithDouble:world_volume[3]], gksPrefWorldVolumeMaxY,
                [NSNumber numberWithDouble:world_volume[4]], gksPrefWorldVolumeMinZ,
                [NSNumber numberWithDouble:world_volume[5]], gksPrefWorldVolumeMaxZ,
                [NSNumber numberWithBool:YES], gksPrefFrustumCullFlag,
                [NSNumber numberWithBool:YES], gksPlayingFlag,
                nil];
    }
    return dict;
}

+ (void)initialize
{
    if (self == [GKSAppDelegate class]) {
        // Set up default values for preferences managed by NSUserDefaultsController
        
        // Register NSColor transformer
        if (@available(macOS 10.14, *)) {
            NSSecureColorTransformer *scf = [[NSSecureColorTransformer alloc] init];
            [NSValueTransformer setValueTransformer:scf forName:@"NSSecureColorTransformer"];
            
        } else {
            // Fallback on earlier versions
        }

        
        
        
        // Nothing gets written to the Preferences "file" until its value changes from
        // the original defaults value.
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues()];
        [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaultValues()];
        
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return NO;
}


- (IBAction)showPreferencesWindow:(id)sender
{
    GKSPreferences *preferences = [GKSPreferences sharedPreferences];
    
    [preferences showWindow:sender];
    
}


- (IBAction)showSceneInspectorWindow:(id)sender
{
    GKSSceneInspector *inspector = [GKSSceneInspector sharedInspector];
 
    [inspector showWindow:sender];

}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    


}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
