//
//  GKSPreferences.m
//  GeKoS
//
//  Created by Alex Popadich on 1/16/22.
//

#import "GKSPreferences.h"
#import "GKSConstants.h"

@interface GKSPreferences ()

@property (strong) NSNumber* projectionTypeDefault;
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
        
        _projectionTypeDefault = @(kPerspective);
        _backgroundDefaultColor = [NSColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        _fillDefaultColor = [NSColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
        _lineDefaultColor = [NSColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
        
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

- (void)initColorWellDefaults {
    
    NSError* error;
    // background color
    NSData* colorData = [[NSUserDefaults standardUserDefaults] dataForKey:gksPrefBackgroundColor];
    if (colorData != nil) {
        self.backgroundDefaultColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:colorData error:&error];
    }
    // line color
    colorData = [[NSUserDefaults standardUserDefaults] dataForKey:gksPrefPenColor];
    if (colorData != nil) {
        self.lineDefaultColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:colorData error:&error];
    }
    // fill color
    colorData = [[NSUserDefaults standardUserDefaults] dataForKey:gksPrefFillColor];
    if (colorData != nil) {
        self.fillDefaultColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:colorData error:&error];
    }
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self initColorWellDefaults];
}


- (IBAction)resetAllPreferences:(id)sender
{

    // clear the non-default values
    NSDictionary *defaultsDict = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    for (NSString *key in [defaultsDict allKeys])
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];

    // update the preference window to reflect the new defaults
    [self initColorWellDefaults];
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
