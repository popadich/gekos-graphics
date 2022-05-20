//
//  ActorEntity+CoreDataProperties.h
//  GeKoS
//
//  Created by Alex Popadich on 5/16/22.
//
//

#import "ActorEntity+CoreDataClass.h"
#import "GKS3DActor.h"


NS_ASSUME_NONNULL_BEGIN

@interface ActorEntity (CoreDataProperties)

+ (NSFetchRequest<ActorEntity *> *)fetchRequest NS_SWIFT_NAME(fetchRequest());

@property (nullable, nonatomic, copy) NSUUID *actorID;
@property (nonatomic) double centerX;
@property (nonatomic) double centerY;
@property (nonatomic) double centerZ;
@property (nonatomic) BOOL hidden;
@property (nonatomic) int32_t kind;
@property (nullable, nonatomic, retain) NSColor *lineColor;
@property (nonatomic) double locX;
@property (nonatomic) double locY;
@property (nonatomic) double locZ;
@property (nullable, nonatomic, copy) NSString *material;
@property (nullable, nonatomic, copy) NSString *name;
@property (nonatomic) double priority;
@property (nonatomic) double radius;
@property (nonatomic) double rotX;
@property (nonatomic) double rotY;
@property (nonatomic) double rotZ;
@property (nonatomic) double scaleX;
@property (nonatomic) double scaleY;
@property (nonatomic) double scaleZ;
@property (nullable, nonatomic, readonly) NSString *summary;
@property (nullable, nonatomic, readonly) GKS3DActor *transientActor;
@property (nullable, nonatomic, retain) SceneEntity *toScene;

@end

NS_ASSUME_NONNULL_END
