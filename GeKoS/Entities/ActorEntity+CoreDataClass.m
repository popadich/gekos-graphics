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

@end
