#!/bin/bash
# Script to check size of eos directory
# Written by O. Bondu (June 2013)

#####
echo "WARNING: script has to be SOURCED (source script.sh) for the eos commands to be recognized"
totalBytes="0"

#####
function letsdothis {
	if [[ -z ${1} ]]
	then
		return 1
	fi
	
	folder=${1}
	oldfolder=${2}
	echo "checking folder ${folder}"
	
	#####
	#echo "summing files in the directory"
	totalfiles=$(
	for file in `eos ls ${folder}`
	do
	#	echo ${file}
		eos ls -l ${folder} | grep -x ".*${file}\>" | awk '{print $1}' | grep d &> /dev/null && continue
		eos ls -l ${folder}/${file}
	done | awk '{SUM+=$5} END{print SUM}'
	)
	if [[ ${totalfiles} = "" ]]
	then
		totalfiles="0"
	fi
	
	totalfilesHR=`echo "${totalfiles}" | awk '{ sum=$1 ; hum[1024**5]="Pb";hum[1024**4]="Tb";hum[1024**3]="Gb";hum[1024**2]="Mb";hum[1024]="Kb"; for (x=1024**5; x>=1024; x/=1024){ if (sum>=x) { printf "%.2f %s\n",sum/x,hum[x];break } }}'`
	echo -e "totalfiles=\t${totalfilesHR}\t(${totalfiles} bytes)"
	
	totalBytes=$(( ${totalfiles} + ${totalBytes} ))
	
	#####
	#echo "listing additional directories"
	total="0"
	for file in `eos ls ${folder}`
	do
	#		echo ${folder}/${file}
		  eos ls -l ${folder} | grep -x ".*${file}\>" | awk '{print $1}' | grep d &> /dev/null && letsdothis ${folder}/${file} ${folder}
	done
	
	folder=${oldfolder}
	#echo "exiting function: folder= ${folder}"
	return ${total}
}

letsdothis ${1} ${1}

##### 
totalBytesHR=`echo "${totalBytes}" | awk '{ sum=$1 ; hum[1024**5]="Pb";hum[1024**4]="Tb";hum[1024**3]="Gb";hum[1024**2]="Mb";hum[1024]="Kb"; for (x=1024**5; x>=1024; x/=1024){ if (sum>=x) { printf "%.2f %s\n",sum/x,hum[x];break } }}'`
echo ""
echo -e "GRAND TOTAL =\t${totalBytesHR}\t(${totalBytes} bytes)\tfor folder ${1}"

