#!/bin/bash
#
# Helper script for copying the current cv to the github.io folder.

echo "Starting the copy process..."

# Stop execution on error.
set -e

DEST="/home/woope/git/plhrja.github.io/"
SUFFIX=

# Check for flags.
while test $# -gt 0; do
        case "$1" in
                -en|--english)
			SUFFIX="en"
			shift
                        ;;

		-fi|--finnish)
			SUFFIX="fi"
			shift
                        ;;

                *)
                        break
                        ;;
        esac
done

if [ $# -ne 1 ]; then
	echo "Provide a single input file for copying!"
	exit 1
fi

if [ -z $SUFFIX ]; then
	echo "USAGE: copy_CV_to_github.io.sh LANG-FLAG DOCUMENT"
	echo "	LANG-FLAGS:"
	echo "		-fin|--finnish: 'fi' suffix"
	echo "		-en|--english: 'en' suffix"
	exit 1
fi

echo "Copying $1 to $DEST with suffix $SUFFIX"

TRG=$(echo $1 | sed "s/.pdf$/_$SUFFIX.pdf/")
TRG=$DEST$TRG

echo $TRG
cp $1 $TRG

echo "Copying finished!"
