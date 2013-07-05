#!/bin/bash
# Script to check size of eos directory
# Written by O. Bondu (June 2013)

#####
echo "WARNING: script has to be SOURCED (source script.sh) for the eos commands to be recognized"
totalBytes="0"

#####
function letsdothis {
	if [[ -z ${2} ]]
	then
		return 1
	fi

	depth=${1}	
	folder[${depth}]=${2}
	oldfolder[${depth}]=${3}
	echo "checking folder ${folder[${depth}]} (depth= ${depth})"
	
	#####
	#echo "summing files in the directory"
	totalfiles[${depth}]=$(
	for file in `eos ls ${folder[${depth}]}`
	do
	#	echo ${file}
		eos ls -l ${folder[${depth}]} | grep -x ".*${file}\>" | awk '{print $1}' | grep d &> /dev/null && continue
		eos ls -l ${folder[${depth}]}/${file}
	done | awk '{SUM+=$5} END{print SUM}'
	)
	if [[ ${totalfiles[${depth}]} = "" ]]
	then
		totalfiles[${depth}]="0"
	fi
	
	totalfilesHR[${depth}]=`echo "${totalfiles[${depth}]}" | awk '{ sum=$1 ; hum[1024**5]="Pb";hum[1024**4]="Tb";hum[1024**3]="Gb";hum[1024**2]="Mb";hum[1024]="Kb"; for (x=1024**5; x>=1024; x/=1024){ if (sum>=x) { printf "%.2f %s\n",sum/x,hum[x];break } }}'`
	echo -e "totalfiles[${depth}]=\t${totalfilesHR[${depth}]}\t(${totalfiles[${depth}]} bytes)"
	
	totalBytes=$(( ${totalfiles[${depth}]} + ${totalBytes} ))
	
	#####
	#echo "listing additional directories"
#	total[${depth}]="0"
	listdir[${depth}]=`eos ls ${folder[${depth}]}`
	for file in `echo "${listdir[${depth}]}"`
	do
	#		echo ${folder}/${file}
			depthNew=`echo "${depth} + 1" | bc -ql`
		  eos ls -l ${folder[${depth}]} | grep -x ".*${file}\>" | awk '{print $1}' | grep d &> /dev/null && letsdothis ${depthNew} ${folder[${depth}]}/${file} ${folder[${depth}]} #&& echo -e "\t\t### END OF CALL letsdothis ${depthNew} ${folder[${depth}]}/${file} ${folder[${depth}]}"
#			echo "depth= ${depth}"
	done
	
	folder[${depth}]=${oldfolder[${depth}]}
	#echo "exiting function: folder= ${folder}"
#	return ${total[${depth}]}
	return 0
}

letsdothis 0 ${1} ${1}

##### 
totalBytesHR=`echo "${totalBytes}" | awk '{ sum=$1 ; hum[1024**5]="Pb";hum[1024**4]="Tb";hum[1024**3]="Gb";hum[1024**2]="Mb";hum[1024]="Kb"; for (x=1024**5; x>=1024; x/=1024){ if (sum>=x) { printf "%.2f %s\n",sum/x,hum[x];break } }}'`
echo ""
echo -e "GRAND TOTAL =\t${totalBytesHR}\t(${totalBytes} bytes)\tfor folder ${1}"

