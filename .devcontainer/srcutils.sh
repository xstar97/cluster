#!/bin/bash

CONFIG_FILE="$HOME/.config/fish/config.fish"
SOURCE_LINE='source $PWD/scripts/utils.sh'
COMMENT_LINE='    # Commands to run in interactive sessions can go here'

# Check if the source line already exists
if grep -Fxq "$SOURCE_LINE" "$CONFIG_FILE"; then
    echo "Line already exists: $SOURCE_LINE"
else
    # Insert the source line after the comment line
    if grep -Fxq "$COMMENT_LINE" "$CONFIG_FILE"; then
        sed -i "/$COMMENT_LINE/a $SOURCE_LINE" "$CONFIG_FILE"
        echo "Line added after comment: $SOURCE_LINE"
    else
        echo "Comment not found. Appending line to end of file."
        echo "$SOURCE_LINE" >> "$CONFIG_FILE"
    fi
fi
