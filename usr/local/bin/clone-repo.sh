#!/bin/bash

export GIT_URL=$1
if [ -z "${GIT_URL}" ]; then
	echo "Please specify the URL for the repo to clone. You can use HTTPS or SSH repositories";
	exit
fi
shift
if [ ! -z "{$1}" ]; then
	export MASTER_BRANCH=$1
else
	export MASTER_BRANCH=master
fi
git clone ${GIT_URL} .
git config devel.masterbranch ${MASTER_BRANCH}
git config devel.currentbranch ${MASTER_BRANCH}
