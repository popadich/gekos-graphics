//
//  Document.m
//  GeKoS
//
//  Created by Alex Popadich on 11/30/21.
//

#import "GKSDocument.h"

@interface GKSDocument ()

@end

@implementation GKSDocument

- (instancetype)init {
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}

+ (BOOL)autosavesInPlace {
    return YES;
}


- (NSString *)windowNibName {
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Document";
}


@end
