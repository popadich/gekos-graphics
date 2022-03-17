//
//  GKSConstants.h
//  GeKoS
//
//  Created by Alex Popadich on 1/2/22.
//

#ifndef GKSConstants_h
#define GKSConstants_h

#define gksPrefViewWidth @"viewWidth"
#define gksPrefViewHeight @"viewHeight"
#define gksPrefVirtualWidth @"virtualWidth"
#define gksPrefVirtualHeight @"virtualHeight"
#define gksPrefProjectionType @"projectionTypeIndex"
#define gksPrefPerspectiveDistance @"perspectiveDepth"
#define gksPrefVisibleSurfaceFlag @"visibleSurfaceFlag"
#define gksPrefBackgroundColor @"backgroundColor"
#define gksPrefFillColor @"fillColor"
#define gksPrefPenColor @"penColor"
#define gksPrefWorldVolumeData @"worldVolume"
#define gksPrefWorldVolumeMinX @"worldVolumeMinX"
#define gksPrefWorldVolumeMaxX @"worldVolumeMaxX"
#define gksPrefWorldVolumeMinY @"worldVolumeMinY"
#define gksPrefWorldVolumeMaxY @"worldVolumeMaxY"
#define gksPrefWorldVolumeMinZ @"worldVolumeMinZ"
#define gksPrefWorldVolumeMaxZ @"worldVolumeMaxZ"

typedef enum ProjectionIndex : NSUInteger {
    kOrthogonal,
    kPerspective,
    kStereo
} ProjectionIndex;

#endif /* GKSConstants_h */
