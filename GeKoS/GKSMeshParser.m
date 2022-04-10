//
//  GKSMeshParser.m
//  GeKoS
//
//  Created by Alex Popadich on 4/8/22.
//


#import "GKSMeshParser.h"

@implementation GKSMeshParser


+ (id)sharedMeshParser {
    static GKSMeshParser *sharedMeshParser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMeshParser = [[self alloc] init];
    });
    return sharedMeshParser;
}


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
- (GKSmesh_3 *)parseOFFMeshFile:(NSURL*)URL error:(NSError **)error
{
    GKSmesh_3 *anObjectMesh = NULL;
    
    NSString *fileTextString = [[NSString alloc] initWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:error];
    
    anObjectMesh = [self parseOFFMeshString:fileTextString error:error];
    
    return anObjectMesh;
}


// TODO: parser needs to be excercised with different files
- (GKSmesh_3 *)parseOFFMeshString:(NSString*)meshString error:(NSError **)error
{
    int specified_verts;
    int specified_polys;
    int specified_edges;
    
    int vert_count = 0;
    int poly_count = 0;
    int edge_count = 0;
    GKSmesh_3 *anObjectMesh = NULL;
    
    int meta_data_offset = 2;  // 2 text lines offset
    
//    GKSpolygonArrPtr polygon_array = NULL;
    GKSvertexArrPtr vertex_array = NULL;
    GKSint *compact_array = NULL;

    @try {
        NSString *fileTextString = meshString;
        
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
        
//        polygon_array = (GKSpolygonArrPtr)calloc(specified_polys, sizeof(GKSpolygon_3));
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
//                free(polygon_array);
                free(vertex_array);
                free(compact_array);
                return NULL;
            }
//            polygon_array[i][0] = verts;
            edge_count += verts;
            poly_count += 1;
            
            compact_array[k] = verts;    // compact string all in a row
            k += 1;
            for(GKSint j=1; j<=verts; j++)
            {
                NSString* componentPointNo = polygonComponentsArr[j];
                int pointNo = [componentPointNo intValue];
//                polygon_array[i][j] = pointNo + 1;
                
                compact_array[k] = pointNo + 1;    // compact string all in a row
                k += 1;
                
            }
            
        }
    } @catch (NSException *exception) {
        NSLog(@"Could not read OFF data file");
        NSDictionary *userInfoDict = @{NSLocalizedDescriptionKey : @"Mesh parse bad"};
        // populate the error object with the details
        *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadCorruptFileError userInfo:userInfoDict];
    } @finally {
        NSLog(@"Arivadercci Finale");
        NSLog(@"Meta Data:  Verts: %d  Polys: %d  Edges: %d", specified_verts, specified_polys, specified_edges);
        NSLog(@"Mesh        Verts: %d  Polys: %d  Edges: %d", vert_count, poly_count, edge_count);
        
        anObjectMesh = (GKSmesh_3 *)calloc(1, sizeof(GKSmesh_3));

        anObjectMesh->vertices = vertex_array;
        anObjectMesh->vertnum = specified_verts;
//        anObjectMesh->polygons = polygon_array;
        anObjectMesh->polynum = specified_polys;
        anObjectMesh->polygons_compact = compact_array;
    }
    
    return anObjectMesh;
}



@end
