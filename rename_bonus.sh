
#!/bin/bash

if [[ -n $(find . -type d -name "bonus") ]]; then
    cd bonus
    find . -type f \( -name "*.c" -o -name "*.h" \) | while read -r FILE; do
        if [[ ! "$FILE" =~ "_bonus" ]]; then
            FILE_PATH=$(dirname "$FILE")
            NAME=$(basename "$FILE")
            EXTLESS_NAME="${NAME%.*}"
            EXTENSION="${NAME##*.}"

            NEW_NAME="${EXTLESS_NAME}_bonus.${EXTENSION}"
            NEW_PATH="${FILE_PATH}/${NEW_NAME}"

            mv "$FILE" "$NEW_PATH"
            echo "File renamed : $FILE -> $NEW_NAME"
        fi
    done
else
    echo "No 'bonus' folder found"
fi


