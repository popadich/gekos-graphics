//
//  gks_3d_context.h
//  GeKoS
//
//  Created by Alex Popadich on 12/8/21.
//

#ifndef gks_3d_context_h
#define gks_3d_context_h

#include "gks_types.h"

#define GKS_MAX_CONTEXT_PTS 10
#define GKS_VOLUME_TYPES 2
#define GKS_TRANSFORM_TYPES 2


void gks_context_init(void);
void gks_context_set_defaults(void);

GKSint gks_context_get_current_view(void);
void gks_context_set_current_view(GKSint view_num);




#endif /* gks_3d_context_h */
