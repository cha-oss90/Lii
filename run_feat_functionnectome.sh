#!bin/bash

#1 = datadir $2=subject $3 = Task $4 = model
# Adjust fsf file for new subjects and run feat

# Make sub directory
if [ ! -d $1functionnectome/$2/ ]; then
  mkdir -p $1functionnectome/$2/
  # run_feats now contains the change fsf bash script
  chmod -R 777  $1functionnectome/$2/
fi
# Make designs folder in task directory
if [ ! -d $1functionnectome/$2/$3/designs/ ]; then
  mkdir -p $1/functionnectome/$2/$3/{designs,run_feats}
  # run_feats now contains the change fsf bash script
  chmod -R 777  $1functionnectome/$2/$3/
fi

# Make model folder
if [ ! -d $1/functionnectome/$2/$3/$4/ ]; then
  mkdir -p $1functionnectome/$2/$3/$4
  # run_feats now contains the change fsf bash script
  chmod -R 777  $1functionnectome/$2/$3/
fi


# Copy fresh preprocessing directory (remember, we use lower level input feats now)
if [ ! -f $1functionnectome/$2/$3/$4/$2_functionnectome.nii.gz ]; then
cp $1functionnectome/$2\_functionnectome.nii.gz $1functionnectome/$2/$3/
# Copy design.fsf file
fi
if [ ! -f $1muge/functionnectome/$2/$3/$4/$2_functionnectome.nii.gz ]; then
cp $1functionnectome/sub-002/$3/$4/design.fsf $1functionnectome/$2/$3/$4/design.fsf
fi
# Grant permission
chmod -R 777  $1functionnectome/$2/$3/


# adjust subject number
# No need to adjust volumes, they are all the same! 

# delete possible earlier versions of the same model

#rm -r $1muge/functionnectome/$2/$3/$4*.feat

# NOTE: We use sub-001 as an example Subject here
 echo "sed -i -e 's/sub-002/$2/' $1muge/functionnectome/$2/$3/$4/design.fsf
 sed -i -e 's/_sub-002/_$2/' $1muge/functionnectome/$2/$3/$4/design.fsf
 sed -i -e 's/sub-002_functionnectome/$2_functionnectome/' $1muge/functionnectome/$2/$3/$4/design.fsf" > "$1muge/functionnectome/$2/$3/run_feats/$4.sh" # One liner until here from last echo

# Run feat
bash $1muge/functionnectome/$2/$3/run_feats/$4.sh
 #echo "feat $d/S${s}/feat/${model}/design.fsf" > $d/S${s}/feat/run_feats/${model}.sh
 #echo "Start Job for Subject $s"
feat $1muge/functionnectome/$2/$3/$4/design.fsf
