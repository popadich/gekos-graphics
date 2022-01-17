//
//  GKSPreferences.m
//  GeKoS
//
//  Created by Alex Popadich on 1/16/22.
//

#import "GKSPreferences.h"

@interface GKSPreferences ()

@end

@implementation GKSPreferences


+ (id)sharedPreferences {
    static GKSPreferences *sharedPreferences = nil;
    
    static dispatch_once_t onceToken; // onceToken = 0
    _dispatch_once(&onceToken, ^{
        sharedPreferences = [[GKSPreferences alloc] initWithWindowNibName:@"GKSPreferences"];
    });
    
    return sharedPreferences;
}

- (instancetype)initWithWindowNibName:(NSNibName)windowNibName
{
    self = [super initWithWindowNibName:windowNibName];
    if (self != nil) {
        _etherealStringPropery = @"Some ethereal string";
        _enableEtherealOptions = NO;
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
