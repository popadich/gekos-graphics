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
#define gksPrefNearPlaneDistance @"nearPlaneDistance"
#define gksPrefFarPlaneDistance @"farPlaneDistance"
#define gksPrefCameraLocX @"cameraLocationX"
#define gksPrefCameraLocY @"cameraLocationY"
#define gksPrefCameraLocZ @"cameraLocationZ"
#define gksPrefVisibleSurfaceFlag @"visibleSurfaceFlag"
#define gksPrefFrustumCullFlag @"frustumCullFlag"
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
#define gksPlayingFlag @"playingFlag"

typedef enum ProjectionIndex : NSUInteger {
    kOrthogonal,
    kPerspectiveSimple,
    kPerspective,
    kAlternate
} ProjectionIndex;

#endif /* GKSConstants_h */
