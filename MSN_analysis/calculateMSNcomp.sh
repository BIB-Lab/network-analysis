#!/bin/bash

usage()
{
cat<<EOF
USAGE:
$0 [ -l list of all labels in the analysis (textfile) ] [ -s list of all subjects ] [ -d subject directory ]

OPTIONS:
	-h 	Show this message

EOF
}

#Default settings
lflag=off
sflag=off
dflag=off

#Reading flags
while getopts l:s:d:h: opt; do
	case "$opt" in
	l)	lflag=on
			labels_list="$OPTARG";;
	s)	sflag=on
			subj_list="$OPTARG";;
	d)	dflag=on
			subjdir=("$OPTARG");;
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

if [ $lflag == "off" ] || [ $sflag == off ] || [ $dflag == off ]; then
 	echo
 	echo "Missing flag, review usage section to verify inputs"
    echo
    usage
    exit 1
fi

echo $subjdir
echo $labels_list
echo $subj_list

export SUBJECTS_DIR=$subjdir
cd $subjdir

cat $subj_list | while read sub; do
	mkdir -p ${subjdir}/${sub}/stats/MSN
  cat $labels_list | while read lab; do
    for hemi in lh rh; do
      mris_anatomical_stats -l ${hemi}.${lab}.label -b $sub ${hemi} >> $sub/stats/MSN/${hemi}_MMP12_stats.txt
    done
  done
done

cat $subj_list | while read sub; do
  mkdir -p ${sub}/stats/MSN/MMP12_temp
  for hemi in lh rh; do
    tempdir=${subjdir}/${sub}/stats/MSN/MMP12_temp
    ## extract every 16th line (with the statistics)
    awk 'NR % 16 == 0' ${subjdir}/${sub}/stats/MSN/${hemi}_MMP12_stats.txt > $tempdir/${sub}_Tempfile1_${hemi}.txt
    ## For each hemisphere:
    awk '{print $2,$3,$4,$5,$6,$7,$8,$9,$10}' $tempdir/${sub}_Tempfile1_${hemi}.txt > $tempdir/${sub}_Tempfile2_${hemi}.txt
    ## separate everthing with columns
    sed 's/\s\+/,/g' $tempdir/${sub}_Tempfile2_${hemi}.txt > $tempdir/${sub}_Tempfile3_${hemi}.txt
    ## remove "MMP12_" from labels
    sed 's/MMP12_//g' $tempdir/${sub}_Tempfile3_${hemi}.txt > $tempdir/${sub}_Tempfile4_${hemi}.txt
    ##add headings to csv files
    echo "surface_area(mm2),gray_matter_vol(mm3),avg_cort_thickness,CT+-SD,mean_curvature,gaussian_curv,folding_index,curv_index,hemi,label" > $tempdir/${sub}_Tempfile5_${hemi}.txt
    ## remove ".label" from ROI name and rename file with sbject ID
    awk -F"," 'BEGIN{OFS=","}{gsub(".label"," ",$10);print $0}' $tempdir/${sub}_Tempfile4_${hemi}.txt >> $tempdir/${sub}_Tempfile5_${hemi}.txt
    #replace spaces with commas
    sed 's/ /,/g' $tempdir/${sub}_Tempfile5_${hemi}.txt > $tempdir/${sub}_Tempfile6_${hemi}.txt
    #removes a specific period from behind the hemi, changes it to comma
    sed 's/\([lr]h\)\./\1,/g' $tempdir/${sub}_Tempfile6_${hemi}.txt > $tempdir/${sub}_Tempfile7_${hemi}.txt
    #removes ".label"
    sed 's/\.label$//' $tempdir/${sub}_Tempfile7_${hemi}.txt > ${subjdir}/${sub}/stats/MSN/${sub}_${hemi}_MMP12stats.csv
  done
  rm -rf $tempdir
  echo "MSN file compiled for ${sub}"
done

mkdir -p ${subjdir}/MSNs/MMP12_stats ${subjdir}/MSNs/Matrix ${subjdir}/MSNs/DMNs ${subjdir}/MSNs/CCNs ${subjdir}/MSNs/SNs ${subjdir}/MSNs/ORDMs
cat $subj_list | while read sub; do
  paste -d ',' "${subjdir}/${sub}/stats/MSN/${sub}_lh_MMP12stats.csv" "${subjdir}/${sub}/stats/MSN/${sub}_rh_MMP12stats.csv" > "${subjdir}/MSNs/MMP12_stats/${sub}_MMP12stats.csv"
done

#export essential variables to the matlab environment
MMP12_stats_dir=${subjdir}/MSNs/MMP12_stats/
matrix_dir=${subjdir}/MSNs/Matrix/
DMNs_dir=${subjdir}/MSNs/DMNs/
CCNs_dir=${subjdir}/MSNs/CCNs/
SNs_dir=${subjdir}/MSNs/SNs/
ORDMs_dir=${subjdir}/MSNs/ORDMs/

echo "MMP12_stats_dir='$MMP12_stats_dir'" >> ${subjdir}/MSNs/variables.m
echo "matrix_dir='$matrix_dir'" >> ${subjdir}/MSNs/variables.m
echo "DMNs_dir='$DMNs_dir'" >> ${subjdir}/MSNs/variables.m
echo "CCNs_dir='$CCNs_dir'" >> ${subjdir}/MSNs/variables.m
echo "SNs_dir='$SNs_dir'" >> ${subjdir}/MSNs/variables.m
echo "ORDMs_dir='$ORDMs_dir'" >> ${subjdir}/MSNs/variables.m

echo "Running Matlab..."
