//
//  GKSContent.h
//  GeKoS
//
//  Created by Alex Popadich on 3/15/22.
//

#import <Foundation/Foundation.h>
#import "GKSSceneController.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKSContent : NSObject

@property (strong)GKSSceneController *theScene;
@property (assign)GKScontext3DPtr theContext;


@end

NS_ASSUME_NONNULL_END
