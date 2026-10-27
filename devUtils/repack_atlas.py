#!/usr/bin/env python3
import argparse
import io
import json
import math
import os
import re
import sys

from PIL import Image

XML_TAG = re.compile(r'<SubTexture\b(?:"[^"]*"|[^>"])*>')
JSON_SPRITE = re.compile(
    r'("name"\s*:\s*")([^"]*)("\s*,\s*"x"\s*:\s*)\d+(\s*,\s*"y"\s*:\s*)\d+(\s*,\s*"w"\s*:\s*)\d+(\s*,\s*"h"\s*:\s*)\d+(\s*,\s*"rotated"\s*:\s*)(?:true|false)'
)
JSON_SIZE = re.compile(r'("size"\s*:\s*\{\s*"w"\s*:\s*)\d+(\s*,\s*"h"\s*:\s*)\d+')
IMAGE_EXTS = (".webp", ".png")


def attr(tag, name):
    m = re.search(r'\s%s="([^"]*)"' % name, tag)
    return m.group(1) if m else None


def set_attr(tag, name, value):
    return re.sub(r'(\s%s=")[^"]*(")' % name, lambda m: m.group(1) + str(value) + m.group(2), tag, count=1)


def add_attr(tag, name, value):
    if attr(tag, name) is not None:
        return set_attr(tag, name, value)
    return re.sub(r"\s*(/?>)$", lambda m: ' %s="%s" ' % (name, value) + m.group(1) if m.group(1) == "/>" else ' %s="%s">' % (name, value), tag)


def set_rotated(tag, rotated):
    has = attr(tag, "rotated") is not None
    if rotated and has:
        return set_attr(tag, "rotated", "true")
    if rotated:
        return re.sub(r"\s*(/?>)$", lambda m: ' rotated="true" ' + m.group(1) if m.group(1) == "/>" else ' rotated="true">', tag)
    if has:
        return re.sub(r'\s+rotated="[^"]*"', "", tag, count=1)
    return tag


class MaxRects:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.free = [(0, 0, w, h)]

    def place(self, rw, rh, allow_rotate=False):
        best = None
        orients = [(rw, rh, False)]
        if allow_rotate and rw != rh:
            orients.append((rh, rw, True))
        for fx, fy, fw, fh in self.free:
            for w, h, rot in orients:
                if w <= fw and h <= fh:
                    score = (min(fw - w, fh - h), max(fw - w, fh - h), fy, fx, rot)
                    if best is None or score < best[0]:
                        best = (score, fx, fy, w, h, rot)
        if best is None:
            return None
        _, x, y, w, h, rot = best
        self._split(x, y, w, h)
        return x, y, rot

    def _split(self, x, y, w, h):
        kept = []
        fresh = []
        for fx, fy, fw, fh in self.free:
            if x >= fx + fw or x + w <= fx or y >= fy + fh or y + h <= fy:
                kept.append((fx, fy, fw, fh))
                continue
            if x > fx:
                fresh.append((fx, fy, x - fx, fh))
            if x + w < fx + fw:
                fresh.append((x + w, fy, fx + fw - x - w, fh))
            if y > fy:
                fresh.append((fx, fy, fw, y - fy))
            if y + h < fy + fh:
                fresh.append((fx, y + h, fw, fy + fh - y - h))
        survivors = []
        for i, a in enumerate(fresh):
            ax, ay, aw, ah = a
            contained = False
            for b in kept:
                bx, by, bw, bh = b
                if ax >= bx and ay >= by and ax + aw <= bx + bw and ay + ah <= by + bh:
                    contained = True
                    break
            if not contained:
                for j, b in enumerate(fresh):
                    if i == j:
                        continue
                    bx, by, bw, bh = b
                    if ax >= bx and ay >= by and ax + aw <= bx + bw and ay + ah <= by + bh and (a != b or j < i):
                        contained = True
                        break
            if not contained:
                survivors.append(a)
        self.free = kept + survivors


SORTS = {
    "height": lambda r: (-r[2][1], -r[2][0]),
    "width": lambda r: (-r[2][0], -r[2][1]),
    "area": lambda r: (-(r[2][0] * r[2][1]), -r[2][1]),
    "side": lambda r: (-max(r[2]), -min(r[2])),
}


def pack(items, gap, max_w, max_h, allow_rotate=False):
    sizes = [(k, i, (w + gap, h + gap)) for k, (i, w, h) in enumerate(items)]
    total = sum(w * h for _, _, (w, h) in sizes)
    widest = max(w for _, _, (w, h) in sizes)
    lo = max(widest, int(math.sqrt(total)))
    hi = max(lo, max_w + gap)
    cands = sorted({min(hi, max(lo, int(lo * f))) for f in (1.0, 1.05, 1.1, 1.2, 1.3, 1.45, 1.6, 1.8, 2.0, 2.5)} | {hi})
    best = None
    for bw in cands:
        for name, key in SORTS.items():
            bin_ = MaxRects(bw, max_h + gap)
            pos = {}
            ok = True
            for k, i, (w, h) in sorted(sizes, key=key):
                p = bin_.place(w, h, allow_rotate)
                if p is None:
                    ok = False
                    break
                pos[k] = p
            if not ok:
                continue
            uw = max(pos[k][0] + (items[k][2] if pos[k][2] else items[k][1]) for k in pos)
            uh = max(pos[k][1] + (items[k][1] if pos[k][2] else items[k][2]) for k in pos)
            score = (uw * uh, max(uw, uh))
            if best is None or score < best[0]:
                best = (score, uw, uh, pos)
    return best


def load_xml(path):
    text = open(path, encoding="utf-8").read()
    m = re.search(r'imagePath="([^"]*)"', text)
    if not m:
        return None
    img = os.path.join(os.path.dirname(path), m.group(1))
    if not os.path.exists(img):
        stem = os.path.splitext(path)[0]
        for e in IMAGE_EXTS:
            if os.path.exists(stem + e):
                img = stem + e
                break
    tags = XML_TAG.findall(text)
    sprites = []
    for t in tags:
        sprites.append((attr(t, "name"), int(attr(t, "x")), int(attr(t, "y")), int(attr(t, "width")), int(attr(t, "height")), attr(t, "rotated") == "true"))
    return text, img, sprites


def load_json(path):
    text = open(path, encoding="utf-8-sig").read()
    data = json.loads(text)
    img = None
    meta = data.get("meta", {})
    if meta.get("image"):
        img = os.path.join(os.path.dirname(path), meta["image"])
    if img is None or not os.path.exists(img):
        stem = os.path.splitext(path)[0]
        for e in IMAGE_EXTS:
            if os.path.exists(stem + e):
                img = stem + e
                break
    sprites = []
    for s in data["ATLAS"]["SPRITES"]:
        s = s["SPRITE"]
        sprites.append((s["name"], s["x"], s["y"], s["w"], s["h"], bool(s.get("rotated"))))
    return open(path, encoding="utf-8").read(), img, sprites


def encode(im, path):
    buf = io.BytesIO()
    if path.lower().endswith(".webp"):
        im.save(buf, "WEBP", lossless=True, quality=100, method=6, exact=True)
    else:
        im.save(buf, "PNG", optimize=True)
    return buf.getvalue()


def process(path, gap, apply, allow_rotate, trim):
    is_xml = path.lower().endswith(".xml")
    loaded = load_xml(path) if is_xml else load_json(path)
    if not loaded:
        return "skip: not a texture atlas"
    text, img_path, sprites = loaded
    if not img_path or not os.path.exists(img_path):
        return "skip: image missing"
    if not sprites:
        return "skip: no sprites"
    if len({s[0] for s in sprites}) != len(sprites):
        return "skip: duplicate sprite names"
    sprites = [s for s in sprites if s[3] != 0 and s[4] != 0 or s[3] < 0 or s[4] < 0]
    if not sprites:
        return "keep: only empty sprites"

    src = Image.open(img_path).convert("RGBA")
    W, H = src.size
    orig_w, orig_h = W, H
    old_area = W * H
    rects = {}
    for name, x, y, w, h, _ in sprites:
        if w <= 0 or h <= 0 or x < 0 or y < 0:
            return "skip: invalid sprite rect (negative size or position)"
    ext_w = max(W, max(x + w for _, x, y, w, h, _ in sprites))
    ext_h = max(H, max(y + h for _, x, y, w, h, _ in sprites))
    if (ext_w, ext_h) != (W, H):
        padded = Image.new("RGBA", (ext_w, ext_h), (0, 0, 0, 0))
        padded.paste(src, (0, 0))
        src = padded
        W, H = ext_w, ext_h
    for name, x, y, w, h, rot in sprites:
        rects.setdefault((x, y, w, h, rot), []).append(name)
    keys = list(rects)
    for i, a in enumerate(keys):
        for b in keys[i + 1:]:
            if a[0] < b[0] + b[2] and b[0] < a[0] + a[2] and a[1] < b[1] + b[3] and b[1] < a[1] + a[3]:
                return "skip: partially overlapping sprites"

    trim = trim and is_xml
    crops = {}
    seen = {}
    remap = {}
    shown = {}
    trims = {}
    ntrimmed = 0
    for k in keys:
        c = src.crop((k[0], k[1], k[0] + k[2], k[1] + k[3]))
        if k[4]:
            c = c.transpose(Image.ROTATE_90)
        shown[k] = (c.width, c.height)
        trims[k] = (0, 0)
        if trim:
            box = c.getchannel("A").getbbox()
            if box and box != (0, 0, c.width, c.height):
                trims[k] = (box[0], box[1])
                c = c.crop(box)
                ntrimmed += 1
        sig = (c.width, c.height, c.tobytes())
        if sig in seen:
            remap[k] = seen[sig]
        else:
            seen[sig] = k
            crops[k] = c
    uniq = list(crops)
    items = [(k, crops[k].width, crops[k].height) for k in uniq]
    max_h = min(H * 2, max(H, 4096))
    best = pack(items, gap, W, max_h)
    if allow_rotate:
        alt = pack(items, gap, W, max_h, True)
        if alt is not None and (best is None or alt[0] < best[0]):
            best = alt
    if best is None:
        return "skip: no packing fit"
    _, nw, nh, pos = best
    new_area = nw * nh
    info = "%dx%d -> %dx%d (%.1f%%), %d sprites, %d unique" % (orig_w, orig_h, nw, nh, 100.0 * new_area / old_area, len(keys), len(uniq))
    if ntrimmed:
        info += ", %d trimmed" % ntrimmed
    if new_area >= old_area:
        return "keep: " + info

    newpos = {}
    for idx, k in enumerate(uniq):
        newpos[k] = pos[idx]
    for k, target in remap.items():
        newpos[k] = newpos[target]
    crops_dims = {k: (crops[k].width, crops[k].height) for k in uniq}
    for k, target in remap.items():
        crops_dims[k] = crops_dims[target]

    out = Image.new("RGBA", (nw, nh), (0, 0, 0, 0))
    for k in uniq:
        x, y, rot = newpos[k]
        out.paste(crops[k].transpose(Image.ROTATE_270) if rot else crops[k], (x, y))
    for k in uniq:
        x, y, rot = newpos[k]
        c = crops[k]
        sw, sh = (c.height, c.width) if rot else (c.width, c.height)
        got = out.crop((x, y, x + sw, y + sh))
        if rot:
            got = got.transpose(Image.ROTATE_90)
        if got.tobytes() != c.tobytes():
            return "error: pixel verification failed"

    data = encode(out, img_path)
    old_bytes = os.path.getsize(img_path)
    info += ", %.0fKB -> %.0fKB" % (old_bytes / 1024, len(data) / 1024)

    if not apply:
        return "would repack: " + info

    by_name = {}
    for k, names in rects.items():
        x, y, rot = newpos[k]
        w, h = (crops_dims[k][1], crops_dims[k][0]) if rot else crops_dims[k]
        for n in names:
            by_name.setdefault(n, []).append((x, y, w, h, rot, trims[k], shown[k], crops_dims[k] != shown[k]))
    if is_xml:
        def fix(m):
            t = m.group(0)
            if attr(t, "name") not in by_name:
                return t
            x, y, w, h, rot, (tl, tt), (dw, dh), cut = by_name[attr(t, "name")][0]
            t = set_attr(set_attr(set_attr(set_attr(t, "x", x), "y", y), "width", w), "height", h)
            if cut:
                if attr(t, "frameX") is not None:
                    t = set_attr(t, "frameX", int(attr(t, "frameX")) - tl)
                    t = set_attr(t, "frameY", int(attr(t, "frameY")) - tt)
                else:
                    t = add_attr(add_attr(add_attr(add_attr(t, "frameX", -tl), "frameY", -tt), "frameWidth", dw), "frameHeight", dh)
            return set_rotated(t, rot)
        new_text = XML_TAG.sub(fix, text)
    else:
        counters = {}

        def fix(m):
            n = m.group(2)
            if n not in by_name:
                return m.group(0)
            c = counters.get(n, 0)
            counters[n] = c + 1
            x, y, w, h, rot = by_name[n][c][:5]
            return (m.group(1) + n + m.group(3) + str(x) + m.group(4) + str(y) + m.group(5) + str(w) + m.group(6) + str(h)
                    + m.group(7) + ("true" if rot else "false"))
        new_text = JSON_SPRITE.sub(fix, text)
        if sum(counters.values()) != len(sprites):
            return "error: could not rewrite every sprite entry"
        new_text = JSON_SIZE.sub(lambda m: m.group(1) + str(nw) + m.group(2) + str(nh), new_text)
        json.loads(new_text.lstrip("﻿"))

    with open(img_path, "wb") as f:
        f.write(data)
    with open(path, "w", encoding="utf-8", newline="") as f:
        f.write(new_text)
    return "repacked: " + info


def find_atlases(root):
    for d, _, files in os.walk(root):
        for f in sorted(files):
            low = f.lower()
            if low.endswith(".xml") or (low.startswith("spritemap") and low.endswith(".json")):
                yield os.path.join(d, f)


def main():
    ap = argparse.ArgumentParser(description="Repack sprite atlases losslessly to reduce dead space.")
    ap.add_argument("root", nargs="?", default="assets")
    ap.add_argument("--apply", action="store_true", help="write changes (default is a dry run)")
    ap.add_argument("--gap", type=int, default=2, help="pixels between sprites")
    ap.add_argument("--no-rotate", action="store_true", help="never store sprites rotated 90 degrees")
    ap.add_argument("--no-trim", action="store_true", help="keep transparent borders on XML sprites")
    args = ap.parse_args()

    saved = 0
    for path in find_atlases(args.root):
        print("... %s" % path)
        sys.stdout.flush()
        try:
            res = process(path, args.gap, args.apply, not args.no_rotate, not args.no_trim)
        except Exception as e:
            res = "error: %s" % e
        print("%s: %s" % (path, res))
        sys.stdout.flush()


if __name__ == "__main__":
    main()
