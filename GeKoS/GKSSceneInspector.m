//
//  GKSSceneInspector.m
//  GeKoS
//
//  Created by Alex Popadich on 3/16/22.
//

#import "GKSSceneInspector.h"
#import "GKSSceneController.h"
#import "GKSContent.h"
#import "GKSWindowController.h"


@interface GKSSceneInspector ()

@property (strong)NSNumber *objectCount;
@property (strong)NSNumber *vertexCount;
@property (strong)NSNumber *polygonCount;

@end

@implementation GKSSceneInspector


+ (id)sharedInspector {
    static GKSSceneInspector *sharedInspector = nil;
    
    static dispatch_once_t onceToken; // onceToken = 0
    _dispatch_once(&onceToken, ^{
        sharedInspector = [[GKSSceneInspector alloc] initWithWindowNibName:@"GKSSceneInspector"];
    });
    
    return sharedInspector;
}


- (GKSint)countVertexesInArray:(NSArray *)objArr
{
    GKSint vertices = 0;
    
    for (GKS3DObject *obj in objArr) {
        GKSactor *actor = obj.objectActor;
        GKSmesh_3 mesh = actor->mesh_object;
        GKSint vertex_count = mesh.vertnum;
        vertices += vertex_count;
    }
    
    return vertices;
}

- (GKSint)countPolygonsInArray:(NSArray *)objArr
{
    GKSint polygons = 0;
    
    for (GKS3DObject *obj in objArr) {
        GKSactor *actor = obj.objectActor;
        GKSmesh_3 mesh = actor->mesh_object;
        polygons += mesh.polynum;
    }
    
    return polygons;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    //Get main window, check its kind before accessing the content data.
    // TODO: become an observer for changes to mainWindow

    
    
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    NSWindowController *wc =  [[NSApplication.sharedApplication mainWindow] windowController];
    if ([wc isKindOfClass:[GKSWindowController class]]) {
        GKSContent *repobj = wc.contentViewController.representedObject;
        GKSSceneController *scene = repobj.theScene;
        
        NSInteger count = [scene.objectList count];
        self.objectCount = [NSNumber numberWithInteger:count];
        
        GKSint vertices = [self countVertexesInArray:scene.objectList];
        self.vertexCount = @(vertices);
        
        GKSint polys = [self countPolygonsInArray:scene.objectList];
        self.polygonCount = @(polys);
        
        self.theScene = scene;

    }
}


@end
