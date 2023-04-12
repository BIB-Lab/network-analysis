#!/bin/bash

  amp_dir=
  subj_list=
  group_info=
  atlases=("basalTh" "HiAm")
  ROIs=("caud" "put" "pall" "na" "thal" "hipp" "amyg")
  graph_matlab=
	braph_path=

	#### FOR EACH ROI in $ROIs, PLEASE PROVIDE A PATH TO AN ATLAS .BYU FILE

#	caud_atlas=
#	put_atlas=
#	pall_atlas=
# na_atlas=
#	thal_atlas=
#	hipp_atlas=
#	amyg_atlas=

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

echo "The BRAPH 1.0.0 Package is located at $braph_path"

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

for atlas in ${atlases[@]}; do
	for roi in ${ROIs[@]}; do
		mkdir -p $amp_dir/net_analysis_${timestamp}/${atlas}/${roi}/measures $amp_dir/net_analysis_${timestamp}/${atlas}/${roi}/comparisons $amp_dir/net_analysis_${timestamp}/${atlas}/${roi}/random_comp
	done
done

#create a composite atlas to be used in the matlab script.
order=()

if [ -n "$caud_atlas" ]; then
    grep -E '[0-9]+\.[0-9]+' $caud_atlas >> $logdir/network_files/composite_atlas.byu
		order+=("caud_atlas")
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
		order+=("put_atlas")
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
		order+=("pall_atlas")
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
		order+=("na_atlas")
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
		order+=("thal_atlas")
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
		order+=("hipp_atlas")
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
		order+=("amyg_atlas")
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

echo "Now building group affiliation files for cohort input."

#Building individual group affiliations for input to cohort in matlab
cat $group_info | while read line; do
  if [[ -z $line ]]; then
    continue
  fi
  if [[ ! -e $logdir/network_files/${line}_group.txt ]]; then
    cat $group_info | while read group; do
      if [[ $line == $group ]]; then
        echo "1" >> $logdir/network_files/${line}_group.txt
      else
        echo "0" >> $logdir/network_files/${line}_group.txt
      fi
    done
    echo "${line}_group.txt" >> $logdir/network_files/groupnames.txt
  else
    continue
  fi
done

echo "Exporting Variables."

cat $logdir/network_files/groupnames.txt | while read line; do
	echo "${line%.txt}='$logdir/network_files/${line}'" >> $logdir/network_files/variables.m
	echo "${line%.txt}" >> $logdir/network_files/group_noext.txt
done

#export essential variables to the matlab environment
amp_comp_path=$logdir/network_files/amp_comp_path.txt
composite_atlas=$logdir/network_files/composite_atlas.byu
measure_write=$amp_dir/net_analysis_${timestamp}/measures/
comp_write=$amp_dir/net_analysis_${timestamp}/comparisons/
randcomp_write=$amp_dir/net_analysis_${timestamp}/random_comp/

echo "amp_comp_path='$amp_comp_path'" >> $logdir/network_files/variables.m
echo "composite_atlas='$composite_atlas'" >> $logdir/network_files/variables.m
echo "measure_write='$measure_write'" >> $logdir/network_files/variables.m
echo "comp_write='$comp_write'" >> $logdir/network_files/variables.m
echo "randcomp_write='$randcomp_write'" >> $logdir/network_files/variables.m
echo "braph_path='$braph_path'" >> $logdir/network_files/variables.m
echo "group_noext='$logdir/network_files/group_noext.txt'" >> $logdir/network_files/variables.m

echo "Running Matlab..."

#Run BRAPH analysis
matlab -nodisplay -r "run('$logdir/network_files/variables.m'); run('$graph_matlab'); exit"

start_row=2
for atlas in "${order[@]}"; do
  atlas_csv="${!atlas}"
  atlas_rows=$(cat "$atlas_csv" | wc -l)
  end_row=$((start_row + atlas_rows - 1))
  atlas_ranges+=("$start_row:$end_row")
  start_row=$((end_row + 1))
done

echo "now creating individual ROI outputs for visualization of measures."
for nodal_csv in $amp_dir/net_analysis_${timestamp}/measures/*.csv; do
	current_measure="${nodal_csv##*/measures/}"
  current_measure="${current_measure%.csv}"
  echo "Current measure is: $current_measure"
	for atlas in ${atlases[@]}; do
		if [[ -e $amp_dir/net_analysis_${timestamp}/${atlas} ]]; then
			for roi in ${ROIs[@]}; do
				if [[ -e $amp_dir/net_analysis_${timestamp}/${atlas}/${roi} ]]; then
					for i in "${!order[@]}"; do
					  atlas="${order[$i]}"
						roi_check=$(echo "$atlas" | sed 's/_.*//')
						if [ "$roi_check" = "$roi" ]; then
							echo "Dividing measure BRAPH output of $current_measure by roi. Current ROI: $roi"
					  	atlas_csv="${!atlas}"
					  	atlas_range="${atlas_ranges[$i]}"
					  	awk -F, -v range="$atlas_range" 'NR >= range {print}' "$nodal_csv" > "$amp_dir/net_analysis_${timestamp}/${atlas}/${roi}/measures/${roi}_${current_measure}.csv"
						fi
					done
				fi
			done
		fi
	done
done

echo "now creating individual ROI outputs for visualization of comparisons."
for nodal_csv in $amp_dir/net_analysis_${timestamp}/comparisons/*.csv; do
	current_measure="${nodal_csv##*/comparisons/}"
  current_measure="${current_measure%.csv}"
  echo "Current measure is: $current_measure"
	for atlas in ${atlases[@]}; do
		if [[ -e $amp_dir/net_analysis_${timestamp}/${atlas} ]]; then
			for roi in ${ROIs[@]}; do
				if [[ -e $amp_dir/net_analysis_${timestamp}/${atlas}/${roi} ]]; then
					for i in "${!order[@]}"; do
					  atlas="${order[$i]}"
						roi_check=$(echo "$atlas" | sed 's/_.*//')
						if [ "$roi_check" = "$roi" ]; then
							echo "Dividing Comparison BRAPH output of $current_measure by roi. Current ROI: $roi"
					  	atlas_csv="${!atlas}"
					  	atlas_range="${atlas_ranges[$i]}"
					  	awk -F, -v range="$atlas_range" 'NR >= range {print}' "$nodal_csv" > "$amp_dir/net_analysis_${timestamp}/${atlas}/${roi}/comparisons/${roi}_${current_measure}.csv"
						fi
					done
				fi
			done
		fi
	done
done

echo "now creating individual ROI outputs for visualization of random_comp."
for nodal_csv in $amp_dir/net_analysis_${timestamp}/random_comp/*.csv; do
	current_measure="${nodal_csv##*/random_comp/}"
  current_measure="${current_measure%.csv}"
  echo "Current measure is: $current_measure"
	for atlas in ${atlases[@]}; do
		if [[ -e $amp_dir/net_analysis_${timestamp}/${atlas} ]]; then
			for roi in ${ROIs[@]}; do
				if [[ -e $amp_dir/net_analysis_${timestamp}/${atlas}/${roi} ]]; then
					for i in "${!order[@]}"; do
					  atlas="${order[$i]}"
						roi_check=$(echo "$atlas" | sed 's/_.*//')
						if [ "$roi_check" = "$roi" ]; then
							echo "Dividing Random Comparison BRAPH output of $current_measure by roi. Current ROI: $roi"
					  	atlas_csv="${!atlas}"
					  	atlas_range="${atlas_ranges[$i]}"
					  	awk -F, -v range="$atlas_range" 'NR >= range {print}' "$nodal_csv" > "$amp_dir/net_analysis_${timestamp}/${atlas}/${roi}/random_comp/${roi}_${current_measure}.csv"
						fi
					done
				fi
			done
		fi
	done
done

echo "is this the end yet?"
