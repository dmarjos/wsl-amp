#!/bin/bash

export DEVEL_BRANCH=`git config --get devel.currentbranch`
export MASTER_BRANCH=`git config --get devel.masterbranch`
export FORBIDDEN_PUSH=`git config --get devel.pushforbidden`

if [ -z "${MASTER_BRANCH}" ]; then
    export MASTER_BRANCH="working-test"
fi
if [ -z "${DEVEL_BRANCH}" ]; then
	echo "Branch unknown. Set it using"
	echo ""
	echo "git config devel.currentbranch BRANCH"
	exit

fi
git pull origin $MASTER_BRANCH && git pull origin $DEVEL_BRANCH