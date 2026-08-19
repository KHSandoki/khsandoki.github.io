#!/usr/bin/env python3
"""Resize, strip EXIF and convert portfolio source photos to WebP.

Sources live outside the repo (archive drives). Re-runnable: skips work when the
output is newer than the source. Run from the repo root:  python tools/build_media.py
"""
import os
import sys
from PIL import Image, ImageOps

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_ROOT = os.path.join(ROOT, "media")

FULL_PX, FULL_Q = 1800, 84
THUMB_PX, THUMB_Q = 800, 76

E = r"E:\舊資料\舊user\Desktop"
D = r"D:"
DEV = r"C:\Users\abcd1\Desktop\Dev"

# slug -> [(output name, source path), ...]  first entry is the hero
MANIFEST = {
    "clauge": [
        ("hero",        rf"{DEV}\Clauge\hero\clauge_readme.jpg"),
        ("bench",       rf"{DEV}\Clauge\img\IMG_7666.JPG"),
    ],
    "rexxar": [
        ("hero",        rf"{D}\2023_06_12\IMG_3533.JPG"),
        ("toolhead",    rf"{D}\2023_06_12\IMG_3531.JPG"),
    ],
    "sym-wolf-125": [
        ("hero",        rf"{D}\2023_06_04\IMG_3510.JPG"),
        ("paint",       rf"{D}\2023_05_17\IMG_3234.JPG"),
    ],
    "illuminator": [
        ("hero",        rf"{E}\遠東創意\_1150897.JPG"),
        ("extruder",    rf"{E}\遠東創意\_1150902.JPG"),
        ("drive-sled",  rf"{E}\專題\相機圖\_1160211.JPG"),
        ("chassis",     rf"{E}\專題\IMG_20180310_223509.jpg"),
        ("electronics", rf"{E}\專題\IMAG1213.jpg"),
        ("machine",     rf"{E}\專題\IMAG1222.jpg"),
        ("conveyor",    rf"{E}\專題\IMAG1210.jpg"),
        ("auto-eject",  rf"{E}\專題\IMAG1191.jpg"),
        ("print-bust",  rf"{E}\專題\_1150633.JPG"),
        ("print-egg",   rf"{E}\專題\相機圖\_1160216.JPG"),
        ("print-hi",    rf"{E}\專題\相機圖\_1160227.JPG"),
        ("plotter",     rf"{E}\Project Illuminator\PHOTO\_1150562.JPG"),
        ("plotter-pen", rf"{E}\Project Illuminator\PHOTO\_1150566.JPG"),
        ("plotter-art", rf"{E}\Project Illuminator\PHOTO\_1150572.JPG"),
    ],
    "airtick": [
        ("hero",        rf"{E}\遠東創意\_1150909.JPG"),
    ],
}


def convert(src, dst, max_px, quality):
    if os.path.exists(dst) and os.path.getmtime(dst) >= os.path.getmtime(src):
        return None
    im = Image.open(src)
    im = ImageOps.exif_transpose(im)          # bake rotation in...
    im = im.convert("RGB")                    # ...then drop every EXIF tag, GPS included
    im.thumbnail((max_px, max_px), Image.LANCZOS)
    clean = Image.new("RGB", im.size)
    clean.putdata(list(im.getdata()))
    clean.save(dst, "WEBP", quality=quality, method=6)
    return os.path.getsize(dst)


def main():
    total = missing = written = 0
    for slug, entries in MANIFEST.items():
        out_dir = os.path.join(OUT_ROOT, slug)
        os.makedirs(out_dir, exist_ok=True)
        for name, src in entries:
            if not os.path.exists(src):
                print(f"  MISSING  {slug}/{name}  <-  {src}")
                missing += 1
                continue
            for suffix, px, q in (("", FULL_PX, FULL_Q), ("@thumb", THUMB_PX, THUMB_Q)):
                dst = os.path.join(out_dir, f"{name}{suffix}.webp")
                size = convert(src, dst, px, q)
                if size is not None:
                    written += 1
                    print(f"  {slug}/{name}{suffix}.webp  {size // 1024} KB")
            total += os.path.getsize(os.path.join(out_dir, f"{name}.webp"))
            total += os.path.getsize(os.path.join(out_dir, f"{name}@thumb.webp"))

    print(f"\n{written} file(s) written, {missing} source(s) missing.")
    print(f"media/ total: {total / 1024 / 1024:.1f} MB")
    return 1 if missing else 0


if __name__ == "__main__":
    sys.exit(main())
