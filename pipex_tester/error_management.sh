error_management() {
  local TEST_NAME=$1
  local FILE1_P=$2
  local CMD1=$3
  local CMD2=$4
  local FILE2_P=$5
  local FILE1_B=$6
  local FILE2_B=$7
  local PIPEX_STDERR
  local BASH_STDERR
  local VALGRIND
  local LEAKS
  local CHECKED
  local PIPEX_OUTPUT
  local BASH_OUTPUT

  ./pipex "$FILE1_P" "$CMD1" "$CMD2" "$FILE2_P" > "$PIPEX_OUTPUT_FILE" 2>&1
  PIPEX_STDERR=$?

  bash -c "< $FILE1_B $CMD1 | $CMD2 > $FILE2_B" > "$BASH_OUTPUT_FILE" 2>&1
  BASH_STDERR=$?

  VALGRIND=$(valgrind --leak-check=full --show-leak-kinds=all --track-fds=yes ./pipex "$FILE1_P" "$CMD1" "$CMD2" "$FILE2_P" 2>&1)
  LEAKS=$(echo "$VALGRIND" | grep "All heap blocks were freed -- no leaks are possible" | wc -l)
  LEAKS=$((LEAKS + $(echo "$VALGRIND" | grep "ERROR SUMMARY: 0 errors from 0 contexts" | wc -l)))
  LEAKS=$((LEAKS + $(echo "$VALGRIND" | grep "FILE DESCRIPTORS: 3 open (3 std) at exit" | wc -l)))

  if [[ $1 == "file1 doesn't exists" ]]; then
    echo "" >> $FILE2_P
  fi

  CHECKED=$(diff "$FILE2_P" "$FILE2_B" | wc -l)
  # echo "checked = $CHECKED"

  if [[ $CHECKED -eq 0 && $LEAKS -eq 3 ]]; then
    echo "OK : ./pipex $FILE1_P $CMD1 $CMD2 $FILE2_P | \$? = $PIPEX_STDERR"
  elif [[ $CHECKED -ne 0 && $LEAKS -eq 3 ]]; then
    echo "KO : ./pipex $FILE1_P $CMD1 $CMD2 $FILE2_P | \$? = $PIPEX_STDERR"
    local LOG=$LOG_FOLDER/test_$(date +%s).log
    touch "$LOG"
    {
      echo "PROMPT : ./pipex $FILE1_P $CMD1 $CMD2 $FILE2_P"
      echo "pipex output : $(cat "$PIPEX_OUTPUT_FILE")"
      echo "pipex infile : $(cat "$FILE1_P" 2>&1)"
      echo "pipex outfile : $(cat "$FILE2_P")"
      echo "bash output : $(cat "$BASH_OUTPUT_FILE")"
      echo "bash infile : $(cat "$FILE1_B" 2>&1)"
      echo "bash outfile : $(cat "$FILE2_B")"
      echo "---------------------------------------------------------------------------------"
    } >> "$LOG"
  elif [[ $LEAKS -ne 3 ]]; then
    echo "LEAKS"
  fi
}
