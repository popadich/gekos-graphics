//
//  GKSContentViewController.m
//  GeKoS
//
//  Created by Alex Popadich on 2/23/22.
//

#import "GKSContentViewController.h"
#import "GKSConstants.h"
#import "GKSContent.h"
#import "GKSCameraRep.h"

#import "GKS3DObjectRep.h"
#import "GKS3DObject.h"
#import "GKSScene.h"


@interface GKSContentViewController ()

@property (nonatomic, weak) IBOutlet NSView* cameraCustomView;

@property (strong) NSColor* contentLineColor;
@property (strong) NSColor* contentFillColor;

@property (nonatomic, strong) GKSCameraRep* cameraRep;
@property (nonatomic, strong) GKS3DObjectRep* object3DRep;
@property (nonatomic, strong) GKSScene* theScene;

@end

static void *volumeSceneContext = &volumeSceneContext;
static void *worldDataContext = &worldDataContext;

@implementation GKSContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    // init gks
    // this needs to be done early in the application lifecycle
    gks_init();
    
    // Can't use replace subview because constraints in parent view are lost
    NSView* cameraSubView = self.cameraViewController.view;
    cameraSubView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cameraCustomView addSubview:cameraSubView];

    NSDictionary *viewsDictionary = @{@"newView":cameraSubView};

    NSString *hFormatString = @"H:|-0-[newView]-0-|";
    NSString *vFormatString = @"V:|-[newView]-|";

    NSArray *horzConstraints = [NSLayoutConstraint constraintsWithVisualFormat:hFormatString options:0 metrics:nil views:viewsDictionary];
    NSArray *vertConstraints = [NSLayoutConstraint constraintsWithVisualFormat:vFormatString options:0 metrics:nil views:viewsDictionary];
    
    // add constraints
    [self.view addConstraints:horzConstraints];
    [self.view addConstraints:vertConstraints];

    
    NSError *error;
    NSData *colorData = [[NSUserDefaults standardUserDefaults] dataForKey:gksPrefPenColor];
    if (colorData != nil) {
        self.contentLineColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:colorData error:&error];
    }
    colorData = [[NSUserDefaults standardUserDefaults] dataForKey:gksPrefFillColor];
    if (colorData != nil) {
        self.contentFillColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:colorData error:&error];
    }
    
    
    [self updateVantage:self]; // Set all vantage points to the same default values
    
    // Get values world volume from data and device limits from view bounds
    GKSlimits_3 world_volume = [self.theScene worldVolumeLimits];
    GKSlimits_2 port_rect = [self.drawingViewController getPortLimits];
    
    // Set normalization value transforms
    gks_trans_set_device_viewport(&port_rect);
    gks_trans_set_world_volume(&world_volume);
    
    // Instantiate one 3D object representation to act as a data entry buffer;
    // the data is used to create the actual 3D object added to the 3D world
    // later.
    self.object3DRep =  [[GKS3DObjectRep alloc] init];
    self.object3DRep.lineColor = self.contentLineColor;
    self.object3DRep.fillColor = self.contentFillColor;

    [self setIsCenteredObject:@NO];
    
    [self registerAsObserverForScene];
        
    // notifications come after camera values have been set
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraMovedNotification:) name:@"cameraMoved" object:nil];
    
}

- (void)awakeFromNib {
    // content should be populated by the document read methods
    GKSContent *content = self.representedObject;
    
    GKSScene *scene = content.theScene;
    GKSCameraRep *scene_camera = scene.camera;
    
    self.cameraRep = scene_camera;
    self.cameraViewController.representedObject = self.cameraRep;

    self.theScene = scene;
    self.drawingViewController.representedObject = self.theScene;

    
}

- (void)viewDidLayout {

    // TODO: make sure all matrices have been initialized and set
    [self.theScene transformAllObjects];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void) cameraMovedNotification:(NSNotification *) notification
{
    // [notification name] should always be @"cameraMoved", (if) not needed.
    // If this method is used for observing other notifications, then (if) needed.

    if ([[notification name] isEqualToString:@"cameraMoved"]) {
//        NSDictionary *userInfo = notification.userInfo;
//        NSString *moveType = [userInfo objectForKey:@"moveType"];
        [self.theScene transformAllObjects];
        [self.drawingViewController.view setNeedsDisplay:YES];
    }
}


- (void)registerAsObserverForScene
{
    GKSScene *scene = self.theScene;

    [scene addObserver:self forKeyPath:@"worldBackColor" options:NSKeyValueObservingOptionNew context:worldDataContext];
    [scene addObserver:self forKeyPath:@"worldFillColor" options:NSKeyValueObservingOptionNew context:worldDataContext];
    [scene addObserver:self forKeyPath:@"worldLineColor" options:NSKeyValueObservingOptionNew context:worldDataContext];

}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == worldDataContext) {
        [self.drawingViewController.view setNeedsDisplay:YES];

        NSString *changeType = @"Data change to world objects";
        NSLog(@"World Change: %@", changeType);
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


// Add a 3d object to the scene/world
- (void)addObjectRepToScene:(GKS3DObjectRep *)objRep
{
    // use ObjRep to create an Obj3D
    
    GKSobjectKind kind = objRep.objectKind.intValue;
    GKSmesh_3 *theMesh = MeshOfKind(kind);
    GKSvector3d loc = [objRep positionVector];
    GKSvector3d rot = [objRep rotationVector];
    GKSvector3d sca = [objRep scaleVector];

    GKS3DObject *newGuy = [[GKS3DObject alloc] initWithMesh:theMesh atLocation:loc withRotation:rot andScale:sca];

    newGuy.lineColor = objRep.lineColor;
    newGuy.fillColor = objRep.fillColor;
    
    [newGuy computeAction];               // is this the time?

    [self.theScene add3DObject:newGuy];
    
}


// MARK: ACTIONS
- (IBAction)updateVantage:(id)sender
{
    if ([sender isKindOfClass:[NSButton class]]) {
        GKSint tag = (GKSint)[sender tag];
        gks_trans_set_curr_view_idx(tag);

        [self.theScene transformAllObjects];
        [self.drawingViewController refresh];
    }
}

- (IBAction)performVolumeResizeQuick:(id)sender
{
    // very esoteric calls here, make this simpler
    GKSlimits_3 volume = [self.theScene worldVolumeLimits];
    gks_trans_set_world_volume(&volume);
    
    [self.theScene transformAllObjects];
    [self.drawingViewController refresh];
//        NSLog(@"Scene Change: %lf, %lf, %lf, %lf, %lf, %lf", volume.xmin, volume.xmax, volume.ymin, volume.ymax, volume.zmin, volume.zmax);

}

- (IBAction)performAddQuick:(id)sender {

    // Add 3d object to the object list
    // some other controller needs to handle this?
    [self addObjectRepToScene:self.object3DRep];
    
    [self.drawingViewController refresh];

}

- (IBAction)performDeleteQuick:(id)sender {
    
    [self.theScene deleteLast3DObject];
    [self.drawingViewController refresh];

}


- (IBAction)performLookQuick:(id)sender {
    
    [self.cameraViewController camerSetViewLookAtG];
    [self.theScene transformAllObjects];
    [self.drawingViewController refresh];
}


- (IBAction)performUpdateQuick:(id)sender {
    
    [self.theScene transformAllObjects];
    [self.drawingViewController refresh];
}




// MARK: OPEN/SAVE PANEL

- (IBAction)importDocument:(id)sender {

    NSOpenPanel* panel = [NSOpenPanel openPanel];
    panel.allowsMultipleSelection = NO;
    
    // TODO: allowedContentTypes - macOS 11
    if (@available(macOS 11.0, *)) {

//        id objects[] = {@"com.xephyr.off"};
//        NSUInteger count = sizeof(objects) / sizeof(id);
//        NSArray *contentArray = [NSArray arrayWithObjects:objects
//                                             count:count];
        
//        NSArray *contentArray = @[@"com.xephyr.off"];
//        NSLog(@"OS 11 Here %@", contentArray);
//        [panel setAllowedContentTypes:contentArray];
 
    } else {
        NSArray *typeArray = @[@"off", @"OFF"];
        [panel setAllowedFileTypes:typeArray];
    }

    // This method displays the panel and returns immediately.
    // The completion handler is called when the user selects an
    // item or cancels the panel.
    [panel beginWithCompletionHandler:^(NSInteger result){
        if (result == NSModalResponseOK) {
            NSURL*  theDoc = [[panel URLs] objectAtIndex:0];
     
            // Open  the document.
            GKSmesh_3* mesh_ptr = [self parseOFFMeshFile:theDoc.path];
            if (mesh_ptr != NULL) {
                // TODO: use objectRef
                GKSmesh_3 *theMesh = mesh_ptr;
                GKSvector3d loc = [self.object3DRep positionVector];
                GKSvector3d rot = [self.object3DRep rotationVector];
                GKSvector3d sca = [self.object3DRep scaleVector];
                
                GKS3DObject *customObj = [[GKS3DObject alloc] initWithMesh:theMesh atLocation:loc withRotation:rot andScale:sca];

                // copy data from Rep to Obj3D
                customObj.lineColor = [self.object3DRep lineColor];
                customObj.fillColor = [self.object3DRep fillColor];
    
                [customObj computeAction];
                
                [self.theScene add3DObject:customObj];
                [self.drawingViewController refresh];
                
            }
        }
    }];
}


// FIXME: Panel Bug
/*

// this started showing up in the logs, it has to be related to the open panel

Could not instantiate class NSURL. Error: Error Domain=NSCocoaErrorDomain Code=4864 "value for key 'root' was of unexpected class 'NSNull'. Allowed classes are '{(
    NSURL
)}'." UserInfo={NSDebugDescription=value for key 'root' was of unexpected class 'NSNull'. Allowed classes are '{(
    NSURL
)}'.}
*/


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
            NSArray* vertexComponentsArr = [self componentsMatchingRegularExpression:@"\\S+" fromString:vertexLine];
            NSString* componentX = vertexComponentsArr[0];
            NSString* componentY = vertexComponentsArr[1];
            NSString* componentZ = vertexComponentsArr[2];
            
            vertexList[i].crd.x = [componentX doubleValue];
            vertexList[i].crd.y = [componentY doubleValue];
            vertexList[i].crd.z = [componentZ doubleValue];
            vertexList[i].crd.w = 1.0;
        }
        
        data_offset = meta_data_offset + num_verts;
        for(i=0;i<num_polys;i++)
        {
            NSString* polygonLine = textLines[i + data_offset];
            NSArray* polygonComponentsArr = [self componentsMatchingRegularExpression:@"\\d+" fromString:polygonLine];
            NSString* componentPointCount = polygonComponentsArr[0];
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
