//
//  gks_types.h
//  GeKoS
//
//  Created by Alex Popadich on 12/1/21.
//

#ifndef gks_types_h
#define gks_types_h

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
    GKSvertexArrPtr  transverts;      // transformed points
    GKSDCArrPtr      devcoords;
} GKSobject_3;


#endif /* gks_types_h */
