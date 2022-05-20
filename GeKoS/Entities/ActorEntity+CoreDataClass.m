//
//  ActorEntity+CoreDataClass.m
//  GeKoS
//
//  Created by Alex Popadich on 5/16/22.
//
//

#import "ActorEntity+CoreDataClass.h"
#import "GKSContent.h"
#import "GKSDocument.h"

@interface ActorEntity ()
@property (strong) NSString *primitiveSummary;
@end

@implementation ActorEntity

@synthesize primitiveSummary;

- (NSString *)summary {
    if (primitiveSummary != nil) {
        return primitiveSummary;
    }
    [self willAccessValueForKey:@"summary"];

    NSString *summary = [NSString stringWithFormat:@"%6.2lf  : %6.2lf  : %6.2lf", self.locX, self.locY, self.locZ];
    
    primitiveSummary = summary;
    
    [self didAccessValueForKey:@"summary"];
    
    return summary;
}

- (void) setLocX:(double)locX
{
    [self willChangeValueForKey:@"locX"];
    [self willChangeValueForKey:@"summary"];
    
    [self setPrimitiveValue:@(locX) forKey:@"locX"];
    primitiveSummary = nil;
    
    [self didChangeValueForKey:@"locX"];
    [self didChangeValueForKey:@"summary"];
}

- (void) setLocY:(double)locY
{
    [self willChangeValueForKey:@"locY"];
    [self willChangeValueForKey:@"summary"];
    
    [self setPrimitiveValue:@(locY) forKey:@"locY"];
    primitiveSummary = nil;

    [self didChangeValueForKey:@"locY"];
    [self didChangeValueForKey:@"summary"];
}

- (void) setLocZ:(double)locZ
{
    [self willChangeValueForKey:@"locZ"];
    [self willChangeValueForKey:@"summary"];
    
    [self setPrimitiveValue:@(locZ) forKey:@"locZ"];
    primitiveSummary = nil;

    [self didChangeValueForKey:@"locZ"];
    [self didChangeValueForKey:@"summary"];
}


- (GKS3DActor *)transientActor
{
    [self willAccessValueForKey:@"transientActor"];
    
    GKS3DActor *theActor =  [self primitiveValueForKey:@"transientActor"];
    
    if (theActor == nil) {
        GKSDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
        GKSContent *theContent = doc.content;
        NSManagedObjectContext *moc = [theContent managedObjectContext];
        NSFetchRequest *meshRequest = [NSFetchRequest fetchRequestWithEntityName:@"MeshEntity"];

        [meshRequest setPredicate:[NSPredicate predicateWithFormat:@"meshID == %d", self.kind]];


        NSError *error = nil;
        NSArray *results = [moc executeFetchRequest:meshRequest error:&error];
        if (!results) {
            NSLog(@"Error fetching mesh object: %@\n%@", [error localizedDescription], [error userInfo]);
            abort();
        }
        
        if (results.count == 1) {
            NSManagedObject *meshEnt = results[0];
            
            NSNumber *meshID = [meshEnt valueForKey:@"meshID"];
            GKSMeshRep *meshRep = [meshEnt valueForKey:@"meshPointer"];
            
            GKSvector3d loc = GKSMakeVector(self.locX, self.locY, self.locZ);
            GKSvector3d rot = GKSMakeVector(self.rotX, self.rotY, self.rotZ);
            GKSvector3d scale = GKSMakeVector(self.scaleX, self.scaleY, self.scaleZ);
            
            theActor = [[GKS3DActor alloc] initWithMesh:meshRep.meshPtr ofKind:meshID atLocation:loc withRotation:rot andScale:scale];
            
            [self setPrimitiveValue:theActor forKey:@"transientActor"];
            
        }
    }
    
    [self didAccessValueForKey:@"transientActor"];
    
    return theActor;
}

@end
