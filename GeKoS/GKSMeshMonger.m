//
//  GKSMeshMonger.m
//  GeKoS
//
//  Created by Alex Popadich on 4/20/22.
//

#import "GKSMeshMonger.h"
#import "GKSMeshParser.h"
#include "gks/gks.h"
#import "Document+CoreDataModel.h"

@interface GKSMeshMonger ()

@property (strong)NSMutableDictionary *meshes;

@end

@implementation GKSMeshMonger



- (instancetype)init
{
    self = [super init];
    if (self) {
        _meshes = [[NSMutableDictionary alloc] init];

    }
    return self;
}

- (void)addMeshRepToMongerMenu:(GKSMeshRep * _Nonnull)meshRep {
    // TODO: verify all fields
    [self.meshes setObject:meshRep forKey:meshRep.meshId];
}

- (void)insertMeshRep:(GKSMeshRep *)meshRep intoMoc:(NSManagedObjectContext *)moc
{
    if (moc != nil) {
        
        NSNumber *newMeshID = [self nextID];
        
        MeshEntity *meshEnt = [NSEntityDescription insertNewObjectForEntityForName:@"MeshEntity" inManagedObjectContext:moc];
        
        meshEnt.meshID = newMeshID.intValue;
        meshEnt.meshName = meshRep.meshName;
        meshEnt.offString = meshRep.offString;
        
        
        meshRep.meshId = newMeshID;
        [self addMeshRepToMongerMenu:meshRep];

        [moc processPendingChanges];   // TODO: do I need this?
    }
}

- (GKSMeshRep *)getMeshRep:(NSNumber *)meshID
{
    GKSMeshRep *theMesh = nil;
    theMesh = [self.meshes objectForKey:meshID];
    return theMesh;
}

- (NSNumber *)nextID
{
    GKSint calcID = (GKSint)[self.meshes count] + 1;
    NSNumber *newID = [NSNumber numberWithInt:(GKSint)calcID];
    return newID;
}


- (NSArray *)meshList
{
    NSMutableArray *meshesArr = [[NSMutableArray alloc] init];
    for (int i=kCubeKind; i<=kHouseKind; i++) {
        GKSMeshRep *meshRep = [self getMeshRep:@(i)];
        [meshesArr addObject:meshRep];
        
    }
    
    return ([NSArray arrayWithArray:meshesArr]);
}



- (NSString *)convertMeshToOffString:(GKSmesh_3 *)meshPtr
{

    NSMutableString *catString = [NSMutableString stringWithString: @"OFF\n"];
    int edgeNumComputed = meshPtr->edgenum;
    [catString appendFormat:@"%d %d %d\n", meshPtr->vertnum, meshPtr->polynum, edgeNumComputed];
    
    GKSvertexArrPtr vertexes = meshPtr->vertices;
    for (GKSint i = 0; i<meshPtr->vertnum; i++) {
        GKSvector3d vertex = vertexes[i];
        [catString appendFormat:@"%.3lf %.3lf %.3lf\n", vertex.crd.x, vertex.crd.y, vertex.crd.z];
    }
    GKSindexArrPtr polygons = meshPtr->polygons;
    GKSint poly_size = 0;
    GKSint total_edges = 0;
    for (GKSint i = 0; i<meshPtr->polystoresize; i++) {
        if (poly_size == 0){
            poly_size = polygons[i];
            total_edges += poly_size;
            [catString appendFormat:@"%d ",poly_size];
        }
        else {
            poly_size -= 1;
            GKSint polyidx = polygons[i];
            if (poly_size != 0) {
                [catString appendFormat:@"%d ", polyidx-1];
            }
            else {
                [catString appendFormat:@"%d\n", polyidx-1];
            }
        }
    }
    
    NSString *resultString = [NSString stringWithString:catString];
    return resultString;
}


@end
