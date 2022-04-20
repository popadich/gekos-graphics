//
//  GKSMeshRep.h
//  GeKoS
//
//  Created by Alex Popadich on 4/19/22.
//

#import <Foundation/Foundation.h>
#include "gks/gks_types.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKSMeshRep : NSObject

@property (strong)NSNumber *meshId;
@property (assign)GKSmesh_3 *meshPtr;

@end

NS_ASSUME_NONNULL_END
