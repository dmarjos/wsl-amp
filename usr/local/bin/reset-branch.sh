#!/bin/bash
echo '/***************************************************************\'
echo '| Windows Subsystem for Linux - WEB Development Container Setup |'
echo '|                                                               |'
echo '| This script reset and remove any changes that you might have  |'
echo '| on the current repository                                     |'
echo '|                                                               |'
echo '\***************************************************************/'
echo -n "Do you want to continue? (Please type 'Yes, continue'):"
read WHAT_TO_DO

if [ "${WHAT_TO_DO}" != "Yes, continue" ]; then
	echo "Aborted"
	exit
fi 

git restore --staged `git status | grep "modified" | awk '{print $2;}'`
git checkout `git status | grep "modified" | awk '{print $2;}'`
for UNTRACKED in `git ls-files --others --exclude-standard`; do
    rm -f ${UNTRACKED}
done
