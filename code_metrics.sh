#!/bin/bash
echo "Lines of code: $(find . -name "*.c" -o -name "*.h" | xargs wc -l | tail -n 1)"
echo "Comments: $(grep -r "//" . | wc -l)"
