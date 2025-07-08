#!/bin/bash

FILE="/etc/default/landscape-server" # Replace with the actual path to your file

# Check if the file exists
if [ ! -f "$FILE" ]; then
    echo "Error: File '$FILE' not found!"
    exit 1
fi

echo "Updating '$FILE'..."

# Replace RUN_ALL="no" with RUN_ALL="yes"
sed -i 's/RUN_ALL="no"/RUN_ALL="yes"/' "$FILE"

# Replace RUN_MSGSERVER="no" with RUN_MSGSERVER="2"
sed -i 's/RUN_MSGSERVER="no"/RUN_MSGSERVER="2"/' "$FILE"

echo "Replacement complete."
