#!/bin/bash -i
# Run one volume to surface conversion
$script_dir=["INSERT SCRIPT DIRECTORY"]
freesurfer_main="$script_dir/Pipelines-OxfordStructural/Examples/Scripts/RunStructuralBatchMentat.sh"

# Load modules and source freesurfer environment
#echo "Load modules and source environment \n"
#module unload freesurfer # Unload standart freesurfer version
#module load freesurfer/5.3.0-hcp # load hcp compatible freesurfer version
#source /project/2422119.01/scripts/Pipelines-OxfordStructural/Examples/Scripts/SetUpHCPPipeline.sh # source environment file
echo "First var is $1"
#echo "Done! \n"
# Run Freesurfer pipeline bits
echo "Run Freesurfer \n"
echo "Start RENAME \n"
bash $freesurfer_main $1 RENAME
echo "Finished RENAME! \n"
echo "Start PRE \n"
bash $freesurfer_main $1 PRE
echo "Finished PRE \n"
echo "Start FREE \n"
bash $freesurfer_main $1 FREE
echo "Finished FREE \n"
echo "Start POST \n"
bash $freesurfer_main $1 POST
echo "Finished POST \n"
echo "Start CLEANUP \n"
bash $freesurfer_main $1 CLEAN
echo "Finished CLEANUP \n"
echo "Done with Freesurfer Pipeline for subject $1 \n"

