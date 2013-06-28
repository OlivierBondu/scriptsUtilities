#!/bin/bash
# Script to hadd good files locally

syntax="Syntax ${0} {sampleName} {storageDir} {numberOfSamples}"
if [[ -z ${1} ]]
then
  echo ${syntax}
  exit 1
fi
sample=${1}
storageDir=${2:-"/data/`whoami`/${sample}"}
haddQuantity=${3:-10}
outputDir="${storageDir}/HADD"


if [[ ! -d ${outputDir} ]]
then
	echo "Creating output directory ${outputDir}"
	mkdir ${outputDir}
else
	echo "##### WARNING #####"
	echo "##### The directory ${outputDir} already exists, exit now or suffer the consequences #####"
	read -p "" hop
fi

outputCounter=0
inputCounter=0
inputList=""
outputFile="${sample}_${outputCounter}.root"
fileCounter=0
nbOfFiles=`'ls' ${storageDir} | 'grep' root | wc -l`

for file in `'ls' ${storageDir} | 'grep' root`
do
	let fileCounter=fileCounter+1
	inputList="${inputList} ${storageDir}/${file}"
	let inputCounter=inputCounter+1
#	echo -e "${fileCounter}:\t${file}"

	if [[ (! ${inputCounter} -lt ${haddQuantity}) || (${fileCounter} -eq ${nbOfFiles}) ]]
	then
		echo "### CREATING FILE ${outputDir}/${outputFile} ###"
		hadd ${outputDir}/${outputFile} ${inputList}
		let outputCounter=outputCounter+1
		outputFile="${sample}_${outputCounter}.root"
		inputCounter=0
		inputList=""
		echo ""
	fi
done

echo "### OUTPUT IS STORED IN ${outputDir} ###"

exit 0
