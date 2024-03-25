#!/bin/bash

# Usage: First question: type the task you want to do, Surface conversion, perform probabilistic tractography, preprocess diffusion data
# Version history
# 14-12-2022 | Created
# Copyright Marius Braunsdorf
script_dir=["INSERT SCRIPT FOLDER LOCATION"]
data_dir=["INSERT DATA FOLDER LOCATION"]
sub_list="$data_dir/subject_list.txt"
surface_conversion_script="$script_dir/transform_surface_complete.sh"
run_dti_model_script="$script_dir/run_dti_models.sh"
run_dti_preproc_script="$script_dir/run_dti_preproc_script.sh"
run_dti_preproc_alt_script="$script_dir/run_dti_preproc_alt_script.sh"
run_dti_preproc_synth_script="$script_dir/run_dti_preproc_synth.sh"
run_tractography_script="$script_dir/run_dti_models.sh"
clean_up_script="$script_dir/clean_up.sh"
delete_folder_script="$script_dir/delete_folder.sh"
organize_data_script="$script_dir/organize_data.sh"
organize_data_script_alt="$script_dir/organize_data_preproc_alt.sh"
copy_anat_files_script="$script_dir/copy_anat_files.sh"
copy_files_script="$script_dir/copy_files.sh"
quality_control_script="$script_dir/quality_control_script.sh"
combine_echoes_script="$script_dir/combine_echoes.sh"
prepare_scans_script="$script_dir/prepare_scans.sh"
run_feat_script="$script_dir/run_feat.sh" # Works for pre_processing
run_featV2_script="$script_dir/run_featV2.sh" # Mimicks SEC structure
run_rsn_preproc_script="$script_dir/run_rsn_preproc_v2.sh"
T1_seg_script="$script_dir/T1_segmentation.sh"
functionnectome_script="$script_dir/run_feat_functionnectome.sh"
run_xtract_script="$script_dir/run_xtract.sh"
run_xtract_parallel_script="$script_dir/run_xtract_parallel.sh"
script_dir="$script_dir/"


echo -n  "What do you want to do? (Surface|dti|dti_orga|dti_preproc|Tractography|Clean|del|copy_anat|copy_files|combine_echoes|Test|pre_qc|prepare_scans|run_feat|rsn_preproc|T1_seg|delete_folder|xtract)"
read analysis
echo -n "Which subjects do you want to analyse? (start end | start 'rest' | 'all')" # start and end (exclusive) | start subject until end of list | all subjects
read start end #From to which number (we don't start from 0 but from 1!)
case $analysis in
  "Tractography")
  echo -n "What kind of tractography do you want to do? (test|dtifit|bedpost|probtrackx)"
  read model
  ;;
  esac

readarray subjects < $sub_list
if [[ -z $end && $start != all ]]; then 
  echo "End empty, so only ${subjects[$start]} analyzed"
  start=$((start-1))
  end=$((start+1))
  
elif [ $start = all ]; then
  echo "Analyse all subjects"
  end=${#subjects[@]}
  #end=$end+1
  start=0
elif [[ $start != all && $end = rest ]]; then
  start=$((start-1))
  end=${#subjects[@]}
  #end=$end+1
elif [[ $start =~ ^[0-9]+$ && $end =~ ^[0-9]+$ ]]; then
start=$((start-1))
#end=$((start+1))
echo Running subject in range ${subjects[$start]} to ${subjects[$end]}
fi

### Load modules + setup environment
case $analysis in 
    "Surface")
      module unload freesurfer # Unload standart freesurfer version
      module load freesurfer/5.3.0-hcp # load hcp compatible freesurfer version
      source $script_dir/Pipelines-OxfordStructural/Examples/Scripts/SetUpHCPPipeline.sh # source environment file
      ;;
    "dti")
      module unload cuda
      module load cuda/9.1
      echo -n "What kind of tractography do you want to do? (test|dtifit|bedpost|probtrackx)"
      read model
      echo -n  "Which preprocessing version do you want to use? ('preproc'|'preproc_alt'|'preproc_synth')"
      read preproc_version
      ;;
      "dti_preproc")
      echo Load mrtrix and cuda for dti preprocessing
      module unload mrtrix/3.0
      #module unload cuda/9.1
      module unload cuda
      module load mrtrix/3.0
      module load cuda/9.1
      echo Done!
      ;;
    "Tractography")
      module unload cuda
      module load cuda/9.1
    ;;
    "copy_files")
    echo -n  "Which modality do you want to copy? ('func'|'fmap'|'struct')"
    read mod #modality to copy
    ;;
    "prepare_scans")
      echo -n  "Which modality do you want to prepare? ('struct'|'fmap')"
      read mod #modality to copy
    ;;
    "combine_echoes")
    echo -n  "Which task do you want to combine? ('PictureNaming'|'SentenceComprehension'|'SentenceProduction'|'NarrativesHoela'|'NarrativesHonin'|'LexicalDecision')"
    read task #modality to copy
    module load anaconda3/2021.05
    ;;
    "run_feat")
    echo -n  "Which task do you want to analyse? ('PictureNaming'|'SentenceComprehension'|'SentenceProduction'|'NarrativesHoela'|'NarrativesHonin'|'LexicalDecision')"
    read task #task to analyse/preprocess
    echo -n  "Which model do you want to run? ('pre_processing'|'model1')"
    read model # model to run
    ;;
    "rsn_preproc")
    echo -n  "How do you want to preprocess? ('feat'|'feat_sb_ref'|'aroma')"
    read preproc_version # which version to run (fsl standart, or use single band ref for mb data (recommended by glasser))
    task=RSN
    if [[ "$preproc_version" == "aroma" ]]; then
    run_rsn_preproc_script="$script_dir/run_rsn_preproc_aroma.sh"
      echo "Doing ICA-AROMA, loading python"
      #module load python/2.7.8
    #module load anaconda3/2021.05
    module unload anaconda3
    module unload anaconda2
    module load anaconda2
    #source activate "/project/2422119.01/envs/aroma"
    elif [[ "$preproc_version" != "aroma" ]]; then
      echo "Doing $preproc_version rsn preprocessing"
      run_rsn_preproc_script="$SCRIPT_DIRrun_rsn_preproc_feat.sh"

    fi
    ;;
    "T1_seg")
    task=segmentation
    ;;
    "delete_folder")
    echo -n "Where do you want to delete things? ('DTI'|'func'|'surface'|'struct')"
    read modality
    echo -n "What do you want to delete? ('preproc'|'preproc_alt'|'model_X'|'...')"
    read folder
    ;;
    "xtract")
     module unload cuda
      module load cuda/9.1
   echo -n "Which preprocessing version do you want? (preproc_synth|preproc|etc.)"
   read preproc_version
   echo -n "In how many parts do you want to split the protocols?"
   read parts
   echo -n "Which protocols part do you want to use? (all=0|first of part = 1| etc)"
   read protocols_used
    ;;
esac

# Analysis subject loop
cat $sub_list | awk "NR>$start &&  NR<$(($end+1))" | while read subject ; do 
  case $analysis in 
    "Surface")
    if [ ! -d $script_dir/$analysis\_logs/ ]; then
	echo Make output and error directories...\n
	mkdir $script_dir/$analysis\_logs/
	echo Done!\n
    fi
      echo "Perform surface conversion for Subject $subject"
      qsub -q 'verylong' -l 'walltime=42:00:00,mem=25gb' -o $script_dir/$analysis\_logs/$subject\_o -e $script_dir/$analysis\_logs/$subject\_e -N $subject\_$analysis -F "$subject" -V $surface_conversion_script # -N Name -F Variables ($1) -V script 
      echo "Done"
      ;;
   "copy_anat")
      if [ ! -d $script_dir/$analysis\_logs/ ]; then
	echo Make output and error directories...\n
	mkdir $script_dir/$analysis\_logs/
	echo Done!\n
	fi
      echo "Copy T1s for Subject $subject"
      qsub -l 'walltime=00:15:00,mem=5gb' -o $script_dir/$analysis\_logs/$subject\_o -e $script_dir/$analysis\_logs/$subject\_e -N $subject\_$analysis -F "$data_dir $subject" -V $copy_anat_files_script

   ;;
   "T1_seg")
   echo "Make T1 segmentation for subject: $subject"
   if [ ! -d $script_dir/$analysis\_logs/ ]; then
	echo Make output and error directories...\n
	mkdir $script_dir/$analysis\_logs/
	echo Done!\n
   fi
   qsub -l "walltime=00:45:00,mem=5gb" -o $script_dir/$analysis\_logs/$subject\_o -e $script_dir/$analysis\_logs/$subject\_e -N $subject\_$analysis -F "$data_dir $subject $task" -V $T1_seg_script
   ;;
   "copy_files")
   
   if [ ! -d $script_dir/$analysis\_$mod\_logs/ ]; then
	echo Make output and error directories for $mod...\n
	mkdir $script_dir/$analysis\_$mod\_logs/
	echo Done!\n
	fi
      echo "Copy $mod for Subject $subject"
      qsub -l 'walltime=00:30:00,mem=15gb' -o $script_dir/$analysis\_$mod\_logs/$subject\_o -e $script_dir/$analysis\_$mod\_logs/$subject\_e -N $subject\_$analysis -F "$data_dir $mod $subject" -V $copy_files_script
   ;;
     "prepare_scans")  
      if [ ! -d $script_dir/$analysis\_$mod\_logs/ ]; then
	echo Make output and error directories for $mod...\n
	mkdir $script_dir/$analysis\_$mod\_logs/
	echo Done!\n
	fi
      echo "Prepare $mod for Subject $subject"
      qsub -l 'walltime=00:30:00,mem=15gb' -o $script_dir/$analysis\_$mod\_logs/$subject\_o -e $script_dir/$analysis\_$mod\_logs/$subject\_e -N $subject\_$analysis -F "$data_dir $mod $subject" -V $prepare_scans_script
   ;;
   "run_feat_functionnectome")
   if [ ! -d $script_dir/$analysis\_$task\_$model\_logs/ ]; then
	echo Make output and error directories for $task with model $model...\n
	mkdir $script_dir/$analysis\_$task\_$model\_logs/
	echo Done!\n
   fi
      echo "Run $task $model feat for Subject $subject"
      qsub -l 'walltime=04:00:00,mem=15gb' -o $script_dir/$analysis\_$task\_$model\_logs/$subject\_o -e $script_dir/$analysis\_$task\_$model\_logs/$subject\_e -N $subject\_$analysis -F "$data_dir $subject $task $model" -V $functionnectome_script
     
   ;;
    "run_feat")  
      if [ ! -d $script_dir/$analysis\_$task\_$model\_logs/ ]; then
	echo Make output and error directories for $task with model $model...\n
	mkdir $script_dir/$analysis\_$task\_$model\_logs/
	echo Done!\n
	fi
      echo "Run $task $model feat for Subject $subject"
      qsub -l 'walltime=04:00:00,mem=15gb' -o $script_dir/$analysis\_$task\_$model\_logs/$subject\_o -e $script_dir/$analysis\_$task\_$model\_logs/$subject\_e -N $subject\_$analysis -F "$data_dir $subject $task $model" -V $run_feat_script
   ;;
   "combine_echoes")
   echo "Combining echoes for Subject: $subject in Task $task"
   if [ ! -d $script_dir/$analysis\_$task\_logs/ ]; then
	echo Make output and error directories for $task...\n
	mkdir $script_dir/$analysis\_$task\_logs/
	echo Done!\n
   fi 
   qsub -l 'walltime=00:30:00,mem=35gb' -o $script_dir/$analysis\_$task\_logs/$subject\_o -e $script_dir/$analysis\_$task\_logs/$subject\_e -N $subject\_$analysis -F "$data_dir $subject $task" -V $combine_echoes_script

   ;;
   "dti")
   if [ ! -d $script_dir/$analysis\_$task\_logs/ ]; then
	echo Make output and error directories for $task...\n
	mkdir $script_dir/$analysis\_$task\_logs/
	echo Done!\n
   fi
      echo "Run dti $model with $preproc_version on Subject: $subject"
      qsub -l 'nodes=1:gpus=1, feature=cuda, walltime=2:00:00,mem=20gb, reqattr=cudacap>=5.0' -N $subject\_${analysis:0:3} -F "$data_dir $subject $model $preproc_version" -V  $run_dti_model_script
      echo "Done! \n"
      ;;
   "dti_orga")
   modality="dti"
   #Make output and error directory
   if [ ! -d $script_dir/$analysis\_logs/ ]; then
    echo Make output and error directories...\n
    mkdir $script_dir/$analysis\_logs/
    echo Done!\n
   fi
      echo "Organise dti data for Subject $subject"
      qsub -l 'walltime=00:15:00,mem=5gb' -o $script_dir/$analysis\_logs/$subject\_o -e $script_dir/$analysis\_logs/$subject\_e -N $subject\_$analysis -F "$data_dir $subject $modality" -V $organize_data_script_alt
      ;;
   "dti_preproc")
   if [ ! -d $script_dir/$analysis\_logs/ ]; then
    echo Make output and error directories...\n
    mkdir $script_dir/$analysis\_logs/
    echo Done!\n
   fi
      echo "Run dti preprocessing on Subject: $subject"
      qsub -l 'nodes=1:gpus=1, feature=cuda, walltime=04:00:00, mem=10gb, reqattr=cudacap>=5.0' -o $script_dir/$analysis\_logs/$subject\_o -e $script_dir/$analysis\_logs/$subject\_e  \
      -N $subject\_${analysis:0:5} -F "$data_dir $subject" -V $run_dti_preproc_synth_script
      echo "Done!"
      ;;
   "Tractography")
      #model="test" # "dtifit" | "bedpost" | "probtrackx" |"test"
      if [ ! -d $script_dir$analysis\_$model\_logs/ ]; then
	echo Make output and error directories...\n
	mkdir $script_dir$analysis\_$model\_logs/
	echo Done!\n
      fi
      echo "Run tractography on Subject: $subject"
      case $model in 
      "test"|"dtifit")
      echo Using small job
      qsub -l 'walltime=01:00:00, mem=20gb' -o $script_dir/$analysis\_$model\_logs/$subject\_o -e $script_dir/$analysis\_$model\_logs/$subject\_e -N $subject\_${analysis:0:3} -F "$data_dir $subject $model" -V $run_tractography_script
      ;;
      "bedpost"|"probtrackx")
      echo Using a lot of resources
      qsub -l 'nodes=1:gpus=1:ppn=12, feature=cuda, walltime=24:00:00,mem=40gb, reqattr=cudacap>=5.0' -o $script_dir/$analysis\_$model\_logs/$subject\_o -e $script_dir/$analysis\_$model\_logs/$subject\_e -N $subject\_${analysis:0:3} -F "$data_dir $subject $model" -V $run_tractography_script
      ;;
      esac
      echo "Done!"
      ;;
   "xtract")
    if [ ! -d $script_dir$analysis\_$preproc_version\_logs/ ]; then
	echo Make output and error directories...\n
	mkdir $script_dir$analysis\_$preproc_version\_logs/
	echo Done!\n
      fi
      # one protocol per job:
      # Create subject protocol list here:
      protocols=$script_dir/xtract/Human
	# Specifiy protocols list per subject
	# Create xtract folder for subject
	if [ ! -d $data_dir\DTI/$subject/proc/xtract/ ]; then
	  echo "Make xtract directory for $subject"
	  mkdir $data_dir\DTI/$subject/proc/xtract/
	  chmod -R 777 $data_dir\DTI/$subject/proc/xtract/
	  echo "Done!"
	fi
	if [ ! -f $data_dir\DTI/$subject/proc/$subject\_protocols.txt ]; then
	  echo "Creating protocols file for $subject"
	  #protocols=()
	  printf "%s\n" "$(find $protocols/* -type d -exec basename {} \; )" > $data_dir\DTI/$subject/proc/xtract/$subject\_protocols_names.txt # names of tracts only without \t1
	  printf "$(perl -p -e 's/\n/\t1\n /' $data_dir\DTI/$subject/proc/xtract/$subject\_protocols_names.txt)" > $data_dir\DTI/$subject/proc/xtract/$subject\_protocols.txt
	  # Save protocols as "tract tab 1 on single lines" 
	  echo "Done"
	fi # Saved protocols list for subject
	# load as array
	readarray -t protocol_array < $data_dir\DTI/$subject/proc/xtract/$subject\_protocols.txt
	readarray -t protocol_names_array < $data_dir\DTI/$subject/proc/xtract/$subject\_protocols_names.txt
	#echo "${protocol_array[@]}"
	i=0
      for protocol in "${protocol_array[@]}"; do
	echo "Protocol is: $protocol"
	echo "Protocol name is: ${protocol_names_array[$i]}"
	printf "%s\n" "$protocol" > $data_dir\DTI/$subject/proc/xtract/protocol.txt
	protocol_file=$data_dir\DTI/$subject/proc/xtract/protocol.txt
	echo "Protocol file is: $protocol_file"
	echo "Submit job"
	qsub -l "walltime=04:00:00,mem=4gb" -o $script_dir/$analysis\_$preproc_version\_logs/$subject\_o -e $script_dir/$analysis\_$preproc_version\_logs/$subject\_e -N $subject\_${analysis:0:3} -F "$data_dir $subject $preproc_version ${protocol_names_array[$i]}" -V $run_xtract_parallel_script
	((i++))
      done
   ;;
   "rsn_preproc")
   
    if [ ! -d $script_dir/$analysis\_logs/ ]; then
	echo Make output and error directories...\n
	mkdir "$script_dir/$analysis\_$preproc_version\_logs/"
	echo Done!\n
    fi
    
   echo "Run rsn preprocessing on Subject: $subject"
   echo "Preproc version for bash script is: $preproc_version"
   echo "Analysis specified as $analysis"
   qsub -l "walltime=08:00:00,mem=20gb" -o "$script_dir/$analysis\_$preproc_version\_logs/$subject\_o" -e "$script_dir/$analysis\_$preproc_version\_logs/$subject\_e" -N $subject\_${analysis:0:3} -F "$data_dir $subject $task $preproc_version" -V $run_rsn_preproc_script
  
   echo "Done!"
   ;;
   "Test")
    
      ;;
    "Clean")
      echo "Cleaning up subject directory for Subject: $subject"
      qsub -l 'walltime=00:10:00,mem=4gb' -N $subject\_${analysis:0:3} -F "$data_dir $subject" -V $clean_up_script
      #mv "$data_dir$subject/dti" "$data_dir$subject/dti_pre"
      echo "Done!"
      ;;
    "delete_folder")
      echo "Cleaning up folder $folder in $modality  for  $subject"
      qsub -l 'walltime=00:10:00,mem=4gb' -N $subject\_${analysis:0:3} -F "$data_dir $subject $modality $folder" -V $delete_folder_script
      echo "Done!"
      ;;
      "pre_qc")
      echo "Executing quality control for $sub"
      if [ ! -d $script_dir/$analysis\_logs/ ]; then
	echo Make output and error directories...\n
	mkdir $script_dir/$analysis\_logs/
      fi
      qsub -l 'walltime=01:00:00,mem=5gb' -o $script_dir/$analysis\_$model\_logs/$subject\_o -e $script_dir/$analysis\_$model\_logs/$subject\_e -N $subject\_${analysis:0:3} -F "$data_dir $subject" -V $quality_control_script
      echo "Done!"
      ;;
     
  esac
done