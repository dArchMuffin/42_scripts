#!/bin/bash


# set -x

if [[ ! -f pipex ]]; then
  echo "No 'pipex' binary found"
  exit 1
fi

. error_management.sh 
. file_output_tests.sh

FOLDER=pipex_tester_tmp
LOG_FOLDER=log

mkdir -p $FOLDER
mkdir -p $LOG_FOLDER

PIPEX_FILE1=$FOLDER/pipex_infile
PIPEX_FILE2=$FOLDER/pipex_outfile
PIPEX_OUTPUT_FILE=$FOLDER/pipex_output
BASH_FILE1=$FOLDER/bash_infile
BASH_FILE2=$FOLDER/bash_outfile
BASH_OUTPUT_FILE=$FOLDER/bash_output

touch $PIPEX_FILE1
touch $PIPEX_FILE2
touch $BASH_FILE1
touch $BASH_FILE2
touch $PIPEX_OUTPUT_FILE
touch $BASH_OUTPUT_FILE

echo "This is a test file." > $PIPEX_FILE1
echo "This is a test file." > $BASH_FILE1

# Error_management tests
echo "--- Error_management tests ---"
touch $PIPEX_FILE2
touch $BASH_FILE2
rm $PIPEX_FILE1
rm $BASH_FILE1
error_management "file1 doesn't exists" "$PIPEX_FILE1" "ls" "echo" "$PIPEX_FILE2" "$BASH_FILE1" "$BASH_FILE2"
echo "" > pipex_tester_tmp/pipex_outfile
echo "" > pipex_tester_tmp/bash_outfile
touch $PIPEX_FILE1 
touch $BASH_FILE1 
chmod 000 $PIPEX_FILE1
chmod 000 $BASH_FILE1
error_management "file1 has no permissions" "$PIPEX_FILE1" "ls" "echo" "$PIPEX_FILE2" "$BASH_FILE1" "$BASH_FILE2"
# a completer 
chmod 644 "$PIPEX_FILE1"
chmod 644 "$BASH_FILE1"


# Une fois le pipex fonctionnel :
# file_output "$PIPEX_FILE1" "ls -l" "wc -l" "$PIPEX_FILE2" "$BASH_FILE1" "$BASH_FILE2"

# rm -rf $FOLDER
