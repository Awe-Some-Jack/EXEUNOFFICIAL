#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="${BUILD_DIR:-$ROOT/export/final/switch/bin}"
NRO_NAME="VsSonic.nro"
DEST_SUBDIR="switch/VsSonic"

DRY=0
CHECKSUM=0
NO_CONTENTS=0
NO_UNMOUNT=0
SD=""

usage() {
    echo "Usage: $0 [options] [SD_MOUNT_PATH]"
    echo "  -n, --dry-run       show what would change, copy nothing"
    echo "  --checksum          compare contents by checksum (slow, catches same-size edits)"
    echo "  --nro-only          only copy the NRO, leave contents alone"
    echo "  --no-unmount        do not unmount the card when finished"
    echo "  -h, --help          show this help"
    echo "Without SD_MOUNT_PATH the script looks for a mounted card containing a /switch folder."
}

while [ $# -gt 0 ]; do
    case "$1" in
        -n|--dry-run) DRY=1 ;;
        --checksum) CHECKSUM=1 ;;
        --nro-only) NO_CONTENTS=1 ;;
        --no-unmount) NO_UNMOUNT=1 ;;
        -h|--help) usage; exit 0 ;;
        -*) echo "Unknown option: $1"; usage; exit 1 ;;
        *) SD="$1" ;;
    esac
    shift
done

if [ ! -f "$BUILD/$NRO_NAME" ]; then
    echo "Build not found: $BUILD/$NRO_NAME"
    echo "Build the Switch target first."
    exit 1
fi

if [ -z "$SD" ]; then
    CANDIDATES=()
    for base in "/media/$USER" "/run/media/$USER" "/mnt"; do
        [ -d "$base" ] || continue
        for dir in "$base"/*/; do
            dir="${dir%/}"
            if [ -d "$dir/switch" ] && { [ -d "$dir/atmosphere" ] || [ -d "$dir/bootloader" ] || [ -f "$dir/hbmenu.nro" ]; }; then
                CANDIDATES+=("$dir")
            fi
        done
    done
    if [ "${#CANDIDATES[@]}" -eq 0 ]; then
        echo "No Switch SD card found. Plug it in, or pass its mount path: $0 /path/to/sd"
        exit 1
    fi
    if [ "${#CANDIDATES[@]}" -gt 1 ]; then
        echo "More than one card found, pass the one you want:"
        printf '  %s\n' "${CANDIDATES[@]}"
        exit 1
    fi
    SD="${CANDIDATES[0]}"
fi

if [ ! -d "$SD/switch" ]; then
    echo "$SD does not look like a Switch SD card (no /switch folder)"
    exit 1
fi

DEST="$SD/$DEST_SUBDIR"
RSYNC_FLAGS=(-rt --modify-window=2 --delete --no-perms --no-owner --no-group)
if [ "$CHECKSUM" -eq 1 ]; then
    RSYNC_FLAGS+=(--checksum)
else
    RSYNC_FLAGS+=(--size-only)
fi

echo "Card:   $SD"
echo "Build:  $BUILD"
echo "Target: $DEST"
[ "$DRY" -eq 1 ] && echo "(dry run, nothing will be written)"

mkdir -p "$DEST"

if [ "$DRY" -eq 1 ]; then
    if cmp -s "$BUILD/$NRO_NAME" "$DEST/$NRO_NAME" 2>/dev/null; then
        echo "NRO: identical, would skip"
    else
        echo "NRO: would copy $(du -h "$BUILD/$NRO_NAME" | cut -f1)"
    fi
else
    if cmp -s "$BUILD/$NRO_NAME" "$DEST/$NRO_NAME" 2>/dev/null; then
        echo "NRO: identical, skipped"
    else
        echo "NRO: copying..."
        cp "$BUILD/$NRO_NAME" "$DEST/$NRO_NAME.new"
        cmp "$BUILD/$NRO_NAME" "$DEST/$NRO_NAME.new"
        mv -f "$DEST/$NRO_NAME.new" "$DEST/$NRO_NAME"
        echo "NRO: copied and verified"
    fi
fi

if [ "$NO_CONTENTS" -eq 0 ] && [ -d "$BUILD/contents" ]; then
    mkdir -p "$DEST/contents"
    if [ "$DRY" -eq 1 ]; then
        echo "contents: changes that would be made:"
        rsync "${RSYNC_FLAGS[@]}" -n --itemize-changes "$BUILD/contents/" "$DEST/contents/" | head -40
    else
        echo "contents: syncing (this can take a while on first run)..."
        rsync "${RSYNC_FLAGS[@]}" --info=stats1 "$BUILD/contents/" "$DEST/contents/" | tail -4
        echo "contents: verifying..."
        LEFT="$(rsync "${RSYNC_FLAGS[@]}" -n --itemize-changes "$BUILD/contents/" "$DEST/contents/" | wc -l)"
        if [ "$LEFT" -ne 0 ]; then
            echo "contents: $LEFT differences remain after sync"
            exit 1
        fi
        echo "contents: verified"
    fi
fi

if [ "$DRY" -eq 1 ]; then
    exit 0
fi

sync
if [ "$NO_UNMOUNT" -eq 0 ]; then
    DEVICE="$(findmnt -n -o SOURCE --target "$SD" || true)"
    if [ -n "$DEVICE" ] && udisksctl unmount -b "$DEVICE" >/dev/null 2>&1; then
        echo "Card unmounted, safe to remove"
    else
        echo "Could not unmount automatically. Eject the card in your file manager before removing it."
    fi
else
    echo "Done. Eject the card before removing it."
fi
