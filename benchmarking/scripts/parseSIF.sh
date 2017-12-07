#!/bin/bash
#
# This script will parse a .SIF file into the MATLAB CUTEst framework
# The files required for the mcutest to work will be packaged into a
# .tar.gz archive with the problem name
#
#
# Created by: Ian McInerney
# Created on: November 23, 2017
# Version: 1.2
# Last Modified: December 7, 2017
#
# Revision History:
#   1.0 - Initial Release
#   1.1 - Modified to include SIF parameters
#   1.2 - Added ability to force redownload and rebuild

# Make sure that the cutest program is on the path
CUTEST_EXEC=$(command -v cutest2matlab)
if [ -z $CUTEST_EXEC ]; then
  echo cutest2matlab not found
  return 1
fi

# Get the problem name (which is the base of the filename)
PROBLEM_PATH=$1
PROBLEM_BASE=$2
ACTIVE_PATH=$3
FORCE=$4
SIF_PARAM=$5

# Get the problem's SIF filename
PROBLEM_SIF="$PROBLEM_BASE.SIF"

# Navigate to where the problem is located
CURR_DIR=$(pwd)

# Check to see if a tar archive of the problem exists in the directory
PROBLEM_TAR="$PROBLEM_BASE.tar.gz"
if [[ ! -e $PROBLEM_PATH/$PROBLEM_TAR ]] || [[ -n "$SIF_PARAM" ]] || [[ $FORCE == '1' ]]; then
  # The tar archive isn't here, create it
  echo Compiling problem

  # Test to see if a gcc-4.9 installation exists
  if [[ -e /opt/gcc-4.9 ]]; then
    echo Using gcc-4.9 located at /opt/gcc-4.9
    export PATH=/opt/gcc-4.9:$PATH
  else
    echo Using system default gcc
  fi

  # Navigate to the active problem directory
  cd $ACTIVE_PATH

  # Copy the SIF file
  cp $CURR_DIR/$PROBLEM_PATH/$PROBLEM_SIF ./

  # Create the appropriate files
  if [ -n "$SIF_PARAM" ]; then
    # Pass the SIF decode parameters into the decoder when requested
    echo Decoding using SIF parameters $SIF_PARAM
    runcutest -A "$MYMATLABARCH" -p matlab -D "$PROBLEM_SIF" -param "$SIF_PARAM"
  else
    # No SIF parameters requested, save it to a file as well
    $CUTEST_EXEC "$PROBLEM_SIF"
  fi

  # Create a tar.gz archive of the relevant files
  echo Creating archive of problem files
  rm -f $PROBLEM_SIF
  tar -c * -f $PROBLEM_TAR
  cp $PROBLEM_TAR $CURR_DIR/$PROBLEM_PATH
  
else
  echo Problem already compiled
fi
