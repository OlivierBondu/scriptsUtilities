#!/bin/bash

syntax="${0} {folder}"
if [[ -z ${1} ]]
then
	echo "ERROR: syntax is ${syntax}"
	exit 2
fi

folder="${1}"

tar -cvzf ${folder}.tar.gz ${folder}

exit 0

