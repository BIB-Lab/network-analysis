#!/bin/bash

usage()
{
cat<<EOF
USAGE:
$0

EOF
}

#Default settings
dflag=off
sflag=off
gflag=off
aflag=off
rflag=off
mflag=off

#Reading flags
while getopts d:s:g:a:r:m:h: opt; do
	case "$opt" in
  d)  dflag=on
    amp_dir=("$OPTARG");;
	s)	sflag=on
		subj_list=("$OPTARG");;
	g)  gflag=on
		group_info="$OPTARG";;
  a) 	aflag=on
  	atlases+=("$OPTARG");;
	r) 	rflag=on
		ROIs+=("$OPTARG");;
	m)	mflag=on
		graph_matlab=("$OPTARG");;
	h)	usage
		exit 1;;
	?)	# If unknown flag
		echo
		echo "Unknown flag, please reference usage section and try again."
		echo
		usage
		exit 1;;
	esac
done

#Used to iterate through multiple areas or ROIs if more than one of the same flag is used
shift `expr $OPTIND - 1`

#information for 00_network_files
t_history=`history | tail -1`
timestamp=`date +%Y%m%d`
fulldate=`date`

#build file tree to store all files made and script output
mkdir -p $amp_dir/net_analysis_${timestamp}/00_network_files/network_files
mkdir -p $amp_dir/net_analysis_${timestamp}/00_network_files/amp_composite
mkdir -p $amp_dir/net_analysis_${timestamp}/measures
mkdir -p $amp_dir/net_analysis_${timestamp}/comparisons
mkdir -p $amp_dir/net_analysis_${timestamp}/random_comp
logdir=$amp_dir/net_analysis_${timestamp}/00_network_files

#copy files to 00_network_files for documentation and build README.txt
cp $graph_matlab $logdir/network_files
cp $subj_list $logdir/network_files
cp $group_info $logdir/network_files

#Determine the location of all .byu atlases for each ROI.
for flag in "${ROIs[@]}"; do
        read -p "Where is the $flag atlas located? " ${flag}_atlas
done

#Create a README.txt file with general information about network analysis
echo "Network analysis was initiated on $fulldate" >> $logdir/README.txt
echo "" >> $logdir/README.txt
echo "User --$USER-- initiated the script with the following command:" >> $logdir/README.txt
echo "" >> $logdir/README.txt
echo "$t_history" >> $logdir/README.txt
echo "" >> $logdir/README.txt
echo "--$USER-- ran the network analysis with these ROIs integrated into a composite atlas:" >> $logdir/README.txt
echo ${ROIs[@]} >> $logdir/README.txt
echo ${atlases[@]} >> $logdir/README.txt
echo "" >> $logdir/README.txt
echo "Below are the locations for the .byu files used to create the composite atlas (No path will be given if ROI is not included in the analysis):" >> $logdir/README.txt
echo "" >> $logdir/README.txt
echo "Caudate .byu atlas: $caud_atlas" >> $logdir/README.txt
echo "Putamen .byu atlas: $put_atlas" >> $logdir/README.txt
echo "Palladium .byu atlas: $pall_atlas" >> $logdir/README.txt
echo "Nucleus Accumbens .byu atlas: $na_atlas" >> $logdir/README.txt
echo "Thalamus .byu atlas: $thal_atlas" >> $logdir/README.txt
echo "" >> $logdir/README.txt
echo "Hippocampus .byu atlas: $hipp_atlas" >> $logdir/README.txt
echo "Amygdala .byu atlas: $amyg_atlas" >> $logdir/README.txt
echo "" >> $logdir/README.txt
echo "Scripts, subject lists, and group affiliation are found in the /net_analysis_${timestamp}/00_network_files/network_files directory." >> $logdir/README.txt
echo "Hopefully this script works!" >> $logdir/README.txt

#create a composite atlas to be used in the matlab script.
if [ -n "$caud_atlas" ]; then
    grep -E '[0-9]+\.[0-9]+' $caud_atlas >> $logdir/network_files/composite_atlas.byu
		#create the composite amp file with deform data
		cat $subj_list | while read line; do
			if [[ ! -e $amp_dir/basalTh/caud/deform/deform_${line}_caud_rl.amp ]]; then
				continue
			fi
			cat $amp_dir/basalTh/caud/deform/deform_${line}_caud_rl.amp >> $logdir/amp_composite/deform_${line}_comp_rl.amp
		done
		echo "Caudate composites and atlas created."
fi

if [ -n "$put_atlas" ]; then
    grep -E '[0-9]+\.[0-9]+' $put_atlas >> $logdir/network_files/composite_atlas.byu
		cat $subj_list | while read line; do
			if [[ ! -e $amp_dir/basalTh/put/deform/deform_${line}_put_rl.amp ]]; then
				continue
			fi
			cat $amp_dir/basalTh/put/deform/deform_${line}_put_rl.amp >> $logdir/amp_composite/deform_${line}_comp_rl.amp
		done
		echo "Putamen composites and atlas created."
fi

if [ -n "$pall_atlas" ]; then
    grep -E '[0-9]+\.[0-9]+' $pall_atlas >> $logdir/network_files/composite_atlas.byu
		cat $subj_list | while read line; do
			if [[ ! -e $amp_dir/basalTh/pall/deform/deform_${line}_pall_rl.amp ]]; then
				continue
			fi
			cat $amp_dir/basalTh/pall/deform/deform_${line}_pall_rl.amp >> $logdir/amp_composite/deform_${line}_comp_rl.amp
		done
		echo "Palladium composites and atlas created."
fi

if [ -n "$na_atlas" ]; then
    grep -E '[0-9]+\.[0-9]+' $na_atlas >> $logdir/network_files/composite_atlas.byu
		cat $subj_list | while read line; do
			if [[ ! -e $amp_dir/basalTh/na/deform/deform_${line}_na_rl.amp ]]; then
				continue
			fi
			cat $amp_dir/basalTh/na/deform/deform_${line}_na_rl.amp >> $logdir/amp_composite/deform_${line}_comp_rl.amp
		done
		echo "Nucleus Accumbens composites and atlas created."
fi

if [ -n "$thal_atlas" ]; then
    grep -E '[0-9]+\.[0-9]+' $thal_atlas >> $logdir/network_files/composite_atlas.byu
		cat $subj_list | while read line; do
			if [[ ! -e $amp_dir/basalTh/thal/deform/deform_${line}_thal_rl.amp ]]; then
				continue
			fi
			cat $amp_dir/basalTh/thal/deform/deform_${line}_thal_rl.amp >> $logdir/amp_composite/deform_${line}_comp_rl.amp
		done
		echo "Thalamus composites and atlas created."
fi

if [ -n "$hipp_atlas" ]; then
    grep -E '[0-9]+\.[0-9]+' $hipp_atlas >> $logdir/network_files/composite_atlas.byu
		cat $subj_list | while read line; do
			if [[ ! -e $amp_dir/HiAm/hipp/deform/deform_${line}_hipp_rl.amp ]]; then
				continue
			fi
			cat $amp_dir/HiAm/hipp/deform/deform_${line}_hipp_rl.amp >> $logdir/amp_composite/deform_${line}_comp_rl.amp
		done
		echo "Hippocampus composites and atlas created."
fi

if [ -n "$amyg_atlas" ]; then
    grep -E '[0-9]+\.[0-9]+' $amyg_atlas >> $logdir/network_files/composite_atlas.byu
		cat $subj_list | while read line; do
			if [[ ! -e $amp_dir/HiAm/amyg/deform/deform_${line}_amyg_rl.amp ]]; then
				continue
			fi
			cat $amp_dir/HiAm/amyg/deform/deform_${line}_amyg_rl.amp >> $logdir/amp_composite/deform_${line}_comp_rl.amp
		done
		echo "Amygdala composites and atlas created."
fi

echo "Now building composite path files for export to matlab."

#build path files to deform_${line}_comp_rl.amp fileparts
cat $subj_list | while read line; do
	echo "$logdir/amp_composite/deform_${line}_comp_rl.amp" >> $logdir/network_files/amp_comp_path.txt
done

#export essential variables to the matlab environment
amp_comp_path=$logdir/network_files/amp_comp_path.txt
echo "amp_comp_path='$amp_comp_path'" >> $logdir/network_files/variables.txt
composite_atlas=$logdir/network_files/composite_atlas.byu
echo "composite_atlas='$composite_atlas'" >> $logdir/network_files/variables.txt
network_group=$logdir/network_files/group.txt
echo "network_group='$network_group'" >> $logdir/network_files/variables.txt

matlab -nodisplay -r "run('$logdir/network_files/variables.txt');"
matlab -nodisplay -r "run('$graph_matlab')"
