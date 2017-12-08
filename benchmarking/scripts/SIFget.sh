#!/bin/bash
#
# This script will fetch the appropriate problem from the desired SIF
# repository, then parse the .SIF into the mcutest format and place it
# into the active problem folder
#
#
# Created by: Ian McInerney
# Created on: November 23, 2017
# Version: 1.3
# Last Modified: December 7, 2017
#
# Revision History:
#   1.0 - Initial Release
#   1.1 - Modified to become more general SIF fetching
#   1.2 - Added error checking to wget command
#   1.3 - Added ability to force redownload and rebuild

PROBLEM_NAME=$1   # The problem name from the 1st argument
PROBLEM_REPO=$2   # The problem repository is the 2nd argument
SET_URL=$3        # The web URL of the problem is the 3rd argument
FORCE=$4          # Should the problem be force rebuilt
SIF_PARAM=$5      # Parameters to pass to SIF decoder (if any)

CURR_DIR=$(pwd)
PROBLEM_PATH="../problems/$PROBLEM_REPO"
ACTIVE_PATH="../problems/activeCUTEst/"

# Change the filename to be all uppercase with the .SIF extension
PROBLEM_BASE=$(echo $PROBLEM_NAME | awk '{print toupper($0)}')
PROBLEM_SIF="$PROBLEM_BASE.SIF"

# Navigate to the problem directory
mkdir -p $PROBLEM_PATH
cd $PROBLEM_PATH

# Check to see if the .SIF file already exists in the directory
if [[ ! -e $PROBLEM_SIF ]] || [[ $FORCE == '1' ]]; then
  echo Downloading problem

  # Get the .SIF file from the web
  URL="$SET_URL/$PROBLEM_SIF"
  wget -q $URL -O $PROBLEM_SIF

  # Check for wget error and fail if it error'd
  if [ "$?" -ne 0 ]; then
    echo Error fetching problem, make sure the problem actually exists on the remote server
    rm $PROBLEM_SIF
    exit 1
  fi
else
  echo Problem already downloaded
fi

cd $CURR_DIR

# Parse the SIF file into the mcutest format
./SIFparse.sh "$PROBLEM_PATH" "$PROBLEM_BASE" "$ACTIVE_PATH" "$FORCE" "$SIF_PARAM"

# Paths and files
PROBLEM_TAR="$PROBLEM_BASE.tar.gz"

# Move the tar into the active problem directory and remove existing problems
echo Extracting problem into active problem directory
mkdir -p $ACTIVE_PATH
cd $ACTIVE_PATH
rm -f *

# Extract the new problem into the directory
cp $CURR_DIR/$PROBLEM_PATH/$PROBLEM_TAR ./
tar -xf $PROBLEM_TAR
rm -f $PROBLEM_TAR
