//
//  MeshEntity+CoreDataClass.m
//  GeKoS
//
//  Created by Alex Popadich on 5/15/22.
//
//

#import "MeshEntity+CoreDataClass.h"

@implementation MeshEntity

- (NSString *)summary {
    [self willAccessValueForKey:@"summary"];

    NSString *summary = [NSString stringWithFormat:@"%d  : %d  : %d", self.vertexCount, self.polygonCount, self.edgeCount];
    
    [self didAccessValueForKey:@"summary"];
    
    return summary;
}

@end
