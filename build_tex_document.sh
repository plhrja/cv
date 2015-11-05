#!/bin/bash

set -e

if [ "$#" -ne 1 ]; then
    echo "Provide a TeX-file to be run!"
    exit 1
fi

echo "Starting initial compile..."
latex $1
echo "Compiled!"

echo "Next, compiling .bib files..."
# Note that we do not want to run the .tex file explicitly! Removing file-extension...
bibtex $(echo $1 | sed 's/.tex$//')
echo "Compiled!"

echo "Finally, performing double compilation of the article to ensure correct referencing (last compile with pdflatex)."
latex $1
pdflatex -shell-escape $1
echo "Completed! Successfully compiled $1. "
