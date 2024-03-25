#!/bin/bash

#1 = datadir $2=subject $3 = Task $4 = model
# Adjust fsf file for new subjects and run preprocessing feat for resting state data
env_folder=["INSERT PYTHON ENVIRONMENT FOLDER"]
echo "Run preproc script with model $4"
if [[ "$4" != "aroma" ]] ; then #### This part works!!! :o
echo "Wrong Test if"
else
echo "Could enter aroma if..."
fi

# To do! 
echo "Entered aroma if... do aroma for $2"
module load anaconda2
source activate "$env_folder/envs/aroma"
conda info
# COpy preproc folders
# Make folder for aroma
if [ ! -d $1func/$2/$3/pre_processing/aroma/ ]; then
echo "Make aroma folder for sub $2"
mkdir $1func/$2/$3/pre_processing/aroma
chmod -R 777 $1func/$2/$3
echo Done!
fi

# Copy preprocessing feat to aroma dir
if [ ! -d $1func/$2/$3/pre_processing/aroma/feat.feat/ ]; then
  echo "Copying feat preprocessing dir to aroma dir for sub $2"
  cp -r $1func/$2/$3/pre_processing/feat.feat $1func/$2/$3/pre_processing/aroma/
  chmod -R 777 $1func/$2/$3
  echo Done
fi

# Copy preprocessing feat to aroma dir
if [ ! -d $1func/$2/$3/pre_processing/aroma/feat_sb_ref.feat/ ]; then
  echo "Copying feat_sb_ref preprocessing dir to aroma dir for sub $2"
  cp -r $1func/$2/$3/pre_processing/feat_sb_ref.feat $1func/$2/$3/pre_processing/aroma/
  chmod -R 777 $1func/$2/$3
  echo Done
fi

# Do aroma

python "$env_folder/envs/ind_diff/ICA-AROMA-master/ICA_AROMA.py" -den 'both' -f "$1func/$2/$3/pre_processing/aroma/feat.feat/" -o "$1func/$2/RSN/pre_processing/aroma/feat.feat/ICA_AROMA/" 
python "$env_folder/envs/ind_diff/ICA-AROMA-master/ICA_AROMA.py" -den 'both' -f "$1func/$2/$3/pre_processing/aroma/feat_sb_ref.feat" -o "$1func/$2/RSN/pre_processing/aroma/feat_sb_ref.feat/ICA_AROMA/"