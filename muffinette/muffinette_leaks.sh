#!bin/bash

valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --show-mismatched-frees=yes --track-fds=yes --trace-children=yes ./minishell << EOF 2>&1 | tee log/valgrind_output | grep -v "$PROMPT_TO_CLEAN" > /dev/null
$INPUT
EOF

if ! grep -q "LEAK SUMMARY" log/valgrind_output; then
  echo -e "${GREEN}NO LEAKS${NC}"
else
  echo -e "${RED}LEAKS !${NC} : \e]8;;file://$(pwd)/log/valgrind_output\alog/valgrind_output\e]8;;\a"
fi

# echo "Errors val"
# echo "fd"
# echo "childs"
#
