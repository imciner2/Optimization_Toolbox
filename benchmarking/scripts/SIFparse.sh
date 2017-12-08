#!/bin/bash
#
# This script will parse a .SIF file into the MATLAB CUTEst framework.
#
# The files created by the sifdecoder will be packaged into a .tar.gz
# archive. That archive will then be stored locally in a repository
# inside the directory specified by the environment variable $OPTIM_BENCH
# (this is the same location as the original .SIF).
#
#
# Created by: Ian McInerney
# Created on: November 23, 2017
# Version: 1.2
# Last Modified: December 8, 2017
#
# Revision History:
#   1.0 - Initial Release
#   1.1 - Modified to include SIF parameters
#   1.2 - Added ability to force redownload and rebuild
#   1.3 - Refactored scripts

# Display help if no arguments are given
if [[ $# -ne 4 ]] && [[ $# -ne 3 ]]; then
  echo 'Usage: ' $0 'problemName problemSet forceDownload [SIFparam]'
  echo ''
  echo 'problemName: The given name of the problem in the set (also the filename without .SIF)'
  echo 'problemSet: The short name for the problem set (e.g. cutest, marosmeszaros)'
  echo 'forceDownload: if 1, it forces the recompilation of the problem, overwritting the current archive'
  echo 'SIFparam: (optional) Contains the parameters to pass to the sifdecoder to use in the SIF file'
  exit 1
fi

# Make sure that the cutest program is on the path
CUTEST_EXEC=$(command -v cutest2matlab)
if [ -z $CUTEST_EXEC ]; then
  echo cutest2matlab not found
  exit 1
fi

# Get the command line arguments
PROBLEM_NAME=$1   # Get the problem name (which is the base of the filename)
PROBLEM_REPO=$2   # Get the problem repository
FORCE=$3          # If the rebuild should be forced or not
SIF_PARAM=$4      # Any parameters to pass to the sif decoder


PROBLEM_PATH="$OPTIM_BENCH/$PROBLEM_REPO"   # Where the problem repositories are located
TEMP_PATH="/tmp/siftemp"                    # The path where the SIF should be parsed
mkdir -p $TEMP_PATH

# Change the filename to be all uppercase with the .SIF extension
PROBLEM_BASE=$(echo $PROBLEM_NAME | awk '{print toupper($0)}')
PROBLEM_SIF="$PROBLEM_BASE.SIF"


# Check to see if a tar archive of the problem exists in the problem directory
PROBLEM_TAR="$PROBLEM_BASE.tar.gz"
if [[ ! -e $PROBLEM_PATH/$PROBLEM_TAR ]] || [[ -n "$SIF_PARAM" ]] || [[ $FORCE == '1' ]]; then
  # Test to see if a gcc-4.9 installation exists
  if [[ -e /opt/gcc-4.9 ]]; then
    printf 'Using gcc-4.9 located at /opt/gcc-4.9\n'
    export PATH=/opt/gcc-4.9:$PATH
  else
    printf 'Using system default gcc\n'
  fi

  # The tar archive isn't here, create it
  printf 'Compiling problem %s...\n' $PROBLEM_BASE

  # Navigate to the active problem directory
  cd $TEMP_PATH

  # Copy the SIF file
  cp $PROBLEM_PATH/$PROBLEM_SIF ./

  # Create the appropriate files
  if [ -n "$SIF_PARAM" ]; then
    # Pass the SIF decode parameters into the decoder when requested
    runcutest -A "$MYMATLABARCH" -p matlab -D "$PROBLEM_SIF" -param "$SIF_PARAM"
  else
    # No SIF parameters requested, save it to a file as well
    $CUTEST_EXEC "$PROBLEM_SIF"
  fi

  if [ ! -e 'ELFUN.f' ]; then
    printf 'Error building MATLAB file for %s\n' $PROBLEM_NAME
    exit 1
  fi

  # Create a tar.gz archive of the relevant files
  rm -f $PROBLEM_SIF
  tar -c * -f $PROBLEM_TAR
  cp $PROBLEM_TAR $PROBLEM_PATH/
  
  printf 'Problem compiled\n'

else
  printf 'Problem already compiled\n'
fi

cd /tmp
rm -rf $TEMP_PATH
