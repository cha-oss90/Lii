#!/bin/bash
# This script makes white/gray matter and csf segmentations from a betted T1 with fsl Fast 
# Copyright: Marius Braunsdorf Feb. 06
# arguments: 
#$1=data directory: [projectnumber/data/]
#$2=Subject in format: sub-00X 
#$3 = 'Task' here 'segmentation'


# Make segmentation directory in /project/X/data/struct/segmentation/

if [ ! -d $1struct/$2/$3 ]; then
echo "Make $3 directory for subject $2"
mkdir "$1struct/$2/$3"
chmod -R 777 $1struct/$2/
echo "Done! \n"
fi

if [ ! -f $1struct/$2/$3/T1_seg_pve_0.nii.gz ]; then
echo Do segmentation... \n
fast -t 1 -o "$1struct/$2/$3/T1_seg" -n 3 -b -B -g "$1struct/$2/T1_bet/T1_brain"

echo Done! \n
fi
# Rename files to GM WM CSF

# This here seems to weirdly work
#0=csf
#1=gm
#2=wm
# Rename partial volume estimates (pve)
find "$1struct/$2/$3/" -name '*pve_0*' -exec bash -c 'mv $0 ${0/T1_seg_pve_0/csf_pve}' {} \;
find "$1struct/$2/$3/" -name '*pve_1*' -exec bash -c 'mv $0 ${0/T1_seg_pve_1/gm_pve}' {} \;
find "$1struct/$2/$3/" -name '*pve_2*' -exec bash -c 'mv $0 ${0/T1_seg_pve_2/wm_pve}' {} \;

# Rename binarized masks:
find "$1struct/$2/$3/" -name '*seg_0*' -exec bash -c 'mv $0 ${0/T1_seg_seg_0/csf_bin}' {} \;
find "$1struct/$2/$3/" -name '*seg_1*' -exec bash -c 'mv $0 ${0/T1_seg_seg_1/gm_bin}' {} \;
find "$1struct/$2/$3/" -name '*seg_2*' -exec bash -c 'mv $0 ${0/T1_seg_seg_2/wm_bin}' {} \;

