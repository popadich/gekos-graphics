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


+ (id)sharedMeshMonger {
    static GKSMeshMonger *sharedMeshMonger = nil;
    
    static dispatch_once_t onceToken; // onceToken = 0
    _dispatch_once(&onceToken, ^{
        sharedMeshMonger = [[GKSMeshMonger alloc] init];
    });
    
    return sharedMeshMonger;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        _meshes = [[NSMutableDictionary alloc] init];
        
//        GKSmesh_3 *cubeMesh = CubeMesh();
//        NSString *cubeOffString = [self convertMeshToOffString:cubeMesh];
//        GKSMeshRep *cubemeshRep = [[GKSMeshRep alloc] initWithID:@(kCubeKind) andName:@"Cube" andMeshPtr:cubeMesh andOffString:cubeOffString];
//        [self.meshes setObject:cubemeshRep forKey:cubemeshRep.meshId];
//        
//        
//        GKSmesh_3 *pyramidMesh = PyramidMesh();
//        NSString *pyramidOffString = [self convertMeshToOffString:pyramidMesh];
//        GKSMeshRep *pyramidmeshRep = [[GKSMeshRep alloc] initWithID:@(kPyramidKind) andName:@"Pyramid" andMeshPtr:pyramidMesh andOffString:pyramidOffString];
//        [self.meshes setObject:pyramidmeshRep forKey:pyramidmeshRep.meshId];
//
//        
//        
//        GKSmesh_3 *houseMesh = HouseMesh();
//        NSString *houseOffString = [self convertMeshToOffString:houseMesh];
//        GKSMeshRep *housemeshRep = [[GKSMeshRep alloc] initWithID:@(kHouseKind) andName:@"House" andMeshPtr:houseMesh andOffString:houseOffString];
//        [self.meshes setObject:housemeshRep forKey:housemeshRep.meshId];
//
//        
//        
//        GKSmesh_3 *sphereMesh = SphereMesh();
//        NSString *sphereOffString = [self convertMeshToOffString:sphereMesh];
//        GKSMeshRep *spheremeshRep = [[GKSMeshRep alloc] initWithID:@(kSphereKind) andName:@"Sphere" andMeshPtr:sphereMesh andOffString:sphereOffString];
//        [self.meshes setObject:spheremeshRep forKey:spheremeshRep.meshId];
//
//        
//        GKSmesh_3 *coneMesh = ConeMesh();
//        NSString *coneOffString = [self convertMeshToOffString:coneMesh];
//        GKSMeshRep *conemeshRep = [[GKSMeshRep alloc] initWithID:@(kConeKind) andName: @"Cone" andMeshPtr:coneMesh andOffString:coneOffString];
//        [self.meshes setObject:conemeshRep forKey:conemeshRep.meshId];

    }
    return self;
}

- (void)addToMoc:(NSManagedObjectContext *)moc meshEntityFromRep:(GKSMeshRep *)meshRep
{
    if (moc != nil) {
        GKSint calcID = (GKSint)[self.meshes count] + 1;
        meshRep.meshId = @(calcID);
        
        [self.meshes setObject:meshRep forKey:@(calcID)];
        
        MeshEntity *meshEnt = [NSEntityDescription insertNewObjectForEntityForName:@"MeshEntity" inManagedObjectContext:moc];
        
        meshEnt.meshID = calcID;
        meshEnt.meshName = meshRep.meshName;
        meshEnt.offString = meshRep.offString;
        
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
    NSMutableArray *meshes = [[NSMutableArray alloc] init];
    for (int i=kCubeKind; i<=kHouseKind; i++) {
        GKSMeshRep *meshRep = [self getMeshRep:@(i)];
        [meshes addObject:meshRep];
        
    }
    
    return ([NSArray arrayWithArray:meshes]);
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
