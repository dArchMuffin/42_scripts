#!/bin/bash

# Edit this for any other shell :
RC_FILE="$HOME/.zshrc"

if [ "$1" == "add" ]; then
    if [[ $(grep -q $2 $RC_FILE) ]]; then
        echo "$2 is an existing alias :"
        grep "^alias $2=" $RC_FILE
    else 
        echo "alias $2='$3'" >> $RC_FILE
        $SHELL -c "source $RC_FILE"
    fi
elif [ "$1" == "list" ]; then
    grep "alias" $RC_FILE | grep -v "^#"
elif [ "$1" == "rm" ]; then
    if [[ $(grep "^alias $2=" $RC_FILE | wc -l) == 1 ]]; then
        echo "Alias removed : " 
        grep "^alias $2=" $RC_FILE
        sed -i "/^alias $2=/d" $RC_FILE
        $SHELL -c "source $RC_FILE"
    else
        echo "Alias '$2' not found."
        echo ""
        grep "alias" $RC_FILE | grep -v "^#"
    fi
else
    echo "Usage :"
    echo "./alias_manager.sh add <alias_name> <exec>"
    echo "./alias_manager.sh list"
    echo "./alias_manager.sh rm <alias_to_remove>"
fi
