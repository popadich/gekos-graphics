//
//  GKSMeshRep.h
//  GeKoS
//
//  Created by Alex Popadich on 4/19/22.
//

#import <Foundation/Foundation.h>
#include "gks_types.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKSMeshRep : NSObject

@property (strong)NSNumber *meshId;
@property (strong)NSString *meshName;
@property (strong)NSString *offString;
@property (assign)GKSmesh_3 *meshPtr;

- (instancetype)initWithID:(NSNumber *)meshID andName:(NSString *)meshName andOffString:(NSString *)offString;

@end

NS_ASSUME_NONNULL_END
