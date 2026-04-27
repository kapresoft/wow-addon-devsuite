#!/bin/sh
FILE=".emmyrc.json"
# Add a space to change content, then remove it
sleep 2
printf ' ' >> "$FILE" && truncate -s -1 "$FILE"
