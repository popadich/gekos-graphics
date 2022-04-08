//
//  Document.m
//  GeKoS
//
//  Created by Alex Popadich on 11/30/21.
//

#import "GKSDocument.h"
#import "GKSContent.h"
#import "GKSConstants.h"
#import "GKSWindowController.h"
#import "GKSContentViewController.h"


@interface GKSDocument ()

@end

@implementation GKSDocument

- (instancetype)init {
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        _content = [[GKSContent alloc] init];
    }
    return self;
}

+ (BOOL)autosavesInPlace {
    return YES;
}

- (void)makeWindowControllers {
    GKSWindowController *windowController = [[GKSWindowController alloc] initWithWindowNibName:@"GKSDocument"];
    [self addWindowController:windowController];
    
    // No need to specify nib file if it has the same name as the class
    GKSContentViewController *contentController = [[GKSContentViewController alloc] init];
    contentController.representedObject = self.content;
    windowController.contentViewController = contentController;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError *__autoreleasing  _Nullable *)outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error if you return NO.
    // Alternatively, you could remove this method and override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you do, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    
    
    [NSException raise:@"UnimplementedMethod" format:@"%@ is unimplemented", NSStringFromSelector(_cmd)];
    
    
    return NO;

}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError *__autoreleasing  _Nullable *)error
{
    BOOL hasRead = NO;
    GKSmesh_3 *model = nil;
    
    if ([typeName isEqual:@"com.xephyr.off"]) {
        NSLog(@"OFF file to read %@", absoluteURL);
        model = [self.content readModelFromURL:absoluteURL];
        hasRead = YES;
    }
    else if ([typeName isEqual:@"com.xephyr.json"]) {
//        model = [self.content readModelFromJsonData:data];
    }
    
    return hasRead;

}

@end
