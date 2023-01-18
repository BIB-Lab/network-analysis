#!/bin/bash

usage()
{
cat<<EOF
USAGE:
$0 [ -d path to the project directory, should be the parent directory to -a flag ] [-s PCA script ] [ -a atlas (one '-a' flag per atlas) ]
[ -r ROIs (one '-r' flag per ROI)] [ -i subject ID list ] [ -b location where /network_analysis/ is to be created ]

This script is used to build a .amp file that contains the first 20 Principal Components of each targeted ROI within a subject. It is then formatted to be compatible for BRAPH
network analysis (Conducted using MATLAB.)

This script requires all flags noted above. Place a flag in front of EACH
one. DO NOT separate ROIs or areas with a comma.

Available atlases:
hippocampus/amygdala = HiAm
basal ganglia/thalamus = basalTh

Available ROIs:
amygdala = amyg
caudate nucleus = caud
hippocampus = hipp
globus pallidus (aka pallidum) = pall
nucleus accumbens = na
putamen = put
thalamus = thal

Use absolute file paths for flags above (no shortcuts or relative paths)
Notes:


OPTIONS:
	-h 	Show this message

EOF
}

#Default settings
dflag=off
sflag=off
aflag=off
rflag=off
iflag=off
bflag=off

#Reading flags
while getopts d:s:a:r:i:b:h: opt; do
	case "$opt" in
	d)	dflag=on
		proj_dir="$OPTARG";;
	s)  sflag=on
		rscript="$OPTARG";;
	a) 	aflag=on
		atlases+=("$OPTARG");;
	r)	rflag=on
		ROIs+=("$OPTARG");;
	i)	iflag=on
		subj_ids="$OPTARG";;
  b)  bflag=on
    network_dir="$OPTARG";;
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

#Confirm variables
echo 'Analysis Directory is '$proj_dir
echo 'Harmonization R script is '$rscript
echo 'Atlases are '${atlases[@]}
echo 'ROIs are '${ROIs[@]}
echo 'Subject ID List is '$subj_ids
echo 'Network Analysis Directory is '$network_dir

if [ $dflag == "off" ] || [ $sflag == off ] || [ $aflag == off ] || [ $rflag == off ] || [ $bflag == off ] || [ $iflag == off ]; then
 	echo
 	echo "Missing flag, review usage section to verify inputs"
    echo
    usage
    exit 1
fi

#create new .amp structure for network analysis data
mkdir $network_dir/network_analysis_${timestamp}/pca/deform

#compile filepath.txt to use for PCA in R
for atlas in ${atlases[@]}; do
	#Directory for newly-harmonized data
	for ROI in ${ROIs[@]}; do
		#Prevent loop from running for nonexistent data (e.g. HiAm won't run for caud, put, etc.)
		if  [[ ! -e $proj_dir/${atlas}_harm_${timestamp}/${ROI}/deform ]] && [[ -e $proj_dir/${atlas}/${ROI} ]]; then
			mkdir -p $proj_dir/${atlas}_harm_${timestamp}/${ROI}/deform
			mkdir -p $proj_dir/00_harm_files_${timestamp}/${atlas}/${ROI}
