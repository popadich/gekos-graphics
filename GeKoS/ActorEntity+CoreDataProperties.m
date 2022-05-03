//
//  ActorEntity+CoreDataProperties.m
//  
//
//  Created by Alex Popadich on 5/2/22.
//
//  This file was automatically generated and should not be edited.
//

#import "ActorEntity+CoreDataProperties.h"

@implementation ActorEntity (CoreDataProperties)

+ (NSFetchRequest<ActorEntity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"ActorEntity"];
}

@dynamic hidden;
@dynamic kind;
@dynamic locX;
@dynamic locY;
@dynamic locZ;
@dynamic name;
@dynamic priority;
@dynamic rotX;
@dynamic rotY;
@dynamic rotZ;
@dynamic scaleX;
@dynamic scaleY;
@dynamic scaleZ;
@dynamic toScene;

@end
