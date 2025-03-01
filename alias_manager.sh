#!/bin/bash

if [ "$1" == "add" ]; then
    if [[ $(grep -q $2 ~/.zshrc) ]]; then
        echo "$2 is an existing alias :"
        grep "^alias $2=" ~/.zshrc
    else 
        echo "alias $2='$3'" >> ~/.zshrc
        zsh -c "source ~/.zshrc"
    fi
elif [ "$1" == "list" ]; then
    grep "alias" ~/.zshrc | grep -v "^#"
elif [ "$1" == "rm" ]; then
    if [[ $(grep "^alias $2=" ~/.zshrc | wc -l) == 1 ]]; then
        echo "Alias removed : " 
        grep "^alias $2=" ~/.zshrc
        sed -i "/^alias $2=/d" ~/.zshrc
        zsh -c "source ~/.zshrc"
    else
        echo "Alias '$2' not found."
        echo ""
        grep "alias" ~/.zshrc | grep -v "^#"
    fi
else
    echo "Usage :"
    echo "./alias_manager.sh add <alias_name> <exec>"
    echo "./alias_manager.sh list"
    echo "./alias_manager.sh rm <alias_to_remove>"
fi

