//
//  NSSecureColorTransformer.m
//  RayRobin
//
//  Created by Alex Popadich on 5/23/22.
//  Copyright © 2022 Xephyr Systems. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "NSSecureColorTransformer.h"

@implementation NSSecureColorTransformer


+ (Class)transformedValueClass {
    return [NSColor class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

//+ (NSArray<Class> *)allowedTopLevelClasses {
//    return @[[NSColor class]];
//}

- (id)transformedValue:(id)value {
    
    NSColor *theColor = nil;
    NSError *error;
    NSData *colorData = value;
    if (colorData != nil) {
        theColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:colorData error:&error];
    }

    return (value == nil) ? nil : theColor;
}

- (id)reverseTransformedValue:(id)value
{
    if (value == nil) return nil;
    
    NSData *colorData = nil;
    NSError *error;
    if(![value isKindOfClass:[NSColor class]]) {
        [NSException raise:NSInternalInconsistencyException format:@"Value (%@) is not an NSColor instance", [value class]];
    }
        
    colorData = [NSKeyedArchiver archivedDataWithRootObject:value requiringSecureCoding:YES error:&error];
    
    
    return colorData;
}



@end
