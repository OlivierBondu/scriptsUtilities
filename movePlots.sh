#!/bin/bash
syntax="Syntax ${0} {new plot folder}"
if [[ -z ${1} ]]
then
  echo ${syntax}
#  exit 1
fi

newFolder=${1}
mkdir ${newFolder}
#for folder in `echo "eps gif pdf png C"`
for folder in `echo "pdf root gif"`
do
	mv ${folder}/ ${newFolder}/
	mkdir ${folder}
done


