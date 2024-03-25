#!/bin/bash

# Create brain mask and apply to structural scans and prepare field map
#$1 = data_dir $2=modality $3 = subject


# Which structural images do we have?
MP2_images=("inv1" "inv2" "T1w" "T1map" "unit1")
T1_images=("T1w" "rec-filtered_T1w")

# create subfolders for the 2 modalities
case $2 in 
"struct")
if [ ! -d $1$2/$3/MP2RAGE_bet/ ]; then
  echo Make MP2RAGE directory...
  # Make MP2RAGE subfolders
  mkdir $1$2/$3/MP2RAGE_bet/
  chmod -R 777 $1$2/$3/MP2RAGE_bet/
  echo Done!
fi

if [ ! -d $1$2/$3/T1_bet/ ]; then
  # Make MP2RAGE subfolders
  echo Make T1 directory...
  mkdir $1$2/$3/T1_bet/
  chmod -R 777 $1$2/$3/T1_bet/
  echo Done!
fi

# bet MP2RAGE (works great with inv2)
echo Betting MP2RAGE inv2... 
bet $1$2/$3/MP2RAGE_inv2.nii.gz $1$2/$3/MP2RAGE_bet/inv2_brain.nii.gz -m -R
MP2RAGE_mask=$(find $1$2/$3/MP2RAGE_bet/ -name inv2*mask*.nii.gz)
echo MP2RAGE mask found in $MP2RAGE_mask
echo Done!

echo Apply inv2 mask to other MP2RAGE scans...
for image in "${MP2_images[@]}"; do 
echo Apply mask for $image
echo $1$2/$3/MP2RAGE_$image.nii.gz
echo $1$2/$3/MP2RAGE_$image\_brain.nii.gz
  fslmaths $1$2/$3/MP2RAGE_$image.nii.gz -mul $MP2RAGE_mask "$1$2/$3/MP2RAGE_bet/$image"_brain.nii.gz
done
echo Done!


#bet T1 
echo Betting rec filtered T1...
#bet $1$2/$3/rec-filtered_T1w.nii.gz $1$2/$3/T1_bet/rec-filtered_T1w_brain.nii.gz -m -f 0.45 -g -0.1 -R
# Try freesurfer's tool 
mri_synthstrip -i $1$2/$3/rec-filtered_T1w.nii.gz -o $1$2/$3/T1_bet/rec-filtered_T1w_brain.nii.gz -m $1$2/$3/T1_bet/rec-filtered_T1w_brain_mask.nii.gz
# Try freesurfer's tool 
T1_mask=$(find $1$2/$3/T1_bet/ -name rec-filtered*mask*.nii.gz)
echo T1_mask found in $T1_mask
echo Done!

echo Applying rec-filtered_T1 mask to other T1 scans...
for image in "${T1_images[@]}"; do 
echo Masking $image in $1$2/$3/T1_bet/$image\_brain.nii.gz
echo $1$2/$3/$image.nii.gz
echo $1$2/$3/T1_bet/$image\_brain.nii.gz
  fslmaths $1$2/$3/$image.nii.gz -mul $T1_mask "$1$2/$3/T1_bet/$image"_brain.nii.gz
done
echo Done!
echo Copy rec-filtered and rec-filtered maskto T1 for Feat naming conventionlater
cp $1$2/$3/rec-filtered_T1w.nii.gz $1$2/$3/T1_bet/T1.nii.gz
cp $1$2/$3/T1_bet/rec-filtered_T1w_brain.nii.gz $1$2/$3/T1_bet/T1_brain.nii.gz
cp $1$2/$3/T1_bet/rec-filtered_T1w_brain_mask.nii.gz $1$2/$3/T1_bet/T1_brain_mask.nii.gz
;;
"fmap")
runs=("run-1" "run-2")
run1_tasks=("RSN" "PictureNaming" "LexicalDecision" "NarrativeHoela")
run2_tasks=("SentenceComprehension" "SentenceProduction" "NarrativeHoning")

printf "%s " ${run1_tasks[@]} > $1$2/$3/run_1_tasks.txt
printf "%s " ${run2_tasks[@]} > $1$2/$3/run_2_tasks.txt

for run in "${runs[@]}"; do
  fsl_prepare_fieldmap  SIEMENS $1$2/$3/$run"_phasediff.nii.gz" $1$2/$3/$run"_magnitude1.nii.gz" $1$2/$3/fmap_$run.nii.gz 2.46 
done
;;
*)
echo Not yet implemented!
;;
esac