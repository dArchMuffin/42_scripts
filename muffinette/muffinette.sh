#!/bin/sh

GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"

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
./minishell << EOF | grep -v "\[Minishell" > log/minishell_output
$INPUT
EOF
EXIT_CODE_P=$?

bash << EOF | grep -v "\[Minishell" > log/bash_output
$INPUT
EOF
EXIT_CODE_B=$?

# Valgrind 
valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes ./minishell << EOF 2>&1 | tee log/valgrind_output | grep -v "\[Minishell" > /dev/null
$INPUT
EOF

# STDERR
./minishell << EOF | grep -v "\[Minishell" 2> log/minishell_stderr > /dev/null
$INPUT
EOF

bash << EOF 2> log/bash_stderr  > /dev/null
$INPUT
EOF

# Print Result 
if diff -q log/minishell_stderr log/bash_stderr > /dev/null; then
  echo -e "STDERR : ${GREEN}OK${NC}"
else
  echo -e "STDERR : ${RED}KO${NC}"
  diff log/minishell_stderr log/bash_stderr
fi

if diff -q log/minishell_output log/bash_output > /dev/null; then
  echo -e "STDOUT : ${GREEN}OK${NC}"
else
  echo -e "STDOUT : ${RED}KO${NC}"
  diff log/minishell_output log/bash_output
fi

if [[ "$EXIT_CODE_P" -ne "$EXIT_CODE_B" ]]; then
  echo -e "EXIT : ${RED}KO${NC}"
  echo -e "bash : $EXIT_CODE_B\nminishell: $EXIT_CODE_P"
else
  echo -e "EXIT : ${GREEN}OK${NC}"
fi
# echo "Outfile >>"
#

if grep -q "All heap blocks were freed -- no leaks are possible" log/valgrind_output; then
  echo -e "${GREEN}NO LEAKS${NC}"
else
  echo -e "${RED}LEAKS !${NC}"
  cat log/valgrind_output
fi
# echo "Errors val"
# echo "fd"
# echo "childs"
#
# ./muffinette.sh ls cd pwd "cd 42" ls "cd .." "env | grep PATH"
