//
//  MeshEntity+CoreDataProperties.h
//  GeKoS
//
//  Created by Alex Popadich on 5/15/22.
//
//

#import "MeshEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MeshEntity (CoreDataProperties)

+ (NSFetchRequest<MeshEntity *> *)fetchRequest NS_SWIFT_NAME(fetchRequest());

@property (nonatomic) int32_t edgeCount;
@property (nonatomic) int32_t meshID;
@property (nullable, nonatomic, copy) NSString *meshName;
@property (nullable, nonatomic, copy) NSString *offString;
@property (nonatomic) int32_t polygonCount;
@property (nullable, nonatomic, readonly) NSString *summary;
@property (nonatomic) int32_t vertexCount;
@property (nullable, nonatomic, retain) StoryBoardEntity *toStoryBoard;

@end

NS_ASSUME_NONNULL_END
