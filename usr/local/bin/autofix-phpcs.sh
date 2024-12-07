#!/bin/bash

export DIFF_FILE="/tmp/`basename $1 .php`.diff"
vendor/bin/phpcs --report=diff $1 > ${DIFF_FILE}
if [ "$?" == "0" ]; then
    exit
fi
patch -p0 -ui ${DIFF_FILE}
rm -f ${DIFF_FILE}