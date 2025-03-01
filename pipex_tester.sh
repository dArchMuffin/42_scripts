#!/bin/bash

if [[ ! -f pipex ]]; then
  echo "No 'pipex' binary found"
  exit 1
fi

FOLDER=pipex_tester_tmp
LOG_FOLDER=log

mkdir -p $FOLDER
mkdir -p $LOG_FOLDER

PIPEX_FILE1=$FOLDER/pipex_infile
PIPEX_FILE2=$FOLDER/pipex_outfile
PIPEX_OUTPUT=$FOLDER/pipex_output
BASH_FILE1=$FOLDER/bash_infile
BASH_FILE2=$FOLDER/bash_outfile
BASH_OUTPUT=$FOLDER/bash_output

file_output() {
  local FILE1_P=$1
  local CMD1=$2
  local CMD2=$3
  local FILE2_P=$4
  local FILE1_B=$5
  local FILE2_B=$6

  ./pipex "$FILE1_P" "$CMD1" "$CMD2" "$FILE2_P" > "$PIPEX_OUTPUT" 2>&1 
  bash -c "< $FILE1_B $CMD1 | $CMD2 > $FILE2_B" > "$BASH_OUTPUT" 2>&1

  local CHECKED=$(diff -q "$FILE2_P" "$FILE2_B" | wc -l)

  local VALGRIND=$(valgrind --leak-check=full --show-leak-kinds=all --track-fds=yes ./pipex "$FILE1_P" "$CMD1" "$CMD2" "$FILE2_P" 2>&1)
  local LEAKS=$(echo "$VALGRIND" | grep -q "All heap blocks were freed -- no leaks are possible" | wc -l)
  LEAKS+=$(echo "$VALGRIND" | grep -q "ERROR SUMMARY: 0 errors from 0 contexts" | wc -l)
  LEAKS+=$(echo "$VALGRIND" | grep -q "FILE DESCRIPTORS: 0 open at exit" | wc -l)

  if [[ $CHECKED -eq 0 && $LEAKS -eq 0 ]]; then
    echo "OK : ./pipex $FILE1_P $CMD1 $CMD2 $FILE2_P"
  elif [[ $CHECKED -ne 0 && $LEAKS -eq 0 ]]; then
    echo "KO : ./pipex $FILE1_P $CMD1 $CMD2 $FILE2_P"
    local LOG=$LOG_FOLDER/test_$(date +%s).log
    touch $LOG
    {
      echo "PROMPT : ./pipex $FILE1_P $CMD1 $CMD2 $FILE2_P"
      echo "pipex output :"
      echo "pipex infile : $(cat $FILE1_P)"
      echo "pipex outfile : $(cat $FILE2_P)"
      echo "bash output :"
      echo "bash infile : $(cat $FILE1_B)"
      echo "bash outfile : $(cat $FILE2_B)"
      echo "---------------------------------------------------------------------------------"
    } >> "$LOG"
  elif [[ $CHECKED -eq 0 && $LEAKS -ne 0 ]]; then
    echo "LEAKS"
  fi
}

touch $PIPEX_FILE1
touch $PIPEX_FILE2
touch $BASH_FILE1
touch $BASH_FILE2
touch $PIPEX_OUTPUT
touch $BASH_OUTPUT

echo "This is a test file." > $PIPEX_FILE1
echo "This is a test file." > $BASH_FILE1

file_output "$PIPEX_FILE1" "ls -l" "wc -l" "$PIPEX_FILE2" "$BASH_FILE1" "$BASH_FILE2"

rm -rf $FOLDER
