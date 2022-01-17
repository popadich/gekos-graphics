//
//  GKSPreferences.h
//  GeKoS
//
//  Created by Alex Popadich on 1/16/22.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKSPreferences : NSWindowController

@property (nonatomic, retain) NSString *etherealStringPropery;
@property (nonatomic, assign) BOOL enableEtherealOptions;

+ (id)sharedPreferences;

@end

NS_ASSUME_NONNULL_END
