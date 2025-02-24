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

  # Pas besoin de mettre le checker ? 
# mettre le checker en variable comme ca on peut tester avec le checker linux, mac ou le checker bonus
  OUTPUT=$(./push_swap $args 2>&1 | ./checker_linux $args 2>&1)
  VALGRIND_OUTPUT=$(valgrind --leak-check=full --show-leak-kinds=all ./push_swap $args 2>&1)

  LEAKS=$(echo "$VALGRIND_OUTPUT" | grep "All heap blocks were freed -- no leaks are possible" | wc -l) 
  LEAKS+=$(echo "$VALGRIND_OUTPUT" | grep "ERROR SUMMARY: 0 errors from 0 contexts " | wc -l )
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
  ARGS=$(cat $LISTS/list_size_$SIZE)

  OUTPUT=$(./push_swap $ARGS 2>&1 | ./checker_linux $ARGS 2>&1)
  CHECKER_OUTPUT=$(./push_swap $ARGS 2>&1 | ./checker $ARGS 2>&1)
  VAL=$(valgrind --leak-check=full --show-leak-kinds=all ./push_swap $ARGS 2>&1)

  echo -e "\n------------------- Generated list size = $SIZE -------------------\n" 
  echo -e "\n$test\n$(cat $LISTS/list_size_$SIZE | tr '\n' ' ')\n"

  LEAKS=$(echo "$VAL" | grep "All heap blocks were freed -- no leaks are possible" | wc -l)
  LEAKS+=$(echo "$VAL" | grep "ERROR SUMMARY: 0 errors from 0 contexts " | wc -l )
  CHECKED=$(echo $OUTPUT | grep -v "OK" | wc -l)

  if [[ LEAKS == 1 && CHECKED == 1 ]]; then
    echo "KO & LEAKS" 
  elif [[ LEAKS == 0 && CHECKED == 1 ]]; then
    echo "KO" 
  elif [[ LEAKS == 1 && CHECKED == 0 ]]; then
    echo "LEAKS" 
  elif [[ LEAKS == 0 && CHECKED == 0 ]]; then
    echo "OK" 
  fi
}

bonus_test()
{

}

# adatape au checker linux / mac
# cas de non permission chmod +x 
if [[ ! -f push_swap ]]; then
  echo "No "push_swap" binary found"
elif [[ ! -f checker_linux ]]; then
  echo "No "checker_linux" binary found"
elif [[ ! -f checker ]]; then
  echo "No "checker" binary found"
elif [[ ! -f complexity ]]; then
  echo "No "complexity" binary found"
fi

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
