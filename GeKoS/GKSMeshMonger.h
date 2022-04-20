//
//  GKSMeshMonger.h
//  GeKoS
//
//  Created by Alex Popadich on 4/20/22.
//

#import <Foundation/Foundation.h>
#import "GKSMeshRep.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKSMeshMonger : NSObject

@property (strong)NSMutableDictionary *meshes;

- (void)addMeshRep:(GKSMeshRep *)meshRep;
- (GKSMeshRep *)getMeshRep:(NSNumber *)meshID;

@end

NS_ASSUME_NONNULL_END
