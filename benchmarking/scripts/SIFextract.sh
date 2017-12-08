#!/bin/bash
#
# This script will extract the problem files from the archive located with
# the .SIF file in the local repository inside the directory specified
# by the environment variable $OPTIM_BENCH
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
if [[ $# -ne 3 ]]; then
  echo 'Usage: ' $0 'problemName problemSet extractPath'
  echo ''
  echo 'problemName: The given name of the problem in the set (also the filename without .SIF)'
  echo 'problemSet: The short name for the problem set (e.g. cutest, marosmeszaros)'
  echo 'extractPath: The directory to store the extracted problem into'

  exit 1
fi

# Get the command line arguments
PROBLEM_NAME=$1   # Get the problem name (which is the base of the filename)
PROBLEM_REPO=$2   # Get the problem repository
EXTRACT_PATH=$3   # The directory to store the extracted problem data

# Change the filename to be all uppercase with the .SIF extension
PROBLEM_BASE=$(echo $PROBLEM_NAME | awk '{print toupper($0)}')
PROBLEM_SIF="$PROBLEM_BASE.SIF"

# Paths and files
PROBLEM_TAR="$PROBLEM_BASE.tar.gz"

# Navigate to the problem
PROBLEM_PATH="$OPTIM_BENCH/$PROBLEM_REPO"
mkdir -p $PROBLEM_PATH
cd $PROBLEM_PATH

# Make sure the archive exists
if [[ -e $PROBLEM_TAR ]]; then

  # Move the tar into the active problem directory and remove existing problems
  printf 'Extracting problem %s into %s...' $PROBLEM_NAME $EXTRACT_PATH
  mkdir -p $EXTRACT_PATH
  cd $EXTRACT_PATH
  rm -f *

  # Extract the new problem into the directory
  cp $PROBLEM_PATH/$PROBLEM_TAR ./
  tar -xf $PROBLEM_TAR
  rm -f $PROBLEM_TAR
  printf '   [OK]\n'
else
  printf 'Error: Archive containing %s does not exist\n' $PROBLEM_NAME
fi
