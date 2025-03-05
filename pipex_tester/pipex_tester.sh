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
BASH_FOLDER=$FOLDER/bash
PIPEX_FOLDER=$FOLDER/pipex
PIPEX_INFILE=$PIPEX_FOLDER/infile
BASH_INFILE=$BASH_FOLDER/infile
PIPEX_OUTFILE=$PIPEX_FOLDER/outfile
BASH_OUTFILE=$BASH_FOLDER/outfile

mkdir -p $FOLDER
mkdir -p $BASH_FOLDER
mkdir -p $PIPEX_FOLDER
mkdir -p $LOG_FOLDER

PIPEX_OUTPUT_FILE=$PIPEX_FOLDER/output
BASH_OUTPUT_FILE=$BASH_FOLDER/output

touch $PIPEX_INFILE
touch $BASH_INFILE
touch $PIPEX_OUTFILE
touch $BASH_OUTFILE
touch $PIPEX_OUTPUT_FILE
touch $BASH_OUTPUT_FILE

echo "This is a test file." > $PIPEX_OUTFILE
echo "This is a test file." > $BASH_OUTFILE

# Error_management tests
echo "--- Error_management tests ---"
touch $PIPEX_INFILE
touch $BASH_INFILE
rm $PIPEX_INFILE
rm $BASH_INFILE
error_management "infile doesn't exists" "$PIPEX_INFILE" "ls -l" "wc -l" "$PIPEX_OUTFILE" "ls" "-l" "wc" "-l" "$BASH_INFILE" "$BASH_OUTFILE" "$PIPEX_OUTPUT_FILE" "$BASH_OUTPUT_FILE"
touch $PIPEX_INFILE 
touch $BASH_INFILE 
chmod 000 $PIPEX_INFILE
chmod 000 $BASH_INFILE
error_management "infile has no permissions" "$PIPEX_INFILE" "ls -l" "wc -l" "$PIPEX_OUTFILE" "ls" "-l" "wc" "-l" "$BASH_INFILE" "$BASH_OUTFILE" "$PIPEX_OUTPUT_FILE" "$BASH_OUTPUT_FILE"
chmod 755 "$PIPEX_INFILE"
chmod 755 "$BASH_INFILE"
rm -rf $PIPEX_OUTFILE
rm -rf $BASH_OUTFILE
error_management "outfile doesn't exists" "$PIPEX_INFILE" "ls -l" "wc -l" "$PIPEX_OUTFILE" "ls" "-l" "wc" "-l" "$BASH_INFILE" "$BASH_OUTFILE" "$PIPEX_OUTPUT_FILE" "$BASH_OUTPUT_FILE"
touch $PIPEX_OUTFILE 
touch $BASH_OUTFILE 
chmod 000 $PIPEX_OUTFILE
chmod 000 $BASH_OUTFILE
error_management "outfile has no permissions" "$PIPEX_INFILE" "ls -l" "wc -l" "$PIPEX_OUTFILE" "ls" "-l" "wc" "-l" "$BASH_INFILE" "$BASH_OUTFILE" "$PIPEX_OUTPUT_FILE" "$BASH_OUTPUT_FILE"
chmod 755 "$PIPEX_OUTFILE"
chmod 755 "$BASH_OUTFILE"
error_management "incorrect cmd1" "$PIPEX_INFILE" "lsg -l" "wc -l" "$PIPEX_OUTFILE" "lsg" "-l" "wc" "-l" "$BASH_INFILE" "$BASH_OUTFILE" "$PIPEX_OUTPUT_FILE" "$BASH_OUTPUT_FILE"
error_management "incorrect cmd2" "$PIPEX_INFILE" "ls -l" "wcg -l" "$PIPEX_OUTFILE" "ls" "-l" "wcg" "-l" "$BASH_INFILE" "$BASH_OUTFILE" "$PIPEX_OUTPUT_FILE" "$BASH_OUTPUT_FILE"
# ce test est bon ?
error_management "/dev/urandom as infile" "/dev/urandom" "cat" "sleep 3" "$PIPEX_OUTFILE" "cat" "" "sleep" "3" "/dev/urandom" "$BASH_OUTFILE" "$PIPEX_OUTPUT_FILE" "$BASH_OUTPUT_FILE"
error_management "sleep 5 | sleep 5" "$PIPEX_INFILE" "sleep 5" "sleep 5" "$PIPEX_OUTFILE" "sleep" "5" "sleep" "5" "$PIPEX_OUTFILE" "$BASH_OUTFILE" "$PIPEX_OUTPUT_FILE" "$BASH_OUTPUT_FILE"


# rm -rf $FOLDER
#
# /dev/urandom en infile / outfile
# sleep 5 | sleep 5
# infile cat | cat | ls outfile

# Une fois le pipex fonctionnel :
# file_output "$PIPEX_FILE1" "ls -l" "wc -l" "$PIPEX_FILE2" "$BASH_FILE1" "$BASH_FILE2"

# A faire a la main ? 
# < infile ls -l -a -r -t | wc -l -rgergr > outfile
#./pipex /dev/urandom "cat" "head -2" outfile

# env -i : NON ?
# /bin/ls comme cmd : NON
