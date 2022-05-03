//
//  ActorEntity+CoreDataClass.m
//  
//
//  Created by Alex Popadich on 5/2/22.
//
//  This file was automatically generated and should not be edited.
//

#import "ActorEntity+CoreDataClass.h"


@implementation ActorEntity

@synthesize actorObject;

- (GKSvector3d)positionVector
{
    GKSvector3d pos;
    pos = GKSMakeVector(self.locX , self.locY, self.locZ);
    return pos;
}

- (GKSvector3d)rotationVector
{
    GKSvector3d rot;
    GKSfloat degreesAroundX = self.rotX;
    GKSfloat degreesAroundY = self.rotY;
    GKSfloat degreesAroundZ = self.rotZ;
    
    rot = GKSMakeVector(degreesAroundX * DEG_TO_RAD, degreesAroundY * DEG_TO_RAD, degreesAroundZ * DEG_TO_RAD);
    return rot;
}

- (GKSvector3d)scaleVector
{
    GKSvector3d rot;
    rot = GKSMakeVector(self.scaleX, self.scaleY, self.scaleZ);
    return rot;
}

@end
