//
//  MeshEntity+CoreDataProperties.m
//  GeKoS
//
//  Created by Alex Popadich on 5/15/22.
//
//

#import "MeshEntity+CoreDataProperties.h"

@implementation MeshEntity (CoreDataProperties)

+ (NSFetchRequest<MeshEntity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"MeshEntity"];
}

@dynamic edgeCount;
@dynamic meshID;
@dynamic meshName;
@dynamic offString;
@dynamic polygonCount;
@dynamic summary;
@dynamic vertexCount;
@dynamic toStoryBoard;

@end
