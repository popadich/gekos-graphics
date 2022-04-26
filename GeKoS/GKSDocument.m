//
//  Document.m
//  GeKoS
//
//  Created by Alex Popadich on 11/30/21.
//

#import "GKSDocument.h"
#import "GKSContent.h"
#import "GKSConstants.h"
#import "GKSWindowController.h"
#import "GKSContentViewController.h"
#import "GKSMeshParser.h"

@interface GKSDocument ()

@end

@implementation GKSDocument

- (instancetype)init {
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        _content = [[GKSContent alloc] init];
    }
    return self;
}

+ (BOOL)autosavesInPlace {
    return YES;
}

- (void)makeWindowControllers {
    GKSWindowController *windowController = [[GKSWindowController alloc] initWithWindowNibName:@"GKSDocument"];
    [self addWindowController:windowController];
    
    // No need to specify nib file if it has the same name as the class
    GKSContentViewController *contentController = [[GKSContentViewController alloc] init];
    contentController.representedObject = self.content;
    windowController.contentViewController = contentController;
}

/*
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError *__autoreleasing  _Nullable *)outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error if you return NO.
    // Alternatively, you could remove this method and override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you do, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    
    
    [NSException raise:@"UnimplementedMethod" format:@"%@ is unimplemented", NSStringFromSelector(_cmd)];
    
    
    return NO;

}
*/

//
//- (GKSmesh_3 *)readModelFromURL:(NSURL*)URL;
//{
//    GKSmesh_3 *mesh = nil;
//    NSError *error;
//
//    NSString *meshString = [[NSString alloc] initWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:&error];
//
//    if (meshString != nil) {
//        NSLog(@"Parse Mesh string %@", meshString);
//        GKSMeshParser *parser = [GKSMeshParser sharedMeshParser];
//        mesh = [parser parseOFFMeshFile:URL error:&error];
//
//        if (mesh) {
//
//            // TODO: do this elsewhere
//
//            GKSvector3d loc = GKSMakeVector(0.0, 0.0, 0.0);
//            GKSvector3d rot = GKSMakeVector(0.0, 0.0, 0.0);
//            GKSvector3d sca = GKSMakeVector(1.0, 1.0, 1.0);
//            GKS3DObject *customMeshObj = [[GKS3DObject alloc] initWithMesh:mesh atLocation:loc withRotation:rot andScale:sca];
//            [self.content.sceneController add3DObject:customMeshObj];
//
//        }
//    }
//    return  mesh;
//}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError *__autoreleasing  _Nullable *)error
{
    BOOL hasRead = NO;
    GKSmesh_3 *mesh = nil;
    
    if ([typeName isEqual:@"com.xephyr.off"]) {
        NSLog(@"OFF file to read %@", absoluteURL);
        NSString *meshString = [[NSString alloc] initWithContentsOfURL:absoluteURL encoding:NSUTF8StringEncoding error:error];
        if (meshString != nil) {
            GKSMeshParser *parser = [GKSMeshParser sharedMeshParser];
            mesh = [parser parseOFFMeshString:meshString error:error];
            if (mesh) {
                
                // TODO: mesh monger is too buried and this could all be move there
                // add new mesh to monger
                NSNumber *meshID = [self.content.meshMonger nextID];
                GKSMeshRep *meshRep = [[GKSMeshRep alloc] initWithID:meshID andMeshPtr:mesh];
                [self.content.meshMonger addMeshRep:meshRep];
                
                
                // TODO: object add should happen elsewhere
                GKSvector3d loc = GKSMakeVector(0.0, 0.0, 0.0);
                GKSvector3d rot = GKSMakeVector(0.0, 0.0, 0.0);
                GKSvector3d sca = GKSMakeVector(1.0, 1.0, 1.0);
                
                // TODO: pass mesh here
                GKS3DObjectRep *objectRep = [[GKS3DObjectRep alloc] initWithKind:meshID.intValue atLocation:loc withRotation:rot andScale:sca];
                
                // TODO: fragile
                GKSSceneRep *theScene = [self.content.storyBoard sceneOne];
                [theScene add3DObjectRep:objectRep withMesh:mesh];
                
                
            }
            hasRead = YES;
        }
    }
    else if ([typeName isEqual:@"com.xephyr.json"]) {
//        model = [self.content readModelFromJsonData:data];
    }
    
    return hasRead;

}

@end
