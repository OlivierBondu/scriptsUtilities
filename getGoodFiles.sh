#!/bin/bash
# Script to get good files from (eos) storage element

syntax="Syntax ${0} {sampleName} {storageDir}"
if [[ -z ${1} ]]
then
  echo ${syntax}
  exit 1
fi
sample=${1}
storageDir=${2:-"/data/`whoami`/${sample}"}
listFile="listFiles_${sample}"

echo "storage= ${storageDir}"
if [[ ! -d ${storageDir} ]]
then
	echo "Creating directory ${storageDir}"
	mkdir ${storageDir}
else
	echo "Directory ${storageDir} already exists"
fi


if [[ ! -e ${listFile} ]]
then
	echo "File containing the file list (${listFile}) does not exist, exiting"
	exit 1
fi

echo "Now looking files listed in ${listFile}"

for file in `cat ${listFile}`
do
	file=${file#/eos/cms/}
	echo "Trying to reach file ${file}"
	cmsStage ${file} ${storageDir}
	if [[ "$?" == "0" ]]
	then
		echo -e "\tCopy successful"
	else
		echo "##### WARNING, COPY SEEMS TO HAVE FAILED ###"
	fi
	sleep 1
#	cmsLs ${file}
done

echo "### Files have been stored to ${storageDir} ###"
 
exit 0
