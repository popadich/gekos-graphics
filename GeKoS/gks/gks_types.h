//
//  gks_types.h
//  GeKoS
//
//  Created by Alex Popadich on 12/1/21.
//

#ifndef gks_types_h
#define gks_types_h


#if !defined(GKS_INLINE)
    #if defined(__GNUC__)
        #define GKS_INLINE static __inline__ __attribute__((always_inline))
    #elif defined(__MWERKS__) || defined(__cplusplus)
        #define GKS_INLINE static inline
    #elif defined(_MSC_VER)
        #define GKS_INLINE static __inline
    #endif
#endif


#define GKS_MIN_VERTEX_COUNT    7

typedef int GKSint;
typedef double GKSfloat;
typedef char GKSchar;

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
// modifying the GKS_MIN_VERTEX_COUNT constant.
typedef GKSint      GKSpolygon_3[GKS_MIN_VERTEX_COUNT];

typedef GKSvector3d     *GKSvertexArrPtr;       // list of 3D points for each polygon
typedef GKSpolygon_3    *GKSpolygonArrPtr;      // polygon list
typedef GKSpoint_2      *GKSDCArrPtr;
typedef GKSvector3d     *GKSnormalArrPtr;       // normal vector to each polygon


typedef struct
{
    GKSint vertnum;
    GKSint polynum;
    GKSvertexArrPtr  vertices;
    GKSpolygonArrPtr polygons;
    GKSnormalArrPtr  normals;
    GKSvertexArrPtr  transverts;
    GKSDCArrPtr      devcoords;
} GKSobject_3;

typedef enum {
    kCubeKind = 1,
    kSphereKind,
    kPyramidKind,
    kSpaceShuttleKind,
    kHouseKind
} GKSobjectKind;

typedef struct
{
    GKSobject_3 meshObject;    // TODO: this should be a pointer?
    GKSobjectKind kind;
    GKSmatrix_3 modelTransform; // TODO: not necessary
    GKSvector3d scaleVector;
    GKSvector3d rotateVector;
    GKSvector3d translateVector;
    GKScolor fill_color;
    GKScolor line_color;
    
} GKSactor;


GKS_INLINE GKSvector3d GKSMakeVector(GKSfloat x, GKSfloat y, GKSfloat z) {
    GKSvector3d v;
    v.crd.x = x;
    v.crd.y = y;
    v.crd.z = z;
    v.crd.w = 1.0;
    return v;
}

#endif /* gks_types_h */
