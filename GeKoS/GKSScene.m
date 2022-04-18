//
//  GKSScene.m
//  gks-cocoa
//
//  Created by Alex Popadich on 7/31/21.
//

#import "GKSScene.h"
#import "GKSConstants.h"

@interface GKSScene () {
    float seg_vect[3];
    GKSlimits_3 volume;
}



@end


@implementation GKSScene

- (instancetype)initWithCamera:(GKSCameraRep *)aCamera
{
    self = [super init];
    if (self) {
        // initialize scene array
        _objectList = [[NSMutableArray alloc] init];
        
        _worldVolumeMinX = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMinX];
        _worldVolumeMaxX = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMaxX];
        _worldVolumeMinY = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMinY];
        _worldVolumeMaxY = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMaxY];
        _worldVolumeMinZ = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMinZ];
        _worldVolumeMaxZ = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefWorldVolumeMaxZ];
        
        NSError* error;
        NSColor* aColor;
        
        NSData* theData = [[NSUserDefaults standardUserDefaults] dataForKey:gksPrefBackgroundColor];
        if (theData != nil){
            aColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:theData error:&error];
            if (error.code == noErr) {
                self.worldBackColor = aColor;
            }
        }
        theData = [[NSUserDefaults standardUserDefaults] dataForKey:gksPrefPenColor];
        if (theData != nil){
            aColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:theData error:&error];
            if (error.code == noErr) {
                self.worldLineColor = aColor;
            }
        };
        theData = [[NSUserDefaults standardUserDefaults] dataForKey:gksPrefFillColor];
        if (theData != nil) {
            aColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:theData error:&error];
            if (error.code == noErr) {
                self.worldFillColor = aColor;
            }
        }
        self.camera = aCamera;
    }
    return self;
}


- (GKSlimits_3 *)worldVolumeLimits
{
    volume.xmin = self.worldVolumeMinX.doubleValue;
    volume.ymin = self.worldVolumeMinY.doubleValue;
    volume.zmin = self.worldVolumeMinZ.doubleValue;
    
    volume.xmax = self.worldVolumeMaxX.doubleValue;
    volume.ymax = self.worldVolumeMaxY.doubleValue;
    volume.zmax = self.worldVolumeMaxZ.doubleValue;
    return &volume;
}

- (void) add3DObject:(GKS3DObject*)object3D
{
//    NSLog(@"3D Object of kind: %ld \n ScaleX: %lf \n TransX: %lf\n TransY: %lf\n TransZ: %lf", object3D.objectKind.integerValue, object3D.scaleX.floatValue, object3D.transX.floatValue, object3D.transY.floatValue, object3D.transZ.floatValue);
    [object3D computeActorInContext:self.context];               // is this the time?

    [self.objectList addObject:object3D];
}



- (void)deleteLast3DObject
{
    // FIXME: free allocated memory here
    
    GKSmesh_3 *its_mesh = NULL;
    GKS3DObject *lasObj = [self.objectList lastObject];
    its_mesh = lasObj.getMeshPointer;
    free_mesh(its_mesh);
    
    [self.objectList removeLastObject];
}

- (void)transformAllObjects
{
    GKScontext3DPtr ctx = self.context;
    for (GKS3DObject *obj in self.objectList) {
        [obj computeActorInContext:ctx];
    }
}

- (void)setTheWorldVolume
{
    // very esoteric calls here, make this simpler
    GKSlimits_3 *volume = [self worldVolumeLimits];
    gks_norms_set_world_volume(self.context, volume);
    
}


@end
