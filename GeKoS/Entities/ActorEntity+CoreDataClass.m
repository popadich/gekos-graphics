//
//  ActorEntity+CoreDataClass.m
//  GeKoS
//
//  Created by Alex Popadich on 5/16/22.
//
//

#import "ActorEntity+CoreDataClass.h"

@implementation ActorEntity

- (NSString *)summary {
    [self willAccessValueForKey:@"summary"];

    NSString *summary = [NSString stringWithFormat:@"%6.2lf  : %6.2lf  : %6.2lf", self.locX, self.locY, self.locZ];
    
    [self didAccessValueForKey:@"summary"];
    
    return summary;
}

- (void) setLocX:(double)locX
{
    [self willChangeValueForKey:@"locX"];
    [self willChangeValueForKey:@"summary"];
    
    [self setPrimitiveValue:@(locX) forKey:@"locX"];
    
    [self didChangeValueForKey:@"locX"];
    [self didChangeValueForKey:@"summary"];
}

- (void) setLocY:(double)locY
{
    [self willChangeValueForKey:@"locY"];
    [self willChangeValueForKey:@"summary"];
    
    [self setPrimitiveValue:@(locY) forKey:@"locY"];

    [self didChangeValueForKey:@"locY"];
    [self didChangeValueForKey:@"summary"];
}

- (void) setLocZ:(double)locZ
{
    [self willChangeValueForKey:@"locZ"];
    [self willChangeValueForKey:@"summary"];
    
    [self setPrimitiveValue:@(locZ) forKey:@"locZ"];

    [self didChangeValueForKey:@"locZ"];
    [self didChangeValueForKey:@"summary"];
}

@end
