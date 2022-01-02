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

void gks_trans_init_3(void);

Gint gks_trans_get_curr_view_idx(void);
void gks_trans_set_curr_view_idx(Gint view_num);

// Creates and sets view_num index as the current view index
void gks_trans_create_transform_at_idx(Gint view_num, Gfloat r_mini, Gfloat r_maxi, Gfloat s_mini, Gfloat s_maxi, Glim_3 world_volume_3);

Glim_3 gks_trans_get_transform_at_idx(Gint view_num, Gint setup);

Glim_2 gks_trans_get_device_viewport(void);

void gks_trans_wc_to_ndc_3 (Gpt_3 *wc_pt, Gpt_3 *ndc_pt);
void gks_trans_ndc_3_to_dc_2 (Gpt_3 *ndc_pt, Gint *r, Gint *s);

#endif /* gks_3d_transforms_h */
