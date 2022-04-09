//
//  GKSMeshParser.h
//  GeKoS
//
//  Created by Alex Popadich on 4/8/22.
//

#import <Foundation/Foundation.h>
#include "gks/gks_types.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKSMeshParser : NSObject

+ (id)sharedMeshParser;

- (GKSmesh_3 *)parseOFFMeshFile:(NSURL*)URL error:(NSError **)error;
- (GKSmesh_3 *)parseOFFMeshString:(NSString*)meshString error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
