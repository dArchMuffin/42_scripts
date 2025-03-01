#!/bin/bash

if [[ -z $1 ]] || [[ -z $2 ]]; then
  echo "./eval.sh <repo> <name>"
  exit
fi

git clone $1 $2
cd $2

norminette $(find . -name "*.c" -o -name "*.h") | grep -E "Error|Warning"
make
./$2
code .
