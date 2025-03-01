#!/bin/bash

TMP_FOLDER=push_swap_tester_tmp
FAILED_TESTS_FOLDER=$TMP_FOLDER/failed_tests
LISTS=$TMP_FOLDER/lists
PARSING_TEST_FOLDER=$FAILED_TESTS_FOLDER/parsing
SIZE_TEST_FOLDER=$FAILED_TESTS_FOLDER/size

if [[ $(uname -s) == "Linux" ]]; then
  CHECKER_OS="checker_linux"
else
  CHECKER_OS="checker_Mac"

if [[ ! -f push_swap ]]; then
  echo "No "push_swap" binary found"
  exit
elif [[ ! -f checker_linux ]]; then
  echo "No "checker_linux" binary found"
  exit
elif [ ! -x checker_linux ]; then
  echo "Permission denied ./$CHECKER_OS"
  exit
elif [[ ! -f checker ]]; then
  echo "No "checker" binary found"
  exit
elif [[ ! -f complexity ]]; then
  echo "No "complexity" binary found"
  exit
fi


mkdir $TMP_FOLDER
mkdir $FAILED_TESTS_FOLDER
mkdir $LISTS
mkdir $PARSING_TEST_FOLDER
mkdir $SIZE_TEST_FOLDER

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

# Pas besoin de mettre le checker ? 
# mettre le checker en variable comme ca on peut tester avec le checker linux, mac ou le checker bonus
  OUTPUT=$(./push_swap $args 2>&1 | ./checker_linux $args 2>&1)
  VALGRIND_OUTPUT=$(valgrind --leak-check=full --show-leak-kinds=all ./push_swap $args 2>&1)

  LEAKS=$(echo "$VALGRIND_OUTPUT" | grep "All heap blocks were freed -- no leaks are possible" | wc -l) 
  LEAKS+=$(echo "$VALGRIND_OUTPUT" | grep "ERROR SUMMARY: 0 errors from 0 contexts " | wc -l )
  DIFF=$(diff -q $OUTPUT $EXPECTED_OUTPUT)

  PROMPT="./push_swap $ARGS 2>&1 | ./checker_linux $ARGS 2>&1"
  if [[ $LEAKS == 0 && $DIFF == 0 ]]; then
    echo "OK : $NAME_TEST $PROMPT"
  elif [[ $LEAKS == 1 && $DIFF == 1 ]]; then
    echo "KO & LEAKS : $NAME_TEST $PROMPT"
    echo "KO : $NAME_TEST $PROMPT" >> $PARSING_TEST_FOLDER/KO
    echo "Output : $OUTPUT" >> $PARSING_TEST_FOLDER/KO
    echo "Expected output : $EXPECTED_OUTPUT" >> $PARSING_TEST_FOLDER/KO
    echo "----------------------------------------------------" >> $PARSING_TEST_FOLDER/KO
    echo "LEAKS : $NAME_TEST $PROMPT" >> $PARSING_TEST_FOLDER/LEAKS
    echo "$VALGRIND_OUTPUT" >> $PARSING_TEST_FOLDER/LEAKS
    echo "----------------------------------------------------" >> $PARSING_TEST_FOLDER/LEAKS
  elif [[ $LEAKS == 1 && $DIFF == 0 ]]; then
    echo "LEAKS : $NAME_TEST $PROMPT"
    echo "LEAKS : $NAME_TEST $PROMPT" >> $PARSING_TEST_FOLDER/LEAKS
    echo "$VALGRIND_OUTPUT" >> $PARSING_TEST_FOLDER/LEAKS
    echo "----------------------------------------------------" >> $PARSING_TEST_FOLDER/LEAKS
  elif [[ $LEAKS == 0 && $DIFF == 1 ]]; then
    echo "KO : $NAME_TEST $PROMPT"
    echo "KO : $NAME_TEST $PROMPT" >> $PARSING_TEST_FOLDER/KO
    echo "Output : $OUTPUT" >> $PARSING_TEST_FOLDER/KO
    echo "Expected output : $EXPECTED_OUTPUT" >> $PARSING_TEST_FOLDER/KO
    echo "----------------------------------------------------" >> $PARSING_TEST_FOLDER/KO
  fi
}

lists_test()
{
  SIZE=$1
  generate_random_ints "$SIZE"
  ARGS=$(cat $LISTS/list_size_$SIZE)

  OUTPUT=$(./push_swap $ARGS 2>&1 | ./checker_linux $ARGS 2>&1)
  CHECKER_OUTPUT=$(./push_swap $ARGS 2>&1 | ./checker $ARGS 2>&1)
  VAL=$(valgrind --leak-check=full --show-leak-kinds=all ./push_swap $ARGS 2>&1)

  echo -e "\n------------------- Generated list size = $SIZE -------------------\n" 
  echo -e "\n$test\n$(cat $LISTS/list_size_$SIZE | tr '\n' ' ')\n"

  LEAKS=$(echo "$VAL" | grep "All heap blocks were freed -- no leaks are possible" | wc -l)
  LEAKS+=$(echo "$VAL" | grep "ERROR SUMMARY: 0 errors from 0 contexts " | wc -l )
  CHECKED=$(echo $OUTPUT | grep -v "OK" | wc -l)

  PROMPT="./push_swap \$(cat $LISTS/list_size_$SIZE) 2>&1 | ./checker_linux \$(cat $LISTS/list_size_$SIZE) 2>&1"
  if [[ $LEAKS == 0 && $DIFF == 0 ]]; then
    echo "OK : $NAME_TEST $PROMPT"
  elif [[ $LEAKS == 1 && $DIFF == 1 ]]; then
    echo "KO & LEAKS : $NAME_TEST $PROMPT"
    cp $LISTS/list_size_$SIZE $SIZE_TEST_FOLDER/list_size_$SIZE
    echo "$VAL" >> $SIZE_TEST_FOLDER/leaks_size_$SIZE
  elif [[ $LEAKS == 1 && $DIFF == 0 ]]; then
    echo "LEAKS : $NAME_TEST $PROMPT"
    cp $LISTS/list_size_$SIZE $SIZE_TEST_FOLDER/list_size_$SIZE
    echo "$VAL" >> $SIZE_TEST_FOLDER/leaks_size_$SIZE
  elif [[ $LEAKS == 0 && $DIFF == 1 ]]; then
    echo "KO : $NAME_TEST $PROMPT"
    cp $LISTS/list_size_$SIZE $SIZE_TEST_FOLDER/list_size_$SIZE
    echo "$VAL" >> $SIZE_TEST_FOLDER/leaks_size_$SIZE
  fi
}

bonus_test()
{
  local NAME_TEST="$1"
  local ARGS="$2"
  local INPUT="$3"
  local EXPECTED_OUTPUT="$4"

  OUTPUT=$(echo -n "$INSTRUCTIONS" | ./checker $ARGS 2>&1)
  VALGRIND_OUTPUT=$(echo -n "$INSTRUCTIONS" | valgrind --leak-check=full --show-leak-kinds=all ./checker $ARGS 2>&1)
  
  local CHECKED=$(diff -q "$OUTPUT" "$EXPECTED_OUTPUT")
  local LEAKS=$(echo "$VALGRIND_OUTPUT" | grep -q "All heap blocks were freed -- no leaks are possible")
  LEAKS+=$(echo "$VALGRIND_OUTPUT" | grep -q "ERROR SUMMARY: 0 errors from 0 contexts")
  
  PROMPT="echo -n "$INSTRUCTIONS" | ./checker $ARGS 2>&1"
  if [[ $LEAKS == 0 && $DIFF == 0 ]]; then
    echo "OK : $NAME_TEST $PROMPT"
  elif [[ $LEAKS == 1 && $DIFF == 1 ]]; then
    echo "KO & LEAKS : $NAME_TEST $PROMPT"
    echo "KO : $NAME_TEST $PROMPT" >> $FAILED_TESTS_FOLDER/KO_bonus
    echo "Output : $OUTPUT" >> $FAILED_TESTS_FOLDER/KO_bonus
    echo "Expected output : $EXPECTED_OUTPUT" >> $FAILED_TESTS_FOLDER/KO_bonus
    echo "----------------------------------------------------" >> $FAILED_TESTS_FOLDER/KO_bonus
    echo "LEAKS : $NAME_TEST $PROMPT" >> $FAILED_TESTS_FOLDER/LEAKS
    echo "$VALGRIND_OUTPUT" >> $FAILED_TESTS_FOLDER/LEAKS
    echo "----------------------------------------------------" >> $FAILED_TESTS_FOLDER/KO_bonus
  elif [[ $LEAKS == 1 && $DIFF == 0 ]]; then
    echo "LEAKS : $NAME_TEST $PROMPT"
    echo "LEAKS : $NAME_TEST $PROMPT" >> $FAILED_TESTS_FOLDER/KO_bonus
    echo "$VALGRIND_OUTPUT" >> $FAILED_TESTS_FOLDER/LEAKS
    echo "----------------------------------------------------" >> $FAILED_TESTS_FOLDER/KO_bonus
  elif [[ $LEAKS == 0 && $DIFF == 1 ]]; then
    echo "KO : $NAME_TEST $PROMPT"
    echo "KO : $NAME_TEST $PROMPT" >> $FAILED_TESTS_FOLDER/KO_bonus
    echo "Output : $OUTPUT" >> $FAILED_TESTS_FOLDER/KO_bonus
    echo "Expected output : $EXPECTED_OUTPUT" >> $FAILED_TESTS_FOLDER/KO_bonus
    echo "----------------------------------------------------" >> $FAILED_TESTS_FOLDER/KO_bonus
  fi
}
#
# parsing_test "Empty prompt" ""
# parsing_test "INT_MAX overflow" "2147483648 1"
# parsing_test "INT_MIN underflow" "-2147483649 1"
# parsing_test "LONG_MIN" "-9223372036854775808 1"
# parsing_test "Mixed quoted/unquoted" "\"53 54\" 5 6"
# parsing_test "Non-integer character" "54 57 g 15"
# parsing_test "Invalid number format" "45/85/45/74"
# parsing_test "Duplicate numbers" "1 2 3 2"
# parsing_test "Letters in number" "-2gfd47 1"




# exit si pas de push_swap
# Si pas de checker_linux : parsing seulement 
# Si pas de checker : pas de bonus test 
# Si pas de complexity : pas de perf test
# si non on fait tous les tests

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
#
#   rm -rf tous les dossiers vides
# 
