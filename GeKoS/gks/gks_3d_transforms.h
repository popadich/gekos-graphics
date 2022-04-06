//
//  gks_3d_transforms.h
//  GeKoS
//
//  Created by Alex Popadich on 12/8/21.
//

#ifndef gks_3d_transforms_h
#define gks_3d_transforms_h

#include "gks_types.h"

#define GKS_MAX_VIEW_TRANSFORMS 10

void gks_trans_init(void);

GKSint gks_trans_get_curr_view_idx(void);
void gks_trans_set_curr_view_idx(GKSint view_num);




#endif /* gks_3d_transforms_h */
