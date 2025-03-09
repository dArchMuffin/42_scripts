#!/bin/bash

GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"

PROMPT_TO_CLEAN="^oelleaum@minishell"
LEAKS_FLAG=0

if [[ -z $1 ]]; then
  echo "Usage : ./handy_minishell_tester.sh <cmd1> <cmd2> <cmd3> <cmd4>"
  exit 1
fi

if [[ $(find . -maxdepth 1 -type f -name minishell | wc -l) == 0 ]]; then
  echo "Error : no 'minishell' binary found in current working directory"
  exit 1
fi

if [[ $1 == "--leaks" ]]; then
  LEAKS_FLAG=1;
  shift
fi

if [[ $1 == "clean" ]]; then
  rm -rd log
  exit 1
fi

# ajouter une option :
#   checker Leaks ou pas (plus rapide sans)
#   chercher un executable a l'endroit ou on se trouve

mkdir -p log

INPUT=$(printf "%s\n" "$@")

# STDOUT && Exit CODE 
./minishell << EOF | grep -v "$PROMPT_TO_CLEAN" > log/minishell_output
$INPUT
EOF
EXIT_CODE_P=$?

bash << EOF | grep -v "$PROMPT_TO_CLEAN" > log/bash_output
$INPUT
EOF
EXIT_CODE_B=$?



# STDERR
./minishell << EOF | grep -v "$PROMPT_TO_CLEAN" 2> log/minishell_stderr > /dev/null
$INPUT
EOF

bash << EOF 2> log/bash_stderr > /dev/null
$INPUT
EOF

# Valgrind : leaks
# redir_out
# redir_out append
# redir_in
# redir_in append
#

CLEAN=0

# Print Result 
if diff -q log/minishell_output log/bash_output > /dev/null; then
  echo -e "STDOUT : ${GREEN}OK${NC}"
else
  echo -e "STDOUT : ${RED}KO${NC}"
  CLEAN=1
  diff log/minishell_output log/bash_output
fi

if diff -q log/minishell_stderr log/bash_stderr > /dev/null; then
  echo -e "STDERR : ${GREEN}OK${NC}"
else
  echo -e "STDERR : ${RED}KO${NC}"
  CLEAN=1
  diff log/minishell_stderr log/bash_stderr
fi


if [[ "$EXIT_CODE_P" -ne "$EXIT_CODE_B" ]]; then
  echo -e "EXIT : ${RED}KO${NC}"
  echo -e "bash : $EXIT_CODE_B\nminishell: $EXIT_CODE_P"
  CLEAN=1
else
  echo -e "EXIT : ${GREEN}OK${NC}"
fi

if [[ $LEAKS_FLAG == 1 ]]; then
  . ./muffinette_leaks.sh $INPUT
  CLEAN=1
fi

# ./muffinette.sh ls cd pwd "cd 42" ls "cd .." "env | grep PATH"

if [[ $CLEAN == 0 ]]; then
  rm -rd log
fi
#
