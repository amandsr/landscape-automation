#!/bin/bash

FILE="/etc/default/landscape-server" # Replace with the actual path to your file

# Check if the file exists
if [ ! -f "$FILE" ]; then
    echo "Error: File '$FILE' not found!" >&2 # Redirect to stderr
    exit 1
fi

echo "Updating '$FILE' to change all '=\"no\"' to '=\"yes\"'..."

# Replace all instances of ="no" with ="yes"
# The 'g' flag ensures all occurrences on a line are replaced, not just the first.
sed -i 's/="no"/="yes"/g' "$FILE"

# Replace RUN_MSGSERVER="no" with RUN_MSGSERVER="2"
sed -i 's/RUN_MSGSERVER="no"/RUN_MSGSERVER="2"/' "$FILE"

echo "Replacement complete."
