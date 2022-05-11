//
//  GKSMeshMonger.h
//  GeKoS
//
//  Created by Alex Popadich on 4/20/22.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "GKSMeshRep.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKSMeshMonger : NSObject

@property (strong) NSManagedObjectContext *managedObjectContext;

+ (id)sharedMeshMonger;

- (void)addToMoc:(NSManagedObjectContext *)moc meshEntityFromRep:(GKSMeshRep *)meshRep;
- (GKSMeshRep *)getMeshRep:(NSNumber *)meshID;
- (NSNumber *)nextID;

- (NSString *)convertMeshToOffString:(GKSmesh_3 *)meshPtr;
@end

NS_ASSUME_NONNULL_END
