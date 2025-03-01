#!/bin/bash
grep -r "///" . > docs.txt
echo "# Project Documentation" > README.md
cat docs.txt >> README.md
