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
        
        GKSmesh_3 *cubeMesh = CubeMesh();
        NSString *cubeOffString = [self convertMeshToOffString:cubeMesh];
        GKSMeshRep *cubemeshRep = [[GKSMeshRep alloc] initWithID:@(kCubeKind) andMeshPtr:cubeMesh andOffString:cubeOffString];
        [self.meshes setObject:cubemeshRep forKey:cubemeshRep.meshId];
        
        
        GKSmesh_3 *pyramidMesh = PyramidMesh();
        NSString *pyramidOffString = [self convertMeshToOffString:pyramidMesh];
        GKSMeshRep *pyramidmeshRep = [[GKSMeshRep alloc] initWithID:@(kPyramidKind) andMeshPtr:pyramidMesh andOffString:pyramidOffString];
        [self.meshes setObject:pyramidmeshRep forKey:pyramidmeshRep.meshId];

        
        
        GKSmesh_3 *houseMesh = HouseMesh();
        NSString *houseOffString = [self convertMeshToOffString:houseMesh];
        GKSMeshRep *housemeshRep = [[GKSMeshRep alloc] initWithID:@(kHouseKind) andMeshPtr:houseMesh andOffString:houseOffString];
        [self.meshes setObject:housemeshRep forKey:housemeshRep.meshId];

        
        
        GKSmesh_3 *sphereMesh = SphereMesh();
        NSString *sphereOffString = [self convertMeshToOffString:sphereMesh];
        GKSMeshRep *spheremeshRep = [[GKSMeshRep alloc] initWithID:@(kSphereKind) andMeshPtr:sphereMesh andOffString:sphereOffString];
        [self.meshes setObject:spheremeshRep forKey:spheremeshRep.meshId];

        
        GKSmesh_3 *coneMesh = ConeMesh();
        NSString *coneOffString = [self convertMeshToOffString:coneMesh];
        GKSMeshRep *conemeshRep = [[GKSMeshRep alloc] initWithID:@(kConeKind) andMeshPtr:coneMesh andOffString:coneOffString];
        [self.meshes setObject:conemeshRep forKey:conemeshRep.meshId];

    }
    return self;
}

- (void)addMeshRep:(GKSMeshRep *)meshRep
{
    if (self.managedObjectContext != nil) {
        GKSint calcID = (GKSint)[self.meshes count] + 1;
        meshRep.meshId = @(calcID);
        
        [self.meshes setObject:meshRep forKey:@(calcID)];
        
        MeshEntity *meshEnt = [NSEntityDescription insertNewObjectForEntityForName:@"MeshEntity" inManagedObjectContext:self.managedObjectContext];
        
        meshEnt.meshID = calcID;
        meshEnt.meshName = meshRep.meshName;
        meshEnt.offString = meshRep.offString;
        
        [self.managedObjectContext processPendingChanges];   // TODO: do I need this?
    }
}

- (GKSMeshRep *)getMeshRep:(NSNumber *)meshID
{
    GKSMeshRep *theMesh = nil;
    
    if (meshID.intValue > kHouseKind ) {
        if (self.managedObjectContext != nil) {
            theMesh = [self.meshes objectForKey:meshID];
            if (theMesh == nil) {
                // try to fetch from core data
                
                NSFetchRequest *request = [MeshEntity fetchRequest];
                [request setPredicate:[NSPredicate predicateWithFormat:@"meshID == %@", meshID]];
                
                MeshEntity *meshEnt = nil;
                NSError *error = nil;
                NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
                if (!results) {
                    NSLog(@"Error fetching mesh : %@\n%@", [error localizedDescription], [error userInfo]);
                    abort();
                }
                if (results.count == 1) {
                    meshEnt = [results objectAtIndex:0];
                    NSString *offString = meshEnt.offString;
                    
                    GKSMeshParser *parser = [GKSMeshParser sharedMeshParser];
                    
                    GKSmesh_3 *mesh_ptr = [parser parseOFFMeshString:offString error:&error];
                    
                    GKSMeshRep *aMesh = [[GKSMeshRep alloc] initWithID:@(meshEnt.meshID) andMeshPtr:mesh_ptr andOffString:offString];
                    
                    aMesh.meshId = @(meshEnt.meshID);
                    aMesh.meshName = meshEnt.meshName;
                    aMesh.offString = offString;
                    aMesh.meshPtr = mesh_ptr;
                    
                    theMesh = aMesh;
                    [self.meshes setObject:aMesh forKey:meshID];

                    NSLog(@"%@", theMesh.offString);
                }
            }
        }
    }
    else {
        theMesh = [self.meshes objectForKey:meshID];
    }
    
    
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
    
    [catString appendFormat:@"%d %d %d\n", meshPtr->vertnum, meshPtr->polynum, meshPtr->edgenum];
    
    GKSvertexArrPtr vertexes = meshPtr->vertices;
    for (GKSint i = 0; i<meshPtr->vertnum; i++) {
        GKSvector3d vertex = vertexes[i];
        [catString appendFormat:@"%.3lf %.3lf %.3lf\n", vertex.crd.x, vertex.crd.y, vertex.crd.z];
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
