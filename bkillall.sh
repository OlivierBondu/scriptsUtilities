#!/bin/bash

for ijob in `bjobs | grep -v JOBID | awk '{print $1}'`
do
	bkill ${ijob}
done
