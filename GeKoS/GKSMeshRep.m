//
//  GKSMeshRep.m
//  GeKoS
//
//  Created by Alex Popadich on 4/19/22.
//

#import "GKSMeshRep.h"
#include "gks/gks.h"

@implementation GKSMeshRep

- (instancetype)init
{
    return ([self initWithID:@(kCubeKind) andMeshPtr:CubeMesh()]);
}

- (instancetype)initWithID:(NSNumber *)meshID andMeshPtr:(GKSmesh_3 *)meshPtr
{
    self = [super init];
    if (self) {
        _meshId = meshID;
        _meshPtr = meshPtr;
        
        NSDictionary *meshNameLookup = @{  @1 : @"Cube",
                                           @2 : @"Sphere",
                                           @3 : @"Pyramid",
                                           @4 : @"Cone",
                                           @5 : @"House"
        };
        _meshName = meshNameLookup[meshID];
        
        _offString = [self convertMeshToOffString:meshPtr];
    }
    return self;
}

    

- (NSString *)convertMeshToOffString:(GKSmesh_3 *)meshPtr
{
    NSMutableString *catString = [NSMutableString stringWithString: @"OFF\n"];
    
    [catString appendFormat:@"%d %d %d\n", meshPtr->vertnum, meshPtr->polynum, meshPtr->edgenum];
    
    GKSvertexArrPtr vertexes = meshPtr->vertices;
    for (GKSint i = 0; i<meshPtr->vertnum; i++) {
        GKSvector3d vertex = vertexes[i];
        [catString appendFormat:@"%lf %lf %lf\n", vertex.crd.x, vertex.crd.y, vertex.crd.z];
    }
    GKSindexArrPtr polygons = meshPtr->polygons;
    GKSint poly_size = 0;
    for (GKSint i = 0; i<meshPtr->polystoresize; i++) {
        if (poly_size == 0){
            poly_size = polygons[i];
            [catString appendFormat:@"%d ",poly_size];
        }
        else {
            poly_size -= 1;
            GKSint polyidx = polygons[i];
            if (poly_size != 0) {
                [catString appendFormat:@"%d ", polyidx];
            }
            else {
                [catString appendFormat:@"%d\n", polyidx];
            }
        }
    }
    
    NSString *resultString = [NSString stringWithString:catString];
    return resultString;
}

    
@end
