//
//  MeshEntity+CoreDataClass.m
//  GeKoS
//
//  Created by Alex Popadich on 5/19/22.
//
//

#import "MeshEntity+CoreDataClass.h"

@implementation MeshEntity


- (NSString *)summary {
    [self willAccessValueForKey:@"summary"];

    NSString *summary = [NSString stringWithFormat:@"%d  : %d  : %d", self.vertexCount, self.polygonCount, self.edgeCount];
    
    [self didAccessValueForKey:@"summary"];
    
    return summary;
}

- (void)setMeshPointer:(GKSMeshRep * _Nullable)meshRep
{
    [self willChangeValueForKey:@"meshPointer"];
    
    self.meshID = meshRep.meshId.intValue;
    self.meshName = meshRep.meshName;
    self.offString = meshRep.offString;
    
    self.vertexCount = meshRep.meshPtr->vertnum;
    self.polygonCount = meshRep.meshPtr->polynum;
    self.edgeCount = meshRep.meshPtr->edgenum;
    self.volumeMaxX = meshRep.meshPtr->volume.xmax;
    self.volumeMaxY = meshRep.meshPtr->volume.ymax;
    self.volumeMaxZ = meshRep.meshPtr->volume.zmax;
    self.volumeMinX = meshRep.meshPtr->volume.xmin;
    self.volumeMinY = meshRep.meshPtr->volume.ymin;
    self.volumeMinZ = meshRep.meshPtr->volume.zmin;
    [self setPrimitiveValue:meshRep forKey:@"meshPointer"];

    [self didChangeValueForKey:@"meshPointer"];
}

- (GKSMeshRep *)meshPointer
{
    [self willAccessValueForKey:@"meshPointer"];
    
    GKSMeshRep *meshRep = [self primitiveValueForKey:@"meshPointer"];
    if (meshRep == nil) {
        NSNumber *meshID = @(self.meshID);
        meshRep = [[GKSMeshRep alloc] initWithID:meshID andName:self.meshName andOffString:self.offString];
        
        [self setPrimitiveValue:meshRep forKey:@"meshPointer"];
    }
    
    [self didAccessValueForKey:@"meshPointer"];
    return meshRep;
}

@end
