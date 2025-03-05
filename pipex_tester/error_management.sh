
GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

error_management()
{
  # Pierre : recuperer les variables du script parent ? 
  local TEST_NAME=$1
  local INFILE_P=$2
  local CMD1=$3
  local CMD2=$4
  local OUTFILE_P=$5
  local B_CMD1=$6
  local B_ARGS1=$7
  local B_CMD2=$8
  local B_ARGS2=$9
  local INFILE_B=${10}
  local OUTFILE_B=${11}
  local PIPEX_STDERR
  local BASH_STDERR
  local VALGRIND
  local LEAKS
  local CHECKED
  local PIPEX_OUTPUT=${12}
  local BASH_OUTPUT=${13}

  ./pipex "$INFILE_P" "$CMD1" "$CMD2" "$OUTFILE_P" > "$PIPEX_OUTPUT" 2>&1
  PIPEX_STDERR=$?

  bash -c "< $INFILE_B $B_CMD1 $B_ARGS1 | $B_CMD2 $B_ARGS2 > $OUTFILE_B" 2>/dev/null | sed 's/^bash : [^:]*: //' > "$BASH_OUTPUT" 2>&1
  BASH_STDERR=$?

  VALGRIND=$(valgrind --leak-check=full --show-leak-kinds=all --track-fds=yes ./pipex "$INFILE_P" "$CMD1" "$CMD2" "$OUTFILE_P" 2>&1)
  LEAKS=$(echo "$VALGRIND" | grep "All heap blocks were freed -- no leaks are possible" | wc -l)
  LEAKS=$((LEAKS + $(echo "$VALGRIND" | grep "ERROR SUMMARY: 0 errors from 0 contexts" | wc -l)))
  LEAKS=$((LEAKS + $(echo "$VALGRIND" | grep "FILE DESCRIPTORS: 3 open (3 std) at exit" | wc -l)))

  chmod 755 $OUTFILE_P
  chmod 755 $OUTFILE_B

  CHECKED=$(diff "$OUTFILE_P" "$OUTFILE_B" | wc -l 2>&1)
  if [[ $CHECKED -eq 0 && $LEAKS -ge 3 ]]; then
    echo -e "$GREEN OK$RESET: $TEST_NAME"
  elif [[ $CHECKED -ne 0 && $LEAKS -ge 3 ]]; then
    echo "KO :$TEST_NAME : ./pipex $INFILE_P $CMD1 $CMD2 $OUTFILE_P > $PIPEX_OUTPUT | \$? = $PIPEX_STDERR"
    local LOG=$LOG_FOLDER/test_$(date +%s).log
    touch "$LOG"
    {
      echo "$TEST_NAME : ./pipex $INFILE_P $CMD1 $CMD2 $OUTFILE_P > $PIPEX_OUTPUT"
      echo ""
      echo "pipex output : $(cat "$PIPEX_OUTPUT")"
      echo "bash output : $(cat "$BASH_OUTPUT")"
      echo ""
      echo "pipex infile : $(cat "$FILE1_P" 2>&1)"
      echo "bash infile : $(cat "$FILE1_B" 2>&1)"
      echo ""
      echo "pipex outfile : $(cat "$FILE2_P")"
      echo "bash outfile : $(cat "$FILE2_B")"
      echo "---------------------------------------------------------------------------------"
    } >> "$LOG"
  elif [[ $LEAKS -lt 3 ]]; then
    echo "LEAKS"
    echo -e "$TEST_NAME : ./pipex $INFILE_P $CMD1 $CMD2 $OUTFILE_P > $PIPEX_OUTPUT"
    echo "$VALGRIND" >> "vlog"
 # mettre les logs de valgrind dans logs 
    echo -e "\n---------------------------------------------------------------------------------\n" >> "vlog"
  fi

}
















#
#
#
# error_management() {
#   local TEST_NAME=$1
#   local FILE1_P=$2
#   local CMD1=$3
#   local CMD2=$4
#   local FILE2_P=$5
#   local FILE1_B=$6
#   local FILE2_B=$7
#   local PIPEX_STDERR
#   local BASH_STDERR
#   local VALGRIND
#   local LEAKS
#   local CHECKED
#   local PIPEX_OUTPUT=$8
#   local BASH_OUTPUT=$9
#
#   ./pipex "$FILE1_P" "$CMD1" "$CMD2" "$FILE2_P" > "$PIPEX_OUTPUT" 2>&1
#   PIPEX_STDERR=$?
#
#   # sed a virer ? 
#   bash -c "< $FILE1_B $CMD1 | $CMD2 > $FILE2_B" 2>/dev/null | sed 's/^bash : [^:]*: //' > "$BASH_OUTPUT" 2>&1
#   BASH_STDERR=$?
#
#   VALGRIND=$(valgrind --leak-check=full --show-leak-kinds=all --track-fds=yes ./pipex "$FILE1_P" "$CMD1" "$CMD2" "$FILE2_P" 2>&1)
#   LEAKS=$(echo "$VALGRIND" | grep "All heap blocks were freed -- no leaks are possible" | wc -l)
#   LEAKS=$((LEAKS + $(echo "$VALGRIND" | grep "ERROR SUMMARY: 0 errors from 0 contexts" | wc -l)))
#   LEAKS=$((LEAKS + $(echo "$VALGRIND" | grep "FILE DESCRIPTORS: 3 open (3 std) at exit" | wc -l)))
#
#   chmod 755 $FILE2_P
#   chmod 755 $FILE2_B
#
#   CHECKED=$(diff "$FILE2_P" "$FILE2_B" | wc -l 2>&1)
#   # echo "checked = $CHECKED"
#
#   if [[ $CHECKED -eq 0 && $LEAKS -ge 3 ]]; then
#     echo "OK :$TEST_NAME : ./pipex $FILE1_P $CMD1 $CMD2 $FILE2_P | \$? = $PIPEX_STDERR"
#   elif [[ $CHECKED -ne 0 && $LEAKS -ge 3 ]]; then
#     echo "KO :$TEST_NAME : ./pipex $FILE1_P $CMD1 $CMD2 $FILE2_P | \$? = $PIPEX_STDERR"
#     local LOG=$LOG_FOLDER/test_$(date +%s).log
#     touch "$LOG"
#     {
#       echo "$TEST_NAME : ./pipex $FILE1_P $CMD1 $CMD2 $FILE2_P"
#       echo ""
#       echo "pipex output : $(cat "$PIPEX_OUTPUT")"
#       echo "bash output : $(cat "$BASH_OUTPUT")"
#       echo ""
#       echo "pipex infile : $(cat "$FILE1_P" 2>&1)"
#       echo "bash infile : $(cat "$FILE1_B" 2>&1)"
#       echo ""
#       echo "pipex outfile : $(cat "$FILE2_P")"
#       echo "bash outfile : $(cat "$FILE2_B")"
#       echo "---------------------------------------------------------------------------------"
#     } >> "$LOG"
#   elif [[ $LEAKS -lt 3 ]]; then
#     echo "LEAKS"
#     echo -e "$TEST_NAME : ./pipex $FILE1_P $CMD1 $CMD2 $FILE2_P\n" >> "vlog"
#     echo "$VALGRIND" >> "vlog"
#  # mettre les logs de valgrind dans logs 
#     echo -e "\n---------------------------------------------------------------------------------\n" >> "vlog"
#   fi
# }
