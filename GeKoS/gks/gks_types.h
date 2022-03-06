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
} Gpt_2;

typedef struct
{
    GKSfloat xmin;
    GKSfloat xmax;
    GKSfloat ymin;
    GKSfloat ymax;
} Glim_2;

typedef GKSfloat Matrix_2[3][3];

typedef struct {
    GKSfloat x;
    GKSfloat y;
    GKSfloat z;
    GKSfloat w;
} Gpt_3;
typedef GKSfloat *Gpt_3_Ptr;

typedef struct
{
    GKSfloat xmin;
    GKSfloat xmax;
    GKSfloat ymin;
    GKSfloat ymax;
    GKSfloat zmin;
    GKSfloat zmax;
} Glim_3;

typedef GKSfloat Matrix_3[4][4];
typedef GKSfloat Vector_3[4];

// Union of Gpt_3 points and Vector_4 arrays
union vector3d {
    Gpt_3 vecpos;
    Vector_3 vec_arr;
};
typedef union vector3d GVector;
typedef GVector *GVectorPtr;
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
} Gcolor;


// Polygon has a vertex count followed
// by count vertex indexes (usually 3 or 4)
// but potentially more. Make room by
// modifying the GKS_MIN_VERTEX_COUNT constant.
typedef GKSint      Gpoly_3[GKS_MIN_VERTEX_COUNT];

typedef Gpt_3       *VertexArrayPtr;       // list of 3D points for each polygon
typedef Gpoly_3     *PolygonArrayPtr;      // polygon list


typedef struct
{
    GKSint vertnum;
    GKSint polynum;
    VertexArrayPtr vertices;
    PolygonArrayPtr polygons;
} Object_3;


#endif /* gks_types_h */
