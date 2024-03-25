#!/bin/bash/

# Running xtract on the Lii data, with only one protocol per job: $1 = data_dir, $2 = subject, $3 = preproc_version, $4 protocol name

#module unload cuda
#module load cuda/9.1
MRCATDIR=/opt/mr-cat/latest


	# This means that we warp results to standart space, but we have it in native space as well (T1w) folder
	std2diff=$1$2/surfaces/MNINonLinear/xfms/standard2acpc_dc.nii.gz # Change to T1 registered to diffusion space (use native + gpu flag for xtract)
	diff2std=$1$2/surfaces/MNINonLinear/xfms/acpc_dc2standard.nii.gz
	bpxdir=$1DTI/$2/$3/in.bedpostX # bedpost dir

	outdir=$1DTI/$2/proc/xtract/$4 # We need separate dummy directories to parallelize, otherwise commands and protocols gets overwritten en doesn't compute
	if [ ! -d $1DTI/$2/proc/xtract/$4 ]; then
	  echo "Make xtract directory for $2"
	  mkdir $1DTI/$2/proc/xtract/$4
	  chmod -R 777 $1DTI/$2/proc/xtract/$4
	  echo "Done!"
	fi
	
	# Where can I find the protocols?
	protocols=/project/2422119.01/scripts/xtract/Human
	echo -e "$4 \\t 1" > $1DTI/$2/proc/xtract/$4/protocol.txt
	protocol_file="$1DTI/$2/proc/xtract/$4/protocol.txt"
	#cp $protocol_file $1DTI/$2/proc/xtract/$4/protocol.txt
	#protocol_file="$1DTI/$2/proc/xtract/$4/protocol.txt"
        target=$FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz
	#echo "module load cuda/9.1" > $dir/reports/cmd${tmp}
	#echo "$MRCATDIR/core/xtract -bpx $bpxdir -out $outdir -species HUMAN -str $protocols_list -p $protocols -stdwarp $std2diff $diff2std -stdref $target" | qsub -l 'nodes=1:ppn=1, walltime=48:00:00, mem=256gb' -o $dir/reports/o_${s}.txt -e $dir/reports/e_${s}.txt 
	chmod -R 777 $1DTI/$2/proc/xtract/
	$MRCATDIR/core/xtract -native -bpx $bpxdir -out $outdir -species HUMAN -str $protocol_file -p $protocols -stdwarp $std2diff $diff2std -stdref $target
	# Compute tracts in native space
	
	# Clean up dummy dirs
	cp -r $1DTI/$2/proc/xtract/$4/tracts/$4 $1DTI/$2/proc/xtract/tracts/
	cp -r $1DTI/$2/proc/xtract/$4/masks/$4 $1DTI/$2/proc/xtract/masks/
	cp -r $1DTI/$2/proc/xtract/$4/logs/* $1DTI/$2/proc/xtract/logs/
	#rm -r $1DTI/$2/proc/xtract/$4/
	