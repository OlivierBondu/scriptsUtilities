#!/bin/bash


function letsdothis {
if [[ -z ${1} ]]
then
	return 1
fi

folder=${1}
oldfolder=${2}
echo "checking folder ${folder}"

#echo "summing files in the directory"
# summing files in the directory
for file in `eos ls ${folder}`
do
#	echo ${file}
	eos ls -l ${folder} | grep -x ".*${file}\>" | awk '{print $1}' | grep d &> /dev/null && continue
	eos ls -l ${folder}/${file}
done | awk '{SUM+=$5} END{print SUM}' | awk '{ sum=$1 ; hum[1024**3]="Gb";hum[1024**2]="Mb";hum[1024]="Kb"; for (x=1024**3; x>=1024; x/=1024){ if (sum>=x) { printf "%.2f %s\n",sum/x,hum[x];break } }}'

#echo "listing additional directories"
# listing additional directories
for file in `eos ls ${folder}`
do
#		echo ${folder}/${file}
#		eos ls -l ${folder}
#	  eos ls -l ${folder} | grep -x ".*${file}\>" | awk '{print $1}' | grep d &> /dev/null && echo -e "\tNew folder= ${file}" && letsdothis ${folder}/${file} ${folder}
	  eos ls -l ${folder} | grep -x ".*${file}\>" | awk '{print $1}' | grep d &> /dev/null && letsdothis ${folder}/${file} ${folder}
done

folder=${oldfolder}
#echo "exiting function: folder= ${folder}"
return
}

letsdothis ${1} ${1}
#letsdothis /eos/cms/store/group/phys_higgs/Resonant_HH/reduced/radion_reduction_v03 /eos/cms/store/group/phys_higgs/Resonant_HH/reduced/radion_reduction_v03

