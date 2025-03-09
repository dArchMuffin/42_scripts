#!/bin/bash

GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"

PROMPT_TO_CLEAN="^oelleaum@minishell"

if [[ -z $1 ]]; then
  echo "Usage : ./handy_minishell_tester.sh <cmd1> <cmd2> <cmd3> <cmd4>"
  exit 1
fi

if [[ $1 == 'clean' ]]; then
  rm -rf log
  exit 1
fi

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

# Valgrind : leaks
valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --show-mismatched-frees=yes --track-fds=yes --trace-children=yes ./minishell << EOF 2>&1 | tee log/valgrind_output | grep -v "$PROMPT_TO_CLEAN" > /dev/null
$INPUT
EOF

# STDERR
./minishell << EOF | grep -v "$PROMPT_TO_CLEAN" 2> log/minishell_stderr > /dev/null
$INPUT
EOF

bash << EOF 2> log/bash_stderr > /dev/null
$INPUT
EOF

# Print Result 
if diff -q log/minishell_output log/bash_output > /dev/null; then
  echo -e "STDOUT : ${GREEN}OK${NC}"
else
  echo -e "STDOUT : ${RED}KO${NC}"
  diff log/minishell_output log/bash_output
fi

if diff -q log/minishell_stderr log/bash_stderr > /dev/null; then
  echo -e "STDERR : ${GREEN}OK${NC}"
else
  echo -e "STDERR : ${RED}KO${NC}"
  diff log/minishell_stderr log/bash_stderr
fi


if [[ "$EXIT_CODE_P" -ne "$EXIT_CODE_B" ]]; then
  echo -e "EXIT : ${RED}KO${NC}"
  echo -e "bash : $EXIT_CODE_B\nminishell: $EXIT_CODE_P"
else
  echo -e "EXIT : ${GREEN}OK${NC}"
fi
# echo "Outfile >>"
#

if ! grep -q "LEAK SUMMARY" log/valgrind_output; then
  echo -e "${GREEN}NO LEAKS${NC}"
else
  echo -e "${RED}LEAKS !${NC} : \e]8;;file://$(pwd)/log/valgrind_output\alog/valgrind_output\e]8;;\a"
fi
# echo "Errors val"
# echo "fd"
# echo "childs"
#
# ./muffinette.sh ls cd pwd "cd 42" ls "cd .." "env | grep PATH"
