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

export MESSAGE="$*"
if [ -z "${MESSAGE}" ]; then
    echo "No commit message specified"
    exit 0
fi

git add --all && git commit -m "$MESSAGE" && git push origin $DEVEL_BRANCH 
