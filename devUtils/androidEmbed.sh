set -euo pipefail

SRC_DIR="${1:-contents_file}"
DEST_DIR="${2:-android_embed}"

if [ ! -d "$SRC_DIR" ]; then
    echo "Error: source directory '$SRC_DIR' does not exist." >&2
    exit 1
fi

mkdir -p "$DEST_DIR"

SRC_DIR="$(cd "$SRC_DIR" && pwd)"
DEST_DIR="$(cd "$DEST_DIR" && pwd)"

echo "Source: $SRC_DIR"
echo "Dest:   $DEST_DIR"
echo

count=0

while IFS= read -r -d '' file; do
    rel_path="${file#$SRC_DIR/}"

    dest_file="$DEST_DIR/$rel_path"
    dest_subdir="$(dirname "$dest_file")"

    mkdir -p "$dest_subdir"
    cp -p "$file" "$dest_file"

    echo "Copied: $rel_path"
    count=$((count + 1))
done < <(find "$SRC_DIR" -type f \( -name "Animation.json" -o -name "spritemap1.json" \) -print0)

echo
echo "Done. $count file(s) copied."