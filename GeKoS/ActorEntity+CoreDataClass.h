//
//  ActorEntity+CoreDataClass.h
//  
//
//  Created by Alex Popadich on 5/2/22.
//
//  This file was automatically generated and should not be edited.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#include "gks/gks.h"

@class SceneEntity;

NS_ASSUME_NONNULL_BEGIN

@interface ActorEntity : NSManagedObject

@property (strong) id actorObject;

- (GKSvector3d)positionVector;
- (GKSvector3d)rotationVector;
- (GKSvector3d)scaleVector;

@end

NS_ASSUME_NONNULL_END

#import "ActorEntity+CoreDataProperties.h"
