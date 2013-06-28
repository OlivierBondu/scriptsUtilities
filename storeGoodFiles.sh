#!/bin/bash
# Script to store good files from (eos) storage element
# Olivier Bondu, March 2012

syntax="Syntax ${0} {sampleName} {storageDir} {eosPath}"
if [[ -z ${1} ]]
then
  echo ${syntax}
  exit 1
fi
sample=${1}
storageDir=${2:-"/data/`whoami`/${sample}/HADD"}
eosPath=${3:-/store/group/phys_higgs/Resonant_HH/processed/V14_00_08/mc}

echo "### CREATING EOS DIRECTORY ###"
cmsMkdir ${eosPath}/${sample}

echo "### COPYING FILES TO THE EOS DIRECTORY ###"
for file in `'ls' ${storageDir}`
do
	echo ${file}
	cmsStage ${storageDir}/${file} ${eosPath}/${sample}/
	if [[ "$?" == "0" ]]
	then
		echo -e "\tCopy successful"
	else
		echo "##### WARNING, COPY SEEMS TO HAVE FAILED ###"
	fi
	sleep 1
done

echo "### FILES HAVE BEEN COPIED TO ${eosPath}/${sample} ###"
echo "### Please ensure everything is correct by checking the following command: ###"
echo "cmsLs ${eosPath}/${sample}"



exit 0

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
#	cmsLs ${file}
done
 
exit 0
