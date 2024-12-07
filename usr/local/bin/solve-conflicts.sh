#!/bin/bash

if [ ! -f $1 ]; then
        echo "File not found"
        exit 0
fi
PWD=`pwd`
PROJECT=`basename ${PWD}`
DIR=`dirname $1`
mkdir -p ../solve-conflicts-${PROJECT}/${DIR}
mv $1 ../solve-conflicts-${PROJECT}/$1
