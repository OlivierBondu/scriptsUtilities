#!/bin/bash
# Script to check size of eos directory
# Written by O. Bondu (June 2013)

#####
echo -e "WARNING: script has to be SOURCED (source script.sh) for the eos commands to be recognized\n"
totalBytes="0"
originalFolder=${1}
dir=""

function listdir {
	depth=${1}
	folder=${2}	
	echo "##### Listing depth ${depth} with folder ${folder}"
	dirlist[${depth}]=`eos ls -l ${folder} | grep -e "^d" | awk '{print $9" "}' | awk '{printf $0}'`
	filelist[${depth}]=`eos ls -l ${folder} | grep -v -e "^d" | awk '{print $9" "}' | awk '{printf $0}'`
	totalfiles[${depth}]=`eos ls -l ${folder} | grep -v -e "^d" | awk 'BEGIN{SUM=0} {SUM+=$5} END{print SUM}'`
	totalfilesHR[${depth}]=`echo "${totalfiles[${depth}]}" | awk '{ sum=$1 ; hum[1024**5]="Pb";hum[1024**4]="Tb";hum[1024**3]="Gb";hum[1024**2]="Mb";hum[1024]="Kb"; for (x=1024**5; x>=1024; x/=1024){ if (sum>=x) { printf "%.2f %s\n",sum/x,hum[x];break } }}'`
#	echo -e "\tdirlist[${depth}]= ${dirlist[${depth}]}"
#	echo -e "\tfilelist[${depth}]= ${filelist[${depth}]}"
	echo -e "\ttotalfiles[${depth}]=\t${totalfilesHR[${depth}]}\t(${totalfiles[${depth}]} bytes)"
#	echo -e "\ttotalfiles[${depth}]= ${totalfiles[${depth}]}"
	totalBytes=$(( ${totalfiles[${depth}]} + ${totalBytes} ))
	return 0
}



function checkdirlist {
	depth=${1}
#	echo -e "depth= ${depth}\tdirlist[${depth}]= ${dirlist[${depth}]}"
	if [[ "${dirlist[${depth}]}" == "" ]]
	then
	# if dirlist is empty, go up one level
		if [[ "${depth}" != "0" ]]
		then
#			echo "EMPTY DIR LIST, going up"
			depth=$(( ${depth} - 1 ))
#			echo "previous level (${depth}) BEFORE: ${dirlist[${depth}]}"
			dirlist[${depth}]=`echo "${dirlist[${depth}]}" | cut -d " " -f 2-`
			folder=`echo ${folder} | rev | cut -d / -f 2- | rev`
			dir=""
#			echo "previous level (${depth}) AFTER: ${dirlist[${depth}]}"
#			echo "folder= ${folder}"
#			echo "dir= ${dir}"
#			echo ""
		else
			depth=$(( ${depth} - 1 ))
		fi
	else
	# if the dirlist is not empty, go deeper
#		echo "dirlist not empty, go deeper !"
		dir=`echo "${dirlist[${depth}]}" | awk '{print $1}'`
#		echo "dir= ${dir}"
		depth=$(( ${depth} + 1 ))
	fi
	return ${depth} # return the current depth level to scan
}


function doit {
	depth=${1}
	folder=${2}
	listdir ${depth} ${folder}
	checkdirlist ${depth}
	echo ""
	
	if [[ "${dir}" != "" ]]
	then

	while [ ${depth} -gt -1 ]
	do
#		dir=`echo "${dirlist[${depth}]}" | awk '{print $1}'`
#		echo "dir= ${dir}"
		if [[ "${dir}" != "" ]]
		then
			listdir ${depth} ${folder}/${dir}
#			sumfiles ${depth} ${folder}/${dir}
		fi
#		for dir in ${dirlist[${depth}]}
#		do
#			listdir ${depth} ${folder}/${dir}
#			echo "Before checkdirlist: depth= ${depth}"
			checkdirlist ${depth}
#			depth=$?
#			echo "After checkdirlist: depth= ${depth}"
#		done
#		break
	done
	fi

}

doit 0 ${originalFolder}



















#testtest=(${filelist[${depth}]})
#echo "testtest[0]= ${testtest[0]}"
#echo "filelist[${depth}][0]= ${filelist[${depth}][0]}"

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


#letsdothis 0 ${1} ${1}

##### 
totalBytesHR=`echo "${totalBytes}" | awk '{ sum=$1 ; hum[1024**5]="Pb";hum[1024**4]="Tb";hum[1024**3]="Gb";hum[1024**2]="Mb";hum[1024]="Kb"; for (x=1024**5; x>=1024; x/=1024){ if (sum>=x) { printf "%.2f %s\n",sum/x,hum[x];break } }}'`
echo ""
echo -e "GRAND TOTAL =\t${totalBytesHR}\t(${totalBytes} bytes)\tfor folder ${1}"

