//
//  gks_types.h
//  GeKoS
//
//  Created by Alex Popadich on 12/1/21.
//

#pragma once

#if !defined(GKS_INLINE)
    #if defined(__GNUC__)
        #define GKS_INLINE static __inline__ __attribute__((always_inline))
    #elif defined(__MWERKS__) || defined(__cplusplus)
        #define GKS_INLINE static inline
    #elif defined(_MSC_VER)
        #define GKS_INLINE static __inline
    #endif
#endif


#define GKS_POLY_VERTEX_MAX     99
#define GKS_ERROR_MSG_MAX       256
#define DEG_TO_RAD              0.01745329252


// Error handling
typedef enum {
    GKS_ERROR_NONE = 0,
    GKS_ERROR_INVALID_FORMAT,
    GKS_ERROR_MISSING_HEADER,
    GKS_ERROR_INVALID_COUNTS,
    GKS_ERROR_PARSE_VERTEX,
    GKS_ERROR_PARSE_POLYGON,
    GKS_ERROR_MEMORY_ALLOCATION,
    GKS_ERROR_FILE_EMPTY,
    GKS_ERROR_INVALID_DATA
} GKSerrorCode;

typedef struct {
    GKSerrorCode code;
    char message[GKS_ERROR_MSG_MAX];
} GKSerror;

// A simple structure to hold your parsed file data
typedef struct {
    double x, y, w, h;
} RectData;

typedef int GKSint;
typedef double GKSfloat;
typedef char GKSchar;
typedef int GKSbool;

typedef struct
{
    GKSfloat x;
    GKSfloat y;
} GKSpoint_2;

typedef struct
{
    GKSfloat xmin;
    GKSfloat xmax;
    GKSfloat ymin;
    GKSfloat ymax;
} GKSlimits_2;

typedef GKSfloat GKSmatrix_2[3][3];

typedef struct {
    GKSfloat x;
    GKSfloat y;
    GKSfloat z;
    GKSfloat w;
} GKSpoint_3;
typedef GKSfloat *GKSpoint_3_Ptr;

typedef struct
{
    GKSfloat xmin;
    GKSfloat xmax;
    GKSfloat ymin;
    GKSfloat ymax;
    GKSfloat zmin;
    GKSfloat zmax;
} GKSlimits_3;

typedef GKSfloat GKSmatrix_3[4][4];
typedef GKSmatrix_3 *GKSmatrixPtr;
typedef GKSfloat GKSvector_3[4];


// Union of Gpt_3 points and Vector_4 arrays
union GKSvector3d {
    GKSpoint_3 crd;
    GKSvector_3 arr;
};
typedef union GKSvector3d GKSvector3d;
typedef GKSvector3d *GKSvector3dPtr;
/*
** A union works like so...
**
  typedef union
  { char *a[2];
      struct
      { char *string1;
        char *string2;
      } s;
  } TWO_WORDS;

  TWO_WORDS t;

  t.a[0] = ...;
  t.a[1] = ...;
  t.s.string1 = ...;
  t.s.string2 = ...;
*/

typedef struct {
    GKSfloat red;
    GKSfloat green;
    GKSfloat blue;
    GKSfloat alpha;
} GKScolor;


// Polygon has a vertex count followed
// by count vertex indexes (usually 3 or 4)
// but potentially more. Make room by
// modifying the MAX constant.
typedef GKSint      GKSpolygon_3[GKS_POLY_VERTEX_MAX];
typedef GKSint      GKSedge_3[2];
typedef GKSvector3d     *GKSvertexArrPtr;       // list of 3D points for each polygon
typedef GKSint          *GKSindexArrPtr;
typedef GKSedge_3       *GKSedgeArrPtr;
typedef GKSpoint_2      *GKSDCArrPtr;
typedef GKSvector3d     *GKSnormalArrPtr;       // normal vector to each polygon


typedef struct
{
    GKSint vertnum;
    GKSint polynum;
    GKSint polystoresize;
    GKSint edgenum;
    GKSlimits_3 volume;
    GKSvertexArrPtr vertices;
    GKSindexArrPtr polygons;
    GKSedgeArrPtr edges;
} GKSmesh_3;

typedef enum {
    kCubeKind = 1,
    kSphereKind,
    kPyramidKind,
    kConeKind,
    kHouseKind
} GKSkind;

typedef struct
{
    GKSint object_id;
    GKSbool hidden;
    GKSfloat priority;
    GKSkind kind;
    GKSmesh_3 mesh_object;    // TODO: this should be a pointer?
    GKSmatrix_3 model_transform;
    GKSvector3d scale_vector;
    GKSvector3d rotate_vector;
    GKSvector3d translate_vector;
    GKScolor fill_color;
    GKScolor line_color;
    
    GKSnormalArrPtr  normals;
    GKSDCArrPtr      dev_coords;

} GKSactor;


typedef struct {
    GKSlimits_3 volume_world;
    GKSlimits_3 volume_view;
    GKSlimits_2 port_rect;
    GKSmatrix_3 view_matrix;
    GKSmatrix_3 proj_matrix;
    GKSfloat focus;
    GKSfloat near;
    GKSfloat far;
    GKSint projection_type;
    
    GKSfloat wrld_xscale;
    GKSfloat wrld_xcoord;
    GKSfloat wrld_yscale;
    GKSfloat wrld_ycoord;
    GKSfloat wrld_zscale;
    GKSfloat wrld_zcoord;
    
    GKSfloat dev_xscale;
    GKSfloat dev_xcoord;
    GKSfloat dev_yscale;
    GKSfloat dev_ycoord;
    
    GKSbool cull_flag;
} GKScontext3D;
typedef GKScontext3D *GKScontext3DPtr;



GKS_INLINE GKSvector3d GKSMakeVector(GKSfloat x, GKSfloat y, GKSfloat z) {
    GKSvector3d v;
    v.crd.x = x;
    v.crd.y = y;
    v.crd.z = z;
    v.crd.w = 1.0;
    return v;
}

GKS_INLINE GKSlimits_3 GKSMakeVolume(GKSvector3d minPoint, GKSvector3d maxPoint) {
    GKSlimits_3 l;
    l.xmin = minPoint.crd.x;
    l.ymin = minPoint.crd.y;
    l.zmin = minPoint.crd.z;
    l.xmax = maxPoint.crd.x;
    l.ymax = maxPoint.crd.y;
    l.zmax = maxPoint.crd.z;
    return l;
}

