file_output() {
  local FILE1_P=$1
  local CMD1=$2
  local CMD2=$3
  local FILE2_P=$4
  local FILE1_B=$5
  local FILE2_B=$6

  ./pipex "$FILE1_P" "$CMD1" "$CMD2" "$FILE2_P" > "$PIPEX_OUTPUT_FILE" 2>&1 
  bash -c "< $FILE1_B $CMD1 | $CMD2 > $FILE2_B" > "$BASH_OUTPUT_FILE" 2>&1

  local CHECKED=$(diff -q "$FILE2_P" "$FILE2_B" | wc -l)

  # ajouter flag track origin + orphenates pour valgrind 
  local VALGRIND=$(valgrind --leak-check=full --show-leak-kinds=all --track-fds=yes ./pipex "$FILE1_P" "$CMD1" "$CMD2" "$FILE2_P" 2>&1)
  local LEAKS=$(echo "$VALGRIND" | grep "All heap blocks were freed -- no leaks are possible" | wc -l)
  LEAKS+=$(echo "$VALGRIND" | grep "ERROR SUMMARY: 0 errors from 0 contexts" | wc -l)
  LEAKS+=$(echo "$VALGRIND" | grep "FILE DESCRIPTORS: 0 open at exit" | wc -l)

  # revoir les -eq et -ne 
  if [[ $CHECKED -eq 0 && $LEAKS -eq 0 ]]; then
    echo "OK : ./pipex $FILE1_P $CMD1 $CMD2 $FILE2_P"
  elif [[ $CHECKED -ne 0 && $LEAKS -eq 0 ]]; then
    echo "KO : ./pipex $FILE1_P $CMD1 $CMD2 $FILE2_P"
    local LOG=$LOG_FOLDER/test_$(date +%s).log
    touch $LOG
    {
      echo "PROMPT : ./pipex $FILE1_P $CMD1 $CMD2 $FILE2_P"
      echo "pipex output : $PIPEX_OUTPUT_FILE"
      echo "pipex infile : $(cat $FILE1_P)"
      echo "pipex outfile : $(cat $FILE2_P)"
      echo "bash output : $BASH_OUTPUT_FILE"
      echo "bash infile : $(cat $FILE1_B)"
      echo "bash outfile : $(cat $FILE2_B)"
      echo "---------------------------------------------------------------------------------"
    } >> "$LOG"
  elif [[ $CHECKED -eq 0 && $LEAKS -ne 0 ]]; then
    echo "LEAKS"
  fi
}
