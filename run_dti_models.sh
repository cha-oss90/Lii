#!/bin/bash
# Usage: Run diffusion models on data
# $1=data_dir $2 = sub-00x $3 = model $4 = preprocessing version

# Create dti processing dir

if [ ! -d "$1/DTI/$2/proc" ]; then
  mkdir "$1DTI/$2/proc" # create dti_gpu dir
  chmod -R 777 "$1DTI/$2/proc" # give permissions
fi

# Prepare dti input directory

if [ ! -d "$1DTI/$2/$4/in" ]; then
  mkdir "$1DTI/$2/$4/in" # create dti_gpu dir
  chmod -R 777 "$1DTI/$2/$4/in" # give permissions
fi

# Copy data so fsl_bedpost_gpu can read it

if [ ! -f "$1DTI/$2/$4/in/data.nii.gz" ]; then
  echo Copy data to in directory for subject $2
  imcp "$1DTI/$2/$4/eddy_corrected.nii.gz" "$1DTI/$2/$4/in/data.nii.gz"
  imcp "$1DTI/$2/$4/my_hifi_b0_brain_mask.nii.gz" "$1DTI/$2/$4/in/nodif_brain_mask.nii.gz"
  cp "$1DTI/$2/raw/bvals" "$1DTI/$2/$4/in/bvals" # No file extension!!! 
  cp "$1DTI/$2/$4/eddy_corrected.eddy_rotated_bvecs" "$1DTI/$2/$4/in/bvecs" # Use eddy corrected version and no file extension
  echo Done!
fi


case $3 in 
"dtifit")
echo Run dtifit for subject $2
dtifit -k $1DTI/$2/$4/in/data -o $1DTI/$2/proc/dtifit_out -m $1DTI/$2/$4/in/nodif_brain_mask -r $1DTI/$2/$4/in/bvecs -b $1DTI/$2/$4/in/bvals
echo Done!
;;
"bedpost")
# Run bedpost
echo Run bedpost on subject $2
/opt/fsl/6.0.5/bin/bedpostx_gpu "$1DTI/$2/$4/in"
echo Done!
;;
"probtrackx")
echo Error in probtrackx: Not yet implemented
#exit 1
echo Run probratckx2 on subject $2
/opt/fsl/6.0.5/bin/probtrackx2_gpu  -s $1DTI/$2/$4/in.bedpostX/merged -m $1DTI/$2/$4/in.bedpostX/nodif_brain_mask -o $1DTI/$2/proc/intest_fdt_matrix2_L --xfm=/project/2422119.01/example_data/MNINonLinear/xfms/standard2acpc_dc --invxfm=/project/2422119.01/example_data/MNINonLinear/xfms/acpc_dc2standard --samples=500 --seed=/project/2422119.01/example_data/MNINonLinear/fsaverage_LR32k/100307.L.midthickness.32k_fs_LR.surf.gii --omatrix2 --target2=/opt/fsl/6.0.3/data/standard/MNI152_T1_2mm_brain -P 10000 --seedref=/opt/fsl/6.0.3/data/standard/MNI152_T1_2mm_brain
echo Done!
;;
"test")
echo "No model executed, files copied for $2"
;;
esac

