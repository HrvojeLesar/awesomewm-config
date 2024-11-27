#!/usr/bin/bash

for file in ./*.gpg; do
    gpg -d -o "${file%.gpg}" "$file"

    if [[ ! -f "$file" ]]; then
        echo "No .gpg files found in $DIR."
        exit 0
    fi
done
