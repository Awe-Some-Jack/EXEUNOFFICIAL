#!/usr/bin/env python3
import argparse
import io
import json
import os
import sys

from PIL import Image

MANIFEST = os.path.join("shared", "data", "image_trims.json")
DEFAULT_EXCLUDES = ["icons", "fonts", "embed", "minigame"]
IMAGE_EXTS = (".png", ".webp")


def atlas_stems(root):
    stems = set()
    for d, _, files in os.walk(root):
        for f in files:
            low = f.lower()
            if low.endswith(".xml"):
                stems.add(os.path.join(d, os.path.splitext(f)[0]))
            elif low.startswith("spritemap") and low.endswith(".json"):
                stems.add(os.path.join(d, os.path.splitext(f)[0]))
                for e in IMAGE_EXTS:
                    stems.add(os.path.join(d, os.path.splitext(f)[0]))
    return stems


def encode(im, path):
    buf = io.BytesIO()
    if path.lower().endswith(".webp"):
        im.save(buf, "WEBP", lossless=True, quality=100, method=6, exact=True)
    else:
        im.save(buf, "PNG", optimize=True)
    return buf.getvalue()


def excluded(rel, excludes):
    parts = rel.replace("\\", "/").split("/")
    return any(e in parts or rel.replace("\\", "/").startswith(e) for e in excludes)


def main():
    ap = argparse.ArgumentParser(description="Trim transparent borders from standalone images and record the offsets for the engine.")
    ap.add_argument("root", nargs="?", default="assets")
    ap.add_argument("--apply", action="store_true", help="write changes (default is a dry run)")
    ap.add_argument("--min-saved", type=int, default=20000, help="skip images that would save fewer pixels than this")
    ap.add_argument("--only", action="append", default=[], help="only touch paths (relative to the root) starting with this; repeatable")
    ap.add_argument("--exclude", action="append", default=None, help="skip paths containing this folder name or starting with this; repeatable (default: %s)" % ", ".join(DEFAULT_EXCLUDES))
    args = ap.parse_args()
    excludes = DEFAULT_EXCLUDES if args.exclude is None else args.exclude

    manifest_path = os.path.join(args.root, MANIFEST)
    manifest = {}
    if os.path.exists(manifest_path):
        manifest = json.load(open(manifest_path, encoding="utf-8"))

    stems = atlas_stems(args.root)
    saved_total = 0
    changed = 0
    for d, dirs, files in os.walk(args.root):
        dirs.sort()
        for f in sorted(files):
            if not f.lower().endswith(IMAGE_EXTS):
                continue
            path = os.path.join(d, f)
            rel = os.path.relpath(path, args.root).replace(os.sep, "/")
            key = os.path.splitext(rel)[0]
            if os.path.join(d, os.path.splitext(f)[0]) in stems:
                continue
            if excluded(rel, excludes):
                continue
            if args.only and not any(rel.startswith(o) for o in args.only):
                continue
            if key in manifest:
                continue
            try:
                im = Image.open(path)
                if im.mode not in ("RGBA", "LA", "PA") and "transparency" not in im.info:
                    continue
                im = im.convert("RGBA")
            except Exception as e:
                print("%s: error: %s" % (rel, e))
                continue
            box = im.getchannel("A").getbbox()
            if box is None:
                continue
            w, h = im.size
            tw, th = box[2] - box[0], box[3] - box[1]
            saved = w * h - tw * th
            if saved < args.min_saved:
                continue

            print("%s: %dx%d -> %dx%d (offset %d,%d, saves %d px)" % (rel, w, h, tw, th, box[0], box[1], saved))
            saved_total += saved
            changed += 1
            if not args.apply:
                continue

            data = encode(im.crop(box), path)
            with open(path, "wb") as fh:
                fh.write(data)
            manifest[key] = [box[0], box[1], w, h, tw, th]

    if args.apply and changed:
        os.makedirs(os.path.dirname(manifest_path), exist_ok=True)
        with open(manifest_path, "w", encoding="utf-8") as fh:
            json.dump(dict(sorted(manifest.items())), fh, indent=1)
    print("%s %d images, %d px saved" % ("trimmed" if args.apply else "would trim", changed, saved_total))


if __name__ == "__main__":
    main()
