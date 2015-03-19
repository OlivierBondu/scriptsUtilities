#!/bin/bash
# Script to check size of eos directory
# Written by O. Bondu (June 2013)

#####
#echo -e "WARNING: script has to be SOURCED (source script.sh) for the eos commands to be recognized\n"
totalBytes="0"
originalFolder=${1}
destinationFolder=${2}
if [[ -z ${1} ]]
then
	echo "need origin and destination folder as arguments"
	return 1
fi 

dir=""
eoscommand="/afs/cern.ch/project/eos/installation/0.2.31/bin/eos.select"

#####
# listdir
#####
function listdir {
	depth=${1}
	folder=${2}	
	echo "##### Listing depth ${depth} with folder ${folder}"
	dirlist[${depth}]=`${eoscommand} ls -l ${folder} | grep -e "^d" | awk '{print $9" "}' | awk '{printf $0}'`
	filelist[${depth}]=`${eoscommand} ls -l ${folder} | grep -v -e "^d" | awk '{print $9" "}' | awk '{printf $0}'`
	bytelist[${depth}]=`${eoscommand} ls -l ${folder} | grep -v -e "^d" | awk '{print $5" "}' | awk '{printf $0}'`
	i=1
	tot=`echo "${filelist[${depth}]}" | wc -w`
	echo "tot= ${tot}"
#	for (( file=`${filelist[${depth}]} | cut -d ' ' -f ${i}` , byte=`${bytelist[${depth}]} | cut -d ' ' -f ${i}` ;  ${i} <= ${tot} ; i++ ))
	while [[ ${i} -lt ${tot} ]] 
	do
		file=`echo "${filelist[${depth}]}" | cut -d ' ' -f ${i}`
		byte=`echo "${bytelist[${depth}]}" | cut -d ' ' -f ${i}`
		echo -e "i= ${i}\tfile= ${file}\tbyte= ${byte}"
		i=$((i+1))
	done
	totalfiles[${depth}]=`${eoscommand} ls -l ${folder} | grep -v -e "^d" | awk 'BEGIN{SUM=0} {SUM+=$5} END{print SUM}'`
	totalfilesHR[${depth}]=`echo "${totalfiles[${depth}]}" | awk '{ sum=$1 ; hum[1024**5]="Pb";hum[1024**4]="Tb";hum[1024**3]="Gb";hum[1024**2]="Mb";hum[1024]="Kb"; for (x=1024**5; x>=1024; x/=1024){ if (sum>=x) { printf "%.2f %s\n",sum/x,hum[x];break } }}'`
#	echo -e "\tdirlist[${depth}]= ${dirlist[${depth}]}"
#	echo -e "\tfilelist[${depth}]= ${filelist[${depth}]}"
	echo -e "\ttotalfiles[${depth}]=\t${totalfilesHR[${depth}]}\t(${totalfiles[${depth}]} bytes)"
#	echo -e "\ttotalfiles[${depth}]= ${totalfiles[${depth}]}"
	totalBytes=$(( ${totalfiles[${depth}]} + ${totalBytes} ))
	return 0
}


#####
# checkdirlist
#####
function checkdirlist {
	depth=${1}
	if [[ "${dirlist[${depth}]}" == "" ]]
	then
	# if dirlist is empty, go up one level
		if [[ "${depth}" != "0" ]]
		then
#			echo "EMPTY DIR LIST, going up + removing current dir from list"
			depth=$(( ${depth} - 1 ))
			dirlist[${depth}]=`echo "${dirlist[${depth}]}" | cut -d " " -f 2-`
			folder=`echo ${folder} | rev | cut -d / -f 2- | rev`
			dir=""
		else
			depth=$(( ${depth} - 1 ))
		fi
	else
	# if the dirlist is not empty, go deeper
		dir=`echo "${dirlist[${depth}]}" | awk '{print $1}'`
		depth=$(( ${depth} + 1 ))
	fi
	return ${depth} # return the current depth level to scan
}


function doit {
	depth=${1}
	folder=${2}
	listdir ${depth} ${folder}
	checkdirlist ${depth}
	if [[ "${dir}" != "" ]]
	then
		while [ ${depth} -gt -1 ]
		do
			if [[ "${dir}" != "" ]]
			then
				listdir ${depth} ${folder}/${dir}
			fi
			checkdirlist ${depth}
		done
	fi
}

doit 0 ${originalFolder}

#####
# Final printout
##### 
totalBytesHR=`echo "${totalBytes}" | awk '{ sum=$1 ; hum[1024**5]="Pb";hum[1024**4]="Tb";hum[1024**3]="Gb";hum[1024**2]="Mb";hum[1024]="Kb"; for (x=1024**5; x>=1024; x/=1024){ if (sum>=x) { printf "%.2f %s\n",sum/x,hum[x];break } }}'`
echo ""
echo -e "GRAND TOTAL =\t${totalBytesHR}\t(${totalBytes} bytes)\tfor folder ${1}"

