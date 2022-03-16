//
//  GKSSceneInspector.m
//  GeKoS
//
//  Created by Alex Popadich on 3/16/22.
//

#import "GKSSceneInspector.h"
#import "GKSScene.h"


@interface GKSSceneInspector ()

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


- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
   
}

@end
