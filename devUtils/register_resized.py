#!/usr/bin/env python3
import argparse
import io
import json
import os
import subprocess
import sys

from PIL import Image, ImageChops, ImageStat

MANIFEST = os.path.join("assets", "shared", "data", "image_trims.json")
EXTS = (".webp", ".png")
DETECT = 8


def git(*args):
    return subprocess.check_output(["git"] + list(args), stderr=subprocess.DEVNULL)


def load_rev(rev, stem):
    for e in EXTS:
        try:
            return Image.open(io.BytesIO(git("show", "%s:%s%s" % (rev, stem, e)))).convert("RGBA")
        except Exception:
            pass
    return None


def load_disk(stem):
    for e in EXTS:
        if os.path.exists(stem + e):
            return Image.open(stem + e).convert("RGBA")
    return None


def previous_size(stem, current, since):
    revs = git("log", "--format=%h", "%s..HEAD" % since, "--", stem + ".webp", stem + ".png").decode().split() + [since]
    for rev in revs:
        im = load_rev(rev, stem)
        if im is not None and im.size != current:
            return rev, im
    return None, None


def flat(im):
    bg = Image.new("RGBA", im.size, (128, 128, 128, 255))
    bg.alpha_composite(im)
    return bg.convert("L")


def diff(a, b):
    return ImageStat.Stat(ImageChops.difference(a, b)).mean[0]


def match(old, new):
    nw, nh = new.size
    ow, oh = old.size
    box = old.getchannel("A").getbbox() or (0, 0, ow, oh)
    cands = set()
    for num, den in ((ow, nw), (oh, nh), (box[2] - box[0], nw), (box[3] - box[1], nh)):
        cands.add(round(num / den, 4))

    target = flat(new)
    small = target.resize((max(1, nw // DETECT), max(1, nh // DETECT)), Image.BILINEAR)
    best = None
    for sc in sorted(cands):
        sw, sh = round(ow / sc), round(oh / sc)
        if sw < nw - 2 or sh < nh - 2:
            continue
        scaled = flat(old.resize((sw, sh), Image.BILINEAR))
        scaled8 = scaled.resize((max(1, sw // DETECT), max(1, sh // DETECT)), Image.BILINEAR)
        bw, bh = small.size
        for dy in range(0, scaled8.height - bh + 1):
            for dx in range(0, scaled8.width - bw + 1):
                e = diff(scaled8.crop((dx, dy, dx + bw, dy + bh)), small)
                if best is None or e < best[0]:
                    best = (e, sc, dx * DETECT, dy * DETECT)
    if best is None:
        return None

    _, sc, dx, dy = best
    sw, sh = round(ow / sc), round(oh / sc)
    scaled = flat(old.resize((sw, sh), Image.BILINEAR))
    half_new = target.resize((max(1, nw // 2), max(1, nh // 2)))
    refined = None
    for ddy in range(-DETECT, DETECT + 1):
        for ddx in range(-DETECT, DETECT + 1):
            x0, y0 = dx + ddx, dy + ddy
            if x0 < 0 or y0 < 0 or x0 + nw > sw + 2 or y0 + nh > sh + 2:
                continue
            e = diff(scaled.crop((x0, y0, x0 + nw, y0 + nh)).resize(half_new.size), half_new)
            if refined is None or e < refined[0]:
                refined = (e, x0, y0)
    if refined is None:
        refined = (best[0], max(0, dx), max(0, dy))
    e, x0, y0 = refined
    return sc, x0 * sc, y0 * sc, e


def main():
    ap = argparse.ArgumentParser(description="Record how resized or cropped stage images map back to their old size, so the engine can keep scripts working unchanged.")
    ap.add_argument("root", nargs="?", default="contents_file")
    ap.add_argument("--only", action="append", default=[], help="only paths (relative to the root) starting with this; repeatable")
    ap.add_argument("--since", default="HEAD~40", help="how far back to look for the previous version of an image")
    ap.add_argument("--max-err", type=float, default=9.0, help="skip images whose best match differs more than this (0-255 scale)")
    ap.add_argument("--apply", action="store_true", help="write entries into the manifest (default is a dry run)")
    ap.add_argument("--force", action="store_true", help="replace entries that already exist")
    args = ap.parse_args()

    manifest = {}
    if os.path.exists(MANIFEST):
        manifest = json.load(open(MANIFEST, encoding="utf-8"))

    prefix = "contents/" if os.path.basename(args.root.rstrip("/")) == "contents_file" else ""
    changed = 0
    for d, dirs, files in os.walk(args.root):
        dirs.sort()
        for f in sorted(files):
            stem_path, ext = os.path.splitext(os.path.join(d, f))
            if ext.lower() not in EXTS:
                continue
            rel = os.path.relpath(stem_path, args.root).replace(os.sep, "/")
            if args.only and not any(rel.startswith(o) for o in args.only):
                continue
            if os.path.exists(stem_path + ".xml") or os.path.exists(os.path.join(d, "Animation.json")):
                continue
            if ext.lower() == ".webp" and os.path.exists(stem_path + ".png") and os.path.getmtime(stem_path + ".png") > os.path.getmtime(stem_path + ".webp"):
                continue
            key = prefix + rel
            if key in manifest and not args.force:
                continue

            new = load_disk(stem_path)
            if new is None:
                continue
            rev, old = previous_size(stem_path, new.size, args.since)
            if old is None:
                continue
            res = match(old, new)
            if res is None:
                print("%s: %s -> %s: no match" % (rel, old.size, new.size))
                continue
            sc, x0, y0, err = res
            note = "ok" if err <= args.max_err else "SKIPPED (poor match)"
            print("%s: %s -> %s (from %s) scale %.4f offset (%.1f, %.1f) err %.1f %s" % (rel, old.size, new.size, rev, sc, x0, y0, err, note))
            if err > args.max_err:
                continue
            changed += 1
            if args.apply:
                manifest[key] = [round(x0, 2), round(y0, 2), old.width, old.height, new.width, new.height, round(sc, 5)]

    if args.apply and changed:
        os.makedirs(os.path.dirname(MANIFEST), exist_ok=True)
        with open(MANIFEST, "w", encoding="utf-8") as fh:
            json.dump(dict(sorted(manifest.items())), fh, indent=1)
    print("%s %d images" % ("recorded" if args.apply else "would record", changed))


if __name__ == "__main__":
    main()
