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


- (IBAction)importDocument:(id)sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    panel.allowsMultipleSelection = NO;
    
    // This method displays the panel and returns immediately.
    // The completion handler is called when the user selects an
    // item or cancels the panel.
    [panel beginWithCompletionHandler:^(NSInteger result){
        if (result == NSModalResponseOK) {
            NSURL*  theDoc = [[panel URLs] objectAtIndex:0];
     
            // Open  the document.
            GKSmesh_3* mesh_ptr = [self parseOFFMeshFile:theDoc.path];
            if (mesh_ptr != NULL) {
//                GKSvector3d trans; GKSvector3d scale; GKSvector3d rotate;
//                trans.crd.x =0.0; trans.crd.y=0.0; trans.crd.z=0.0; trans.crd.w=1.0;
//                scale.crd.x=1.0; scale.crd.y=1.0; scale.crd.z=1.0; scale.crd.w=1.0;
//                rotate.crd.x=0.0; rotate.crd.y=0.0; rotate.crd.z=0.0; rotate.crd.w=1.0;


                
                GKS3DObject *customMeshObj = [[GKS3DObject alloc] initWithMesh:mesh_ptr ofKind:@(kSpaceShuttleKind)];
                
                // TODO: not working
                [customMeshObj locateX:0.0 Y:0.0 Z:-500.0];
                [customMeshObj computeAction];
                
                [self.content.theScene add3DObject:customMeshObj];
                
                
            }
        }
    }];
}





// MARK: OFF Mesh Parser
- (NSArray<NSString *>*) componentsMatchingRegularExpression:(NSString *)pattern fromString:(NSString *)theString
{
   NSError *errorReturn;
   NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&errorReturn];

   if (!regularExpression)
      return nil;
    
//    NSUInteger numberOfMatches = [regularExpression numberOfMatchesInString:theString
//                                                        options:0
//                                                          range:NSMakeRange(0, [theString length])];

   NSMutableArray *matches = NSMutableArray.new;
   [regularExpression enumerateMatchesInString:theString
                                       options:0
                                         range:NSMakeRange(0, theString.length)
                                    usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop)
                                              {
                                                 [matches addObject:[theString substringWithRange:result.range]];
                                              }
   ];

   return matches.copy; // non-mutable copy
}

// simplified OFF file parser. Object File Format files
// are a very simple way of describing 3D objects.
// a better explanation can be found here
//  https://en.wikipedia.org/wiki/OFF_(file_format)
//
// TODO: parser needs to be excercised with different files
- (GKSmesh_3 *)parseOFFMeshFile:(NSString*)path
{
    int num_verts, num_polys;
    int i, j;
    int vert;
    GKSmesh_3 *anObjectMesh = NULL;
    
    int meta_data_offset;  // First line in file has vertex and polygon counts
    int data_offset;       // Where to start reading
    
    
    GKSpolygonArrPtr polygonList = NULL;
    GKSvertexArrPtr vertexList = NULL;
    GKSnormalArrPtr normalList = NULL;
    GKSvertexArrPtr transList = NULL;
    GKSDCArrPtr devCoordList = NULL;

    
    @try {
        NSError *error = nil;
        NSString *fileTextString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        
        NSCharacterSet* newlineChars = [NSCharacterSet newlineCharacterSet];
        NSArray *textLines = [fileTextString componentsSeparatedByCharactersInSet:newlineChars];
        
        // First line has 3 character format code "OFF"
        NSString* offCodeTag = @"OFF";
        if (![offCodeTag isEqualTo:textLines[0]]) {
            NSLog(@"Not an OFF file!");
            return anObjectMesh;
        }
        
        // Second line 2 or 3 integer numbers
        NSString *componentsString = textLines[1]; // 3 numbers seperated by space
        
// teapot        NSArray *componentsCount = [componentsString componentsSeparatedByString:@"  "];
//        NSArray *componentsCount = [componentsString componentsSeparatedByString:@" "];
        NSArray* componentsCount = [self componentsMatchingRegularExpression:@"\\d+" fromString:componentsString];
        // only interested in vertex and polygon counts
        num_verts = [componentsCount[0] intValue];
        num_polys = [componentsCount[1] intValue];
        
        
        polygonList = (GKSpolygonArrPtr)calloc(num_polys, sizeof(GKSpolygon_3));
        vertexList = (GKSvertexArrPtr)calloc(num_verts, sizeof(GKSvector3d));
        normalList = (GKSnormalArrPtr)calloc(num_polys, sizeof(GKSvector3d));
        transList = (GKSvertexArrPtr)calloc(num_verts, sizeof(GKSvector3d));
        devCoordList = (GKSDCArrPtr)calloc(num_verts, sizeof(GKSpoint_2));
        NSLog(@"Mesh Data:\nVertex Count: %d  Polygon Count %d", num_verts, num_polys);
        
        meta_data_offset = 2;       // 2 text lines
        data_offset = meta_data_offset;
        for(i=0;i<num_verts;i++)
        {
            NSString* vertexLine = textLines[i + data_offset];
// teapot            NSArray* vertexComponentsArr = [vertexLine componentsSeparatedByString:@"  "];
//            NSArray* vertexComponentsArr = [vertexLine componentsSeparatedByString:@" "];
            NSArray* vertexComponentsArr = [self componentsMatchingRegularExpression:@"\\S+" fromString:vertexLine];
            NSString* componentX = vertexComponentsArr[0];
            NSString* componentY = vertexComponentsArr[1];
            NSString* componentZ = vertexComponentsArr[2];
            
            vertexList[i].crd.x = [componentX doubleValue];
            vertexList[i].crd.y = [componentY doubleValue];
            vertexList[i].crd.z = [componentZ doubleValue];
        }
        
        data_offset = meta_data_offset + num_verts;
        for(i=0;i<num_polys;i++)
        {
            NSString* polygonLine = textLines[i + data_offset];
//            NSArray* polygonComponentsArr = [polygonLine componentsSeparatedByString:@" "];
            NSArray* polygonComponentsArr = [self componentsMatchingRegularExpression:@"\\d+" fromString:polygonLine];
            NSString* componentPointCount = polygonComponentsArr[0];
            //fscanf(handle,"%d",&vert);
            vert = [componentPointCount intValue];
            if (vert > GKS_POLY_VERTEX_MAX) {
                NSLog(@"Polygon point count %d too large for my buffer", vert);
                return NULL;
            }
            polygonList[i][0] = vert;
            for(j=1;j<=vert;j++)
            {
                NSString* componentPointNo = polygonComponentsArr[j];
                int pointNo = [componentPointNo intValue];
                //fscanf(handle,"%d",&value);
                polygonList[i][j] = pointNo + 1;
            }
        }
        
        
    } @catch (NSException *exception) {
        NSLog(@"Could not read OFF data file");
    } @finally {
        NSLog(@"Arivadercci Finale");
        anObjectMesh = (GKSmesh_3 *)calloc(1, sizeof(GKSmesh_3));

        anObjectMesh->vertices = vertexList;
        anObjectMesh->vertnum = num_verts;
        anObjectMesh->polygons = polygonList;
        anObjectMesh->polynum = num_polys;
        anObjectMesh->transverts = transList;
        anObjectMesh->devcoords = devCoordList;
    }
    
    return anObjectMesh;
}


@end
