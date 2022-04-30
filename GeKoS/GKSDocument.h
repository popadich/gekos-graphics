//
//  Document.h
//  GeKoS
//
//  Created by Alex Popadich on 11/30/21.
//

#import <Cocoa/Cocoa.h>

@class GKSContent;

@interface GKSDocument : NSPersistentDocument
@property (nonatomic, strong) NSColor* lineColor;
@property (nonatomic, strong) NSColor* fillColor;
@property (nonatomic, strong) NSColor* backColor;

@property (strong) GKSContent* content;
@property (strong) id storyBoard;

@end
