//
//  GKSWindowController.m
//  GeKoS
//
//  Created by Alex Popadich on 2/23/22.
//

#import "GKSWindowController.h"
#import "GKSContentViewController.h"
#import "GKSContent.h"

@interface GKSWindowController ()

@end

@implementation GKSWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


- (IBAction)exportModel:(id)sender
{
    NSString *docName = [(NSDocument *)self.document displayName];;
    [self exportDocument:docName toType:@"rrolj"];
}



// this code should be in the window controller or content controller maybe
- (void)exportDocument:(NSString*)name toType:(NSString*)typeUTI
{

    GKSContentViewController *contentViewController = (GKSContentViewController *)self.contentViewController;
    GKSContent *content = (GKSContent *)contentViewController.representedObject;
    NSWindow* window = [self window];
 
    // Build a new name for the file using the current name and
    // the filename extension associated with the specified UTI.
    // CFStringRef newExtension = UTTypeCopyPreferredTagWithClass((CFStringRef)typeUTI, kUTTagClassFilenameExtension);

    NSString* newExtension = typeUTI;
    NSString* newName = [[name stringByDeletingPathExtension] stringByAppendingPathExtension:newExtension];
 
    // Set the default name for the file and show the panel.
    NSSavePanel* panel = [NSSavePanel savePanel];
    [panel setNameFieldStringValue:newName];
    [panel beginSheetModalForWindow:window completionHandler:^(NSInteger result){
        if (result == NSModalResponseOK)
        {
            NSURL*  theFile = [panel URL];
            
            if ([typeUTI isEqualToString:@"rrolj"]) {
                NSData *contentData = content.textRepresentation;
                
                if (contentData != nil) {
//                      NSData * dataOfText = [contentString dataUsingEncoding:kUnicodeUTF8Format];
                    [contentData writeToURL:theFile atomically:YES];
                }
            }

        }
    }];
}

@end
