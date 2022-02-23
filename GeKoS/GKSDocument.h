//
//  Document.h
//  GeKoS
//
//  Created by Alex Popadich on 11/30/21.
//

#import <Cocoa/Cocoa.h>

@interface GKSDocument : NSPersistentDocument
@property (nonatomic, strong) NSColor* lineColor;
@property (nonatomic, strong) NSColor* fillColor;
@property (nonatomic, strong) NSColor* backColor;

@end
