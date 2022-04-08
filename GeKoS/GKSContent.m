//
//  GKSContent.m
//  GeKoS
//
//  Created by Alex Popadich on 3/15/22.
//

#import "GKSContent.h"
#import "GKSCameraRep.h"
#import "GKS3DObject.h"
#import "GKSConstants.h"

@implementation GKSContent

- (instancetype)init
{
    self = [super init];
    if (self) {
        GKSCameraRep *cameraRep = [[GKSCameraRep alloc] init];
        GKSScene *aScene = [[GKSScene alloc] initWithCamera:cameraRep];
        
        // Default volume bounds to the GKS 3D world.
        
        aScene.worldVolumeMinX = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMinX];
        aScene.worldVolumeMinY = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMinY];
        aScene.worldVolumeMinZ = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMinZ];
        
        aScene.worldVolumeMaxX = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMaxX];
        aScene.worldVolumeMaxY = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMaxY];
        aScene.worldVolumeMaxZ = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMaxZ];
        
        
        // TODO: remove when done with playing
        BOOL playing = NO;
        if (playing) {
            for (int i=-3; i<4; i++) {
                GKS3DObject *object3D = [[GKS3DObject alloc] init];
                [object3D locateX:2.0 * i Y:i%2 Z:0.0];

                [aScene add3DObject:object3D];
            }
        }


        _theScene = aScene;
    }
    return self;
}




- (GKSmesh_3 *)readModelFromURL:(NSURL*)URL;
{
    GKSmesh_3 *model = nil;
    NSError *error;

    NSString *contentString = [[NSString alloc] initWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:&error];
    if (contentString != nil) {
        NSLog(@"Parse Mesh string %@", contentString);
        
        GKSvector3d loc = GKSMakeVector(0.0, 0.0, 0.0);
        GKSvector3d rot = GKSMakeVector(0.0, 0.0, 0.0);
        GKSvector3d sca = GKSMakeVector(1.0, 1.0, 1.0);
        
        model = [self parseOFFMeshFile:URL];
        if (model) {
            GKS3DObject *customMeshObj = [[GKS3DObject alloc] initWithMesh:model atLocation:loc withRotation:rot andScale:sca];
            [_theScene add3DObject:customMeshObj];
            
        }
//        self.contentString = contentString;
//        XSRayParser* parser = [XSRayParser sharedRayParser];
//        model = [parser doParseRaw:contentString];
//        self.contentModel = model;
    }
    return  model;
}

// MARK: OFF Mesh Parser
- (NSArray<NSString *>*)componentsMatchingRegularExpression:(NSString *)pattern fromString:(NSString *)theString
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
- (GKSmesh_3 *)parseOFFMeshFile:(NSURL*)URL
{
    int specified_verts;
    int specified_polys;
    int specified_edges;
    
    int vert_count = 0;
    int poly_count = 0;
    int edge_count = 0;
    GKSmesh_3 *anObjectMesh = NULL;
    
    int meta_data_offset = 2;  // 2 text lines offset
    
    GKSpolygonArrPtr polygon_array = NULL;
    GKSvertexArrPtr vertex_array = NULL;
    GKSint *compact_array = NULL;

    @try {
        NSError *error = nil;
        NSString *fileTextString = [[NSString alloc] initWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:&error];
        
        NSCharacterSet* newlineChars = [NSCharacterSet newlineCharacterSet];
        NSArray *textLines = [fileTextString componentsSeparatedByCharactersInSet:newlineChars];
        
        // First line has 3 character format code "OFF"
        NSString* offCodeTag = @"OFF";
        if (![offCodeTag isEqualTo:textLines[0]]) {
            NSLog(@"Not an OFF file!");
            return NULL;
        }
        
        // Second line 3 integer numbers seperated by space
//        NSString *componentsString = textLines[1];
        NSArray* componentsCount = [self componentsMatchingRegularExpression:@"\\d+" fromString:textLines[1]];
        specified_verts = [componentsCount[0] intValue];
        specified_polys = [componentsCount[1] intValue];
        specified_edges = [componentsCount[2] intValue];
        
        polygon_array = (GKSpolygonArrPtr)calloc(specified_polys, sizeof(GKSpolygon_3));
        vertex_array = (GKSvertexArrPtr)calloc(specified_verts, sizeof(GKSvector3d));
        
        // TODO: verify calculated array size
        long computed_size = specified_edges * 2 + specified_polys;
        compact_array = (GKSint *)calloc(computed_size, sizeof(GKSint));
        
        
        int current_line_no = meta_data_offset;
        for(GKSint i=0; i<specified_verts; i++)
        {
            NSString* vertexLine = textLines[current_line_no];
            NSArray* vertexComponentsArr = [self componentsMatchingRegularExpression:@"\\S+" fromString:vertexLine];
            NSString* componentX = vertexComponentsArr[0];
            NSString* componentY = vertexComponentsArr[1];
            NSString* componentZ = vertexComponentsArr[2];
            
            vertex_array[i].crd.x = [componentX doubleValue];
            vertex_array[i].crd.y = [componentY doubleValue];
            vertex_array[i].crd.z = [componentZ doubleValue];
            vertex_array[i].crd.w = 1.0;
            current_line_no += 1;
            vert_count += 1;
        }
        
        int k = 0;
        edge_count = 0;
        
        for(GKSint i=0; i<specified_polys; i++)
        {
            NSString* polygonLine = textLines[current_line_no + i];
            NSArray* polygonComponentsArr = [self componentsMatchingRegularExpression:@"\\d+" fromString:polygonLine];
            NSString* componentPointCount = polygonComponentsArr[0];
            int verts = [componentPointCount intValue];
            if (verts > GKS_POLY_VERTEX_MAX) {
                NSLog(@"Polygon point count %d too large for my buffer", verts);
                free(polygon_array);
                free(vertex_array);
                free(compact_array);
                return NULL;
            }
            polygon_array[i][0] = verts;
            edge_count += verts;
            poly_count += 1;
            
            compact_array[k] = verts;    // compact string all in a row
            k += 1;
            for(GKSint j=1; j<=verts; j++)
            {
                NSString* componentPointNo = polygonComponentsArr[j];
                int pointNo = [componentPointNo intValue];
                polygon_array[i][j] = pointNo + 1;
                
                compact_array[k] = pointNo + 1;    // compact string all in a row
                k += 1;
                
            }
            
        }
    } @catch (NSException *exception) {
        NSLog(@"Could not read OFF data file");
    } @finally {
        NSLog(@"Arivadercci Finale");
        NSLog(@"Meta Data:  Verts: %d  Polys: %d  Edges: %d", specified_verts, specified_polys, specified_edges);
        NSLog(@"Mesh        Verts: %d  Polys: %d  Edges: %d", vert_count, poly_count, edge_count);
        
        anObjectMesh = (GKSmesh_3 *)calloc(1, sizeof(GKSmesh_3));

        anObjectMesh->vertices = vertex_array;
        anObjectMesh->vertnum = specified_verts;
        anObjectMesh->polygons = polygon_array;
        anObjectMesh->polynum = specified_polys;
        anObjectMesh->polygons_compact = compact_array;
    }
    
    return anObjectMesh;
}


@end
