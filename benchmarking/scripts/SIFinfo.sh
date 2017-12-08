#!/bin/bash
#
# This script will parse a .SIF file and find the relevant information
# about the problem it contains. It will then print that information
# in the terminal.
# Specifically, the problem will print out the initial comment in the 
# file (which usually contains the description of the problem and its
# classification), and also any parameters that the file can use.
#
# The problems are searched for inside local repositories that are inside
# the directory specified by the environment variable $OPTIM_BENCH.
#
#
# Created by: Ian McInerney
# Created on: December 8, 2017
# Version: 1.0
# Last Modified: December 8, 2017
#
# Revision History:
#   1.0 - Initial Release

# Display help if no arguments are given
if [[ $# -ne 2 ]]; then
  echo 'Usage: ' $0 'problemName problemSet'
  echo ''
  echo 'problemName: The given name of the problem in the set (also the filename without .SIF)'
  echo 'problemSet: The short name for the problem set (e.g. cutest, marosmeszaros)'

  exit 1
fi

# Get the command line arguments
PROBLEM_NAME=$1   # The problem name from the 1st argument
PROBLEM_REPO=$2   # The problem repository is the 2nd argument

# Change the filename to be all uppercase with the .SIF extension
PROBLEM_BASE=$(echo $PROBLEM_NAME | awk '{print toupper($0)}')
PROBLEM_SIF="$PROBLEM_BASE.SIF"

# Navigate to the problem
PROBLEM_PATH="$OPTIM_BENCH/$PROBLEM_REPO"
mkdir -p $PROBLEM_PATH
cd $PROBLEM_PATH

# Check to see if the SIF file exists
if [[ ! -e $PROBLEM_SIF ]]; then
  printf 'Error: %s is not in the local repository\n' $PROBLEM_NAME
else

  # The comment at the top of the file starts with a line that says
  # *     Problem :
  # and ends with a line that says
  # *     classification
  START_INDEX=$(grep -in 'problem :' $PROBLEM_SIF | cut -f1 -d :)
  END_INDEX=$(grep -in 'classification' $PROBLEM_SIF | cut -f1 -d :)

  # Print out the opening comment
  sed ''"$START_INDEX"','"$END_INDEX"'!d' $PROBLEM_SIF

  # Get the parameters the SIF file can take
  printf '\nSIF parameters:\n'
  sifdecoder -show $PROBLEM_SIF
fi
