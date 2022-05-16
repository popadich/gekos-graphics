//
//  GKSContent.h
//  GeKoS
//
//  Created by Alex Popadich on 3/15/22.
//

#import <Foundation/Foundation.h>
#import "GKSSceneController.h"
#import "GKSSceneRep.h"
#import "GKSMeshMonger.h"
#import "GeKoS+CoreDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKSContent : NSObject
- (instancetype)initWithManagedObjectContext: (NSManagedObjectContext *)moc;

@property (strong) GKSSceneRep *theScene;
@property (strong) GKSCameraRep *theCamera;
@property (weak) NSManagedObjectContext *managedObjectContext;
@property (assign) GKScontext3DPtr context3D;
@property (strong) GKSMeshMonger *theMonger;

- (NSData *)textRepresentation;

@end

NS_ASSUME_NONNULL_END
