//
//  GKSContentViewController.h
//  GeKoS
//
//  Created by Alex Popadich on 2/23/22.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKSContentViewController : NSViewController

@property (strong)NSNumber *isCenteredObject;

- (IBAction)performUpdateQuick:(id)sender;

@end

NS_ASSUME_NONNULL_END
