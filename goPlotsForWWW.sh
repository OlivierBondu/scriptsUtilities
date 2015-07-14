#!/bin/bash
syntax="Syntax ${0} {new plot folder}"
if [[ -z ${1} ]]
then
  echo ${syntax}
#  exit 1
fi

##### CREATE THE NEW FOLDER AND MOVE STUFF IN THERE #####
newFolder=${1}
mkdir ${newFolder}
#for folder in `echo "eps gif pdf png C"`
for folder in `echo "pdf root gif png"`
do
	mv ${folder}/ ${newFolder}/
	mkdir ${folder}
done

##### PUT THE index.php IN THERE #####
cp ~/scripts/index.php ${newFolder}/

##### MOVE EVERYTHING TO SERVER02 #####
scp -r ${newFolder}/ server02.fynu.ucl.ac.be:/home/obondu/public_html/cp3-llbb/

