#!/bin/sh

if [ -z "$1" ]; then
    target_dir="$(pwd)"
else
    target_dir="$1"
fi

echo "Optimizing PNG files in: $target_dir"
echo

if ! command -v oxipng >/dev/null 2>&1; then
    echo "ERROR: oxipng not found."
    echo "Please install oxipng (e.g., 'cargo install oxipng' or use your package manager)"
    exit 1
fi

find "$target_dir" -type f -name "*.png" | while IFS= read -r file; do
    echo "Processing: $file"
    oxipng -o 6 --strip safe --alpha "$file"
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to process $file"
    fi
done

echo
echo "Done!"