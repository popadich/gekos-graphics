//
//  AppDelegate.m
//  GeKoS
//
//  Created by Alex Popadich on 11/30/21.
//

#import "GKSAppDelegate.h"
#import "GKSConstants.h"
#import "GKSPreferences.h"
#include "gks/gks.h"

@interface GKSAppDelegate ()

@end

@implementation GKSAppDelegate

static NSDictionary *defaultValues() {
    double world_volume[6] = {-1.0, 1.0, -1.0, 1.0, -1.0, 1.0};
    
    static NSDictionary *dict = nil;
    if (!dict) {
        // some data types require more work to store to defaults.
        NSColor* bluePrintBlue = [NSColor colorWithRed:0.066 green:0.510 blue:0.910 alpha:1.0];
        NSColor* greypenColor = [NSColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
        NSColor* manillafillColor = [NSColor colorWithRed:1.0 green:1.0 blue:0.8 alpha:1.0];
        
        NSData* worldVolumeData = [NSData dataWithBytes:world_volume length:6*sizeof(double)];
        
        NSError* error = nil;
        
        dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                [NSNumber numberWithInteger:400], GKSViewWidth,
                [NSNumber numberWithInteger:400], GKSViewHeight,
                [NSNumber numberWithBool:YES], GKSPerspectiveProjectionFlag,
                [NSNumber numberWithDouble:1.0], GKSPerspectiveDistance,
                [NSNumber numberWithBool:NO], GKSHiddenLineRemoval,
                [NSKeyedArchiver archivedDataWithRootObject:bluePrintBlue requiringSecureCoding:YES error:&error], GKSBackgroundColor,
                [NSKeyedArchiver archivedDataWithRootObject:manillafillColor requiringSecureCoding:NO error:&error], GKSFillColor,
                [NSKeyedArchiver archivedDataWithRootObject:greypenColor requiringSecureCoding:NO error:&error], GKSPenColor,
                [NSNumber numberWithBool:NO], XSUseLookAtPoint,
                worldVolumeData, GKSWorldVolumeData,
                [NSNumber numberWithDouble:world_volume[0]], GKSWorldVolumeMinX,
                [NSNumber numberWithDouble:world_volume[1]], GKSWorldVolumeMaxX,
                [NSNumber numberWithDouble:world_volume[2]], GKSWorldVolumeMinY,
                [NSNumber numberWithDouble:world_volume[3]], GKSWorldVolumeMaxY,
                [NSNumber numberWithDouble:world_volume[4]], GKSWorldVolumeMinZ,
                [NSNumber numberWithDouble:world_volume[5]], GKSWorldVolumeMaxZ,
                nil];
    }
    return dict;
}

+ (void)initialize
{
    if (self == [GKSAppDelegate class]) {
        // Set up default values for preferences managed by NSUserDefaultsController
        // Nothing gets written to the Preferences "file" until its value changes from
        // the original defaults value.
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues()];
        [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaultValues()];
        
    }
}


- (IBAction)showPreferencesWindow:(id)sender
{
    GKSPreferences *preferences = [GKSPreferences sharedPreferences];
    
    [preferences showWindow:sender];
    
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    // init gks
    // this needs to be done early in the application lifecycle
    gks_init();

}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
