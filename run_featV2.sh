#!bin/bash

#1 = datadir $2=subject $3 = Task $4 = model
# Adjust fsf file for new subjects and run feat

# Make designs folder in task directory
if [ ! -d $1/func/$2/$3/designs/ ]; then
  mkdir -p $1func/$2/$3/{designs,run_feats}
  # run_feats now contains the change fsf bash script
  chmod -R 777  $1func/$2/$3/
fi

# Make model folder
if [ ! -d $1/func/$2/$3/$4/ ]; then
  mkdir -p $1func/$2/$3/$4
  # run_feats now contains the change fsf bash script
  chmod -R 777  $1func/$2/$3/
fi

#delete potential older/unfinished versions
if [[ $4 != 'pre_processing' ]]; then
if [ -d $1/func/$2/$3/$4/pre_processing.feat ]; then
  rm -r $1/func/$2/$3/$4/pre_processing.feat
fi
fi

# Copy fresh preprocessing directory (remember, we use lower level input feats now)
cp -r $1func/$2/$3/pre_processing.feat $1func/$2/$3/$4/
# Copy design.fsf file
cp $1func/sub-001/$3/$4/design.fsf $1func/$2/$3/$4/design.fsf

# Grant permission
chmod -R 777  $1func/$2/$3/


 echo "sed -i -e 's/sub-001/$2/' $1func/$2/$3/$4/design.fsf
 sed -i -e 's/_sub-001/_$2/' $1func/$2/$3/$4/design.fsf" > "$1func/$2/$3/run_feats/$4.sh" # One liner until here from last echo

# Run feat
bash $1func/$2/$3/run_feats/$4.sh
 
feat $1func/$2/$3/$4/design.fsf