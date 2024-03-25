#!/bin/bash/

# Renames output of segmentation to reasonable names

find "$1struct/$2/$3/" -name '*pve_0*' -exec bash -c 'mv $0 ${0/T1_seg_pve_0/csf_pve}' {} \;
find "$1struct/$2/$3/" -name '*pve_1*' -exec bash -c 'mv $0 ${0/T1_seg_pve_1/gm_pve}' {} \;
find "$1struct/$2/$3/" -name '*pve_2*' -exec bash -c 'mv $0 ${0/T1_seg_pve_2/wm_pve}' {} \;

# Rename binarized masks:
find "$1struct/$2/$3/" -name '*seg_0*' -exec bash -c 'mv $0 ${0/T1_seg_seg_0/csf_bin}' {} \;
find "$1struct/$2/$3/" -name '*seg_1*' -exec bash -c 'mv $0 ${0/T1_seg_seg_1/gm_bin}' {} \;
find "$1struct/$2/$3/" -name '*seg_2*' -exec bash -c 'mv $0 ${0/T1_seg_seg_2/wm_bin}' {} \;