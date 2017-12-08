#!/bin/bash
#
# This script will fetch the appropriate problem from the desired SIF
# repository and store it locally in a repository inside the directory
# specified by the environment variable $OPTIM_BENCH.
#
#
# Created by: Ian McInerney
# Created on: November 23, 2017
# Version: 1.4
# Last Modified: December 8, 2017
#
# Revision History:
#   1.0 - Initial Release
#   1.1 - Modified to become more general SIF fetching
#   1.2 - Added error checking to wget command
#   1.3 - Added ability to force redownload and rebuild
#   1.4 - Refactored scripts

# Display help if no arguments are given
if [[ $# -ne 4 ]]; then
  echo 'Usage: ' $0 'problemName problemSet URL forceDownload'
  echo ''
  echo 'problemName: The given name of the problem in the set (also the filename without .SIF)'
  echo 'problemSet: The short name for the problem set (e.g. cutest, marosmeszaros)'
  echo 'URL: The base URL of the problem repository to download from'
  echo 'forceDownload: if 1, it forces the redownload of the problem, overwritting the current file'

  exit 1
fi

# Get the command line arguments
PROBLEM_NAME=$1   # The problem name from the 1st argument
PROBLEM_REPO=$2   # The problem repository is the 2nd argument
SET_URL=$3        # The web URL of the problem is the 3rd argument
FORCE=$4          # Should the problem be force rebuilt

# Where the problem repositories are located
PROBLEM_PATH="$OPTIM_BENCH/$PROBLEM_REPO"

# Change the filename to be all uppercase with the .SIF extension
PROBLEM_BASE=$(echo $PROBLEM_NAME | awk '{print toupper($0)}')
PROBLEM_SIF="$PROBLEM_BASE.SIF"

# Navigate to the problem directory
mkdir -p $PROBLEM_PATH
cd $PROBLEM_PATH

# Check to see if the .SIF file already exists in the directory
if [[ ! -e $PROBLEM_SIF ]] || [[ $FORCE == '1' ]]; then
  printf 'Downloading problem %s...' $PROBLEM_NAME

  # Get the .SIF file from the web
  URL="$SET_URL/$PROBLEM_SIF"
  wget -q $URL -O $PROBLEM_SIF

  # Check for wget error and fail if it threw an error
  if [ "$?" -ne 0 ]; then
    printf '   [FAIL]\nError fetching %s, make sure the problem actually exists on the remote server\n' $PROBLEM_NAME
    rm $PROBLEM_SIF
    exit 1
  fi

  printf '   [OK]\n'
else
  printf 'Problem already downloaded\n'
fi
