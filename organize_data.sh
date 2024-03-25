#!/bin/bash

# Usage: Organize data in different space from one big raw folder in the main dir 
#  $1= data_dir $2 = sub-xxx $3 = modality
case $3 in 

  "dti")
  
  if [ ! -d $1DTI/ ]; then
  printf "Make DTI directory in data"
    mkdir $1DTI/
    printf "Done!"
  fi
 if [ ! -d $1DTI/$2/ ]; then
 printf "Make subject subdirectory in data/DTI/"
    mkdir -p $1DTI/$2/{raw,preproc}
    chmod -R 777 $1DTI/$2/
    printf "Done!"
  fi  
  
  echo  -e Copy and rename files... 
  cp -r $1raw/$2/ses-mri01/dwi/* $1/DTI/$2/raw/ # Copy dwi data to its own space directory
  # Copy files to sensible names
  cp $1DTI/$2/raw/*acq-diffusion*dwi.nii.gz 	$1DTI/$2/raw/dwi.nii.gz
  cp $1DTI/$2/raw/*acq-invdiffusion*dwi.nii.gz 	$1DTI/$2/raw/inv_dwi.nii.gz
  cp $1DTI/$2/raw/*acq-diffusion*.bval 		$1DTI/$2/raw/bvals.txt
  cp $1DTI/$2/raw/*acq-diffusion*.bvec 		$1DTI/$2/raw/bvecs.txt
  cp $1DTI/$2/raw/*acq-invdiffusion*.bval 	$1DTI/$2/raw/inv_bvals.txt
  cp $1DTI/$2/raw/*acq-invdiffusion*.bvec 	$1DTI/$2/raw/inv_bvecs.txt
  echo -e Done!
  # Remove copied files
  
  echo -e Remove old files...
  rm  $1DTI/$2/raw/*acq-diffusion*dwi.nii.gz	
  rm  $1DTI/$2/raw/*acq-invdiffusion*dwi.nii.gz
  rm  $1DTI/$2/raw/*acq-diffusion*.bvec
  rm  $1DTI/$2/raw/*acq-diffusion*.bval
  rm  $1DTI/$2/raw/*acq-invdiffusion*.bvec
  rm  $1DTI/$2/raw/*acq-invdiffusion*.bval
  echo -e Done!
  # Rename Rest
  echo -e Rename leftover files... 
  mv $1DTI/$2/raw/*acq-diffusion*dwi.json $1DTI/$2/raw/dwi_params.json
  mv $1DTI/$2/raw/*acq-invdiffusion*dwi.json $1DTI/$2/raw/inv_dwi_params.json
  mv $1DTI/$2/raw/*acq-diffusion*sbref.json $1DTI/$2/raw/dwi_sbref_params.json
  mv $1DTI/$2/raw/*acq-invdiffusion*sbref.json $1DTI/$2/raw/inv_dwi_sbref_params.json  
  mv $1DTI/$2/raw/*acq-diffusion*sbref.nii.gz $1DTI/$2/raw/dwi_sbref.nii.gz
  mv $1DTI/$2/raw/*acq-invdiffusion*sbref.nii.gz $1DTI/$2/raw/inv_dwi_sbref.nii.gz  
  echo Done!
  # Clean up
  echo -e Clean up...
  rm -r $1/raw/$2/ses-mri01/dwi/
  echo -e Done!
  ;;
  *)
    printf "Error organizing data for %s: Not yet implemented" "$3"
  ;;
esac
echo -e $2 done!