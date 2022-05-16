//
//  ActorEntity+CoreDataProperties.m
//  GeKoS
//
//  Created by Alex Popadich on 5/16/22.
//
//

#import "ActorEntity+CoreDataProperties.h"

@implementation ActorEntity (CoreDataProperties)

+ (NSFetchRequest<ActorEntity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"ActorEntity"];
}

@dynamic actorID;
@dynamic centerX;
@dynamic centerY;
@dynamic centerZ;
@dynamic hidden;
@dynamic kind;
@dynamic lineColor;
@dynamic locX;
@dynamic locY;
@dynamic locZ;
@dynamic material;
@dynamic name;
@dynamic priority;
@dynamic radius;
@dynamic rotX;
@dynamic rotY;
@dynamic rotZ;
@dynamic scaleX;
@dynamic scaleY;
@dynamic scaleZ;
@dynamic summary;
@dynamic transientActor;
@dynamic toScene;

@end
