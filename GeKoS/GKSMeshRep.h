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
@property (strong)NSString *meshName;
@property (strong)NSString *offString;
@property (assign)GKSmesh_3 *meshPtr;

- (instancetype)initWithID:(NSNumber *)meshID andMeshPtr:(GKSmesh_3 *)meshPtr andOffString:(NSString *)offString;

@end

NS_ASSUME_NONNULL_END
