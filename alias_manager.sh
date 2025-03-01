#!/bin/bash
if [ "$1" == "add" ]; then
    echo "alias $2='$3'" >> ~/.bashrc
elif [ "$1" == "list" ]; then
    grep "alias" ~/.bashrc
fi
