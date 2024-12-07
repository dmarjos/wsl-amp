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

export NEW_BRANCH=$1

if [ -z "$NEW_BRANCH" ]; then
    echo "No branch to checkout specified"
    echo $NEW_BRANCH
    exit 0
fi
git config devel.currentbranch $NEW_BRANCH
git branch $NEW_BRANCH && git checkout $NEW_BRANCH && git pull origin $NEW_BRANCH
