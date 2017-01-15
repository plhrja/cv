#!/bin/bash
#
# Helper script for changing the locale of the CV.
# The localized section need to be nested in a '%@@@LOCALIZATION@@@' block.
# The order of the localizations: en, fi, sw.

# Stop execution on error.
set -e

LANG=

# Check for flags.
while test $# -gt 0; do
        case "$1" in
                -en|--english)
                        LANG="en"
                        shift
                        ;;

                -fi|--finnish)
                        LANG="fi"
                        shift
                        ;;

                -sw|--swedish)
                        LANG="sw"
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

if [ -z $LANG ]; then
        echo "USAGE: change_locale.sh LANG-FLAG DOCUMENT"
        echo "  LANG-FLAGS:"
        echo "          -en|--english: english locale"
	echo "          -fi|--finnish: finnish locale"
	echo "          -sw|--swedish: swedish locale"
        exit 1
fi

echo "Changing locale to $LANG..."

# Clean all previous comments
sed -i "/@@@LOCALIZATION@@@/{n;s/%//}" $1
sed -i "/@@@LOCALIZATION@@@/{n;n;s/%//}" $1
sed -i "/@@@LOCALIZATION@@@/{n;n;n;s/%//}" $1

# Comment out the irrelevant sections 
case $LANG in
        en)
                sed -i "/@@@LOCALIZATION@@@/{n;n;s/^/%/}" $1
		sed -i "/@@@LOCALIZATION@@@/{n;n;n;s/^/%/}" $1
		sed -i -E 's/langname \{(english|finnish|swedish)\}/langname \{english\}/' $1
                ;;

        fi)
                sed -i "/@@@LOCALIZATION@@@/{n;s/^/%/}" $1
		sed -i "/@@@LOCALIZATION@@@/{n;n;n;s/^/%/}" $1
		sed -i -E 's/langname \{(english|finnish|swedish)\}/langname \{finnish\}/' $1
                ;;

        sw)
                sed -i "/@@@LOCALIZATION@@@/{n;s/^/%/}"
		sed -i "/@@@LOCALIZATION@@@/{n;n;s/^/%/}"
		sed -i -E 's/langname \{(english|finnish|swedish)\}/langname \{swedish\}/' $1
                ;;
        *)
                ;;
esac

echo "Finished!"

