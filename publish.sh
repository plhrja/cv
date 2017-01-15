#!/bin/bash
#
# Script that publishes the CV to the github.io repo.
# CV languages that are published: English, Finnish.

# Stop execution on error.
set -e

# Build and copy English
bash change_locale.sh -en CV.tex
lualatex CV.tex
bash copy_CV_to_github.io.sh -en CV.pdf


# Build and copy Finnish
bash change_locale.sh -fi CV.tex
lualatex CV.tex
bash copy_CV_to_github.io.sh -fi CV.pdf

