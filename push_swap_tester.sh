#!/bin/bash

TMP_FOLDER=push_swap_tmp
FAILED_TESTS_FOLDER=$TMP_FOLDER/failed_tests
LISTS=$TMP_LISTS/lists_log

mkdir $TMP_FOLDER
mkdir $FAILED_TESTS_FOLDER
mkdir $LISTS

generate_random_ints()
{
  i=0
  while ((i < $1)); do
    echo "$(od -An -N4 -t d4 /dev/urandom | tr -d ' ')" > $LISTS/list_size_$SIZE
    ((i++))
  done
}

parsing_test()
{
  local NAME_TEST="$1"
  shift
  local EXPECTED_OUTPUT="$2"
  shift
  local ARGS="$@"

  OUTPUT=$(./push_swap $args 2>&1 | ./checker_linux $args 2>&1)
  VALGRIND_OUTPUT=$(valgrind --leak-check=full --show-leak-kinds=all ./push_swap $args 2>&1)

  LEAKS=$(echo "$VALGRIND_OUTPUT" | grep "All heap blocks were freed -- no leaks are possible" | wc -l) 
  DIFF=$(diff -q $(echo $OUTPUT) $EXPECTED_OUTPUT)

  # remplir les logs files 
  if [[ $LEAKS == 0 && $DIFF == 0 ]]; then
    echo "OK : $NAME_TEST"
  elif [[ $LEAKS == 1 && $DIFF == 1 ]]; then
    echo "KO & LEAKS : $NAME_TEST"
  elif [[ $LEAKS == 1 && $DIFF == 0 ]]; then
    echo "LEAKS : $NAME_TEST"
  elif [[ $LEAKS == 0 && $DIFF == 1 ]]; then
    echo "KO : $NAME_TEST"
  fi
}

lists_test()
{
  SIZE=$1
  generate_random_ints "$SIZE"

}

bonus_test()
{

}

# if push_swap found 
# parsing_test "Test_name" "input" "expected output"
#
# if checker_linux found
#   lists_test "size" "bonus check ?"
# else 
#   no checker_linux found
#
#if checker found 
# bonus test "Test_name" "input" "instructions" "expected output"
#else
# no checker found
#
#if complexity found
# run complexity
#else 
# no complexity found
