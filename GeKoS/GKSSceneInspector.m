//
//  GKSSceneInspector.m
//  GeKoS
//
//  Created by Alex Popadich on 3/16/22.
//

#import "GKSSceneInspector.h"
#import "GKSSceneRep.h"
#import "GKSSceneController.h"
#import "GKSContent.h"
#import "GKSWindowController.h"
#import "GKSContentViewController.h"

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
    
    for (GKS3DObjectRep *obj in objArr) {
        GKSint vertex_count = obj.getVertexCount;
        vertices += vertex_count;
    }
    
    return vertices;
}

- (GKSint)countPolygonsInArray:(NSArray *)objArr
{
    GKSint polygons = 0;
    
    for (GKS3DObjectRep *obj in objArr) {
        GKSint pc = obj.getPolygonCount;
        polygons += pc;
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
        
        // TODO: use represented object
        GKSContentViewController *cvc = (GKSContentViewController *)wc.contentViewController;
        GKSSceneController *sceneController = cvc.sceneController;
        GKSSceneRep *scene = sceneController.scene;
        
        NSMutableArray *toObject3DReps = [scene valueForKey:@"toObject3DReps"];
        NSInteger count = [scene.toActors count];
        self.objectCount = [NSNumber numberWithInteger:count];
        
        GKSint vertices = [self countVertexesInArray:toObject3DReps];
        self.vertexCount = @(vertices);
        
        GKSint polys = [self countPolygonsInArray:toObject3DReps];
        self.polygonCount = @(polys);
        
        self.scene = scene;

    }
}


@end
