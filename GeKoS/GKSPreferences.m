//
//  GKSPreferences.m
//  GeKoS
//
//  Created by Alex Popadich on 1/16/22.
//

#import "GKSPreferences.h"
#import "GKSConstants.h"

@interface GKSPreferences ()

@property (nonatomic, strong) NSColor* backgroundDefaultColor;
@property (nonatomic, strong) NSColor* fillDefaultColor;
@property (nonatomic, strong) NSColor* lineDefaultColor;

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
        
        _backgroundDefaultColor = [NSColor whiteColor];
        _fillDefaultColor = [NSColor lightGrayColor];
        _lineDefaultColor = [NSColor blackColor];
        
        NSError* error;
        NSData* theData = [[NSUserDefaults standardUserDefaults] dataForKey:gksPrefBackgroundColor];
        if (theData != nil)
            _backgroundDefaultColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:theData error:&error];
        theData = [[NSUserDefaults standardUserDefaults] dataForKey:gksPrefPenColor];
        if (theData != nil)
            _lineDefaultColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:theData error:&error];
        theData = [[NSUserDefaults standardUserDefaults] dataForKey:gksPrefFillColor];
        if (theData != nil)
            _fillDefaultColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:theData error:&error];

    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}



- (void)setBackgroundDefaultColor:(NSColor *)backgroundDefaultColor {
    NSError* error = nil;

    _backgroundDefaultColor = backgroundDefaultColor;
    
    NSData* keyedData = [NSKeyedArchiver archivedDataWithRootObject:backgroundDefaultColor requiringSecureCoding:YES error:&error];
    
    if (error.code == noErr) {
        [[NSUserDefaults standardUserDefaults] setValue:keyedData forKey:gksPrefBackgroundColor];
    }
    
}

- (void)setFillDefaultColor:(NSColor *)fillDefaultColor {
    NSError* error = nil;
    
    _fillDefaultColor = fillDefaultColor;
    
    NSData* keyedData  = [NSKeyedArchiver archivedDataWithRootObject:fillDefaultColor requiringSecureCoding:NO error:&error];
    
    if (error.code == noErr) {
        [[NSUserDefaults standardUserDefaults] setValue:keyedData forKey:gksPrefFillColor];
    }
}

- (void)setLineDefaultColor:(NSColor *)lineDefaultColor {
    NSError* error = nil;
    
    _lineDefaultColor = lineDefaultColor;
    
    NSData* keyedData = [NSKeyedArchiver archivedDataWithRootObject:lineDefaultColor requiringSecureCoding:YES error:&error];
    if (error.code == noErr) {
        [[NSUserDefaults standardUserDefaults] setValue:keyedData forKey:gksPrefPenColor];
    }
}


@end
