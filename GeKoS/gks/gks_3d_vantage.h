//
//  gks_3d_vantage.h
//  GeKoS
//
//  Created by Alex Popadich on 12/8/21.
//

#ifndef gks_3d_vantage_h
#define gks_3d_vantage_h

#include "gks_types.h"

#define GKS_MAX_VIEW_TRANSFORMS 10

void gks_vantage_init(void);

GKSint gks_vantage_get_current_view(void);
void gks_vantage_set_current_view(GKSint view_num);




#endif /* gks_3d_vantage_h */
