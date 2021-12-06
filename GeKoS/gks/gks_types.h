//
//  gks_types.h
//  gks-graphics
//
//  Created by Alex Popadich on 12/1/21.
//

#ifndef gks_types_h
#define gks_types_h

#define GKS_MIN_VERTEX_COUNT    7

typedef int Gint;
typedef double Gfloat;
typedef char Gchar;

/*  2-D  */
typedef struct
{
    Gfloat x;
    Gfloat y;
} Gpt_2;

typedef struct
{
    Gfloat xmin;
    Gfloat xmax;
    Gfloat ymin;
    Gfloat ymax;
} Glim_2;

typedef Gfloat Matrix_3[3][3];


/*  3-D  */
typedef enum {
    kCubeKind = 1,
    kSphereKind,
    kPyramidKind,
    kSpaceShuttleKind,
    kHouseKind
} ObjectKind;


typedef enum {
    kOrthogonalProjection = 0,
    kPerspectiveProjection,
    kAxonometricProjection
} ProjectionType;

typedef struct {
    Gfloat x;
    Gfloat y;
    Gfloat z;
    Gfloat w;
} Gpt_3;
typedef Gfloat *Gpt_3_Ptr;

typedef struct
{
    Gfloat xmin;
    Gfloat xmax;
    Gfloat ymin;
    Gfloat ymax;
    Gfloat zmin;
    Gfloat zmax;
} Glim_3;

typedef Gfloat Matrix_4[4][4];
typedef Gfloat Vector_4[4];

// Union of Gpt_3 points and Vector_4 arrays
union vector3d {
    Gpt_3 vecpos;
    Vector_4 vec_arr;
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
    Gfloat red;
    Gfloat green;
    Gfloat blue;
    Gfloat alpha;
} Gcolor;


// Polygon has a vertex count followed
// by count vertex indexes (usually 3 or 4)
// but potentially more. Make room by
// modifying the GKS_MIN_VERTEX_COUNT constant.
typedef Gint        Gpoly_3[GKS_MIN_VERTEX_COUNT];

typedef Gpt_3       *VertexArrayPtr;       // list of 3D points for each polygon
typedef Gpoly_3     *PolygonArrayPtr;      // polygon list


typedef struct
{
    Gint vertnum;
    Gint polynum;
    VertexArrayPtr vertices;
    PolygonArrayPtr polygons;
} Object_3;


#endif /* gks_types_h */
