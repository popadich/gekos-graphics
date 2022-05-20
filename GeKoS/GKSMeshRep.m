//
//  GKSMeshRep.m
//  GeKoS
//
//  Created by Alex Popadich on 4/19/22.
//

#import "GKSMeshRep.h"


@implementation GKSMeshRep


- (instancetype)initWithID:(NSNumber *)meshID andName:(NSString *)meshName andOffString:(NSString *)offString
{
    self = [super init];
    if (self) {
        _meshId = meshID;
        _meshName = meshName;
        _offString = offString;
        

        NSError *error;
        GKSMeshParser *parser = [GKSMeshParser sharedMeshParser];
        GKSmesh_3* mesh_ptr = [parser parseOFFMeshString:offString error:&error];

        if (mesh_ptr != NULL) {
            _meshPtr = mesh_ptr;
        }
        else
            self = nil;

    }
    return self;
}


@end
