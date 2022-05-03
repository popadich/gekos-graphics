//
//  ActorEntity+CoreDataProperties.h
//  
//
//  Created by Alex Popadich on 5/2/22.
//
//  This file was automatically generated and should not be edited.
//

#import "ActorEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ActorEntity (CoreDataProperties)

+ (NSFetchRequest<ActorEntity *> *)fetchRequest NS_SWIFT_NAME(fetchRequest());

@property (nonatomic) BOOL hidden;
@property (nonatomic) int32_t kind;
@property (nonatomic) double locX;
@property (nonatomic) double locY;
@property (nonatomic) double locZ;
@property (nullable, nonatomic, copy) NSString *name;
@property (nonatomic) double priority;
@property (nonatomic) double rotX;
@property (nonatomic) double rotY;
@property (nonatomic) double rotZ;
@property (nonatomic) double scaleX;
@property (nonatomic) double scaleY;
@property (nonatomic) double scaleZ;
@property (nullable, nonatomic, retain) SceneEntity *toScene;

@end

NS_ASSUME_NONNULL_END
