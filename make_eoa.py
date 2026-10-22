"""Build accessibility-slider (EoA) cursor replacements.

Windows regenerates %LocalAppData%\\Microsoft\\Windows\\Cursors\\*_eoa.cur
from the built-in aero sources every time the user touches
Settings -> Accessibility -> Mouse pointer -> Size, which silently drops the
theme. This script bakes themed versions of all 17 EoA cursors (static .cur,
sizes 48/72/96/144/192, same layout Windows uses). install.ps1 copies them
over the generated ones and watch-eoa.ps1 re-applies them after every slider
move, so the theme survives the size slider.

Run from the repo root:  python make_eoa.py
"""
import io
import os
import struct

from PIL import Image
import resvg_py

ROOT = os.path.dirname(os.path.abspath(__file__))
CURSORS = os.path.join(ROOT, "cursors")
DST = os.path.join(CURSORS, "eoa")
SIZES = [48, 72, 96, 144, 192]

# eoa name -> themed source (static .cur, animated .ani, or the arrow SVG)
STATIC = {
    "helpsel": "bibata/Help.cur",
    "cross": "bibata/Cross.cur",
    "ibeam": "bibata/Text.cur",
    "link": "bibata/Link.cur",
    "ew": "bibata/Horz.cur",
    "ns": "bibata/Vert.cur",
    "nwse": "bibata/Dgn1.cur",
    "nesw": "bibata/Dgn2.cur",
    "move": "bibata/Move.cur",
    "unavail": "bibata/Unavailable.cur",
    "up": "bibata/Alternate.cur",
    "pen": "bibata/Handwriting.cur",
    "person": "bibata/Person.cur",
    "pin": "bibata/Pin.cur",
}
ANIMATED = {
    "busy": "bibata/Work.ani",   # AppStarting
    "wait": "bibata/Busy.ani",   # Wait
}


def largest_cur_entry(data):
    """Return (PIL image, hotspot) of the largest entry of a .cur file."""
    count = struct.unpack("<H", data[4:6])[0]
    best = None
    for i in range(count):
        e = 6 + 16 * i
        w, h, cc, rsv, hx, hy, size, off = struct.unpack("<BBBBHHII", data[e:e + 16])
        w = w or 256
        h = h or 256
        if best is None or w > best[0]:
            best = (w, hx, hy, data[off:off + size])
    w, hx, hy, blob = best
    img = Image.open(io.BytesIO(blob)).convert("RGBA")
    # BMP entries store doubled height (XOR + AND mask)
    if img.size[1] == img.size[0] * 2:
        img = img.crop((0, 0, img.size[0], img.size[0]))
    return img, (hx, hy), w


def first_ani_frame(path):
    data = open(path, "rb").read()
    assert data[:4] == b"RIFF" and data[8:12] == b"ACON"
    pos = 12
    while pos < len(data):
        cid = data[pos:pos + 4]
        size = struct.unpack("<I", data[pos + 4:pos + 8])[0]
        payload = data[pos + 8:pos + 8 + size]
        if cid == b"LIST" and payload[:4] == b"fram":
            inner = payload[4:]
            frame_size = struct.unpack("<I", inner[4:8])[0]
            return inner[8:8 + frame_size]
        pos += 8 + size + (size % 2)
    raise ValueError(f"no frame in {path}")


def build_cur(images_with_hotspots, out_path):
    """images_with_hotspots: list of (size, PIL image, (hx, hy))."""
    entries = []
    for s, img, (hx, hy) in images_with_hotspots:
        buf = io.BytesIO()
        img.save(buf, "PNG")
        entries.append((s, hx, hy, buf.getvalue()))
    header = struct.pack("<HHH", 0, 2, len(entries))
    offset = 6 + 16 * len(entries)
    ent = b""
    blob = b""
    for s, hx, hy, png in entries:
        ent += struct.pack("<BBBBHHII", s, s, 0, 0, hx, hy, len(png), offset)
        blob += png
        offset += len(png)
    with open(out_path, "wb") as f:
        f.write(header + ent + blob)


def bake_from_image(img, ref_size, ref_hotspot, out_path):
    entries = []
    for s in SIZES:
        scaled = img.resize((s, s), Image.LANCZOS)
        hx = round(ref_hotspot[0] * s / ref_size)
        hy = round(ref_hotspot[1] * s / ref_size)
        entries.append((s, scaled, (hx, hy)))
    build_cur(entries, out_path)


def bake_arrow(out_path):
    svg = open(os.path.join(CURSORS, "kimi_arrow.svg"), encoding="utf-8").read()
    entries = []
    for s in SIZES:
        png = bytes(resvg_py.svg_to_bytes(svg_string=svg, width=s, height=s))
        img = Image.open(io.BytesIO(png)).convert("RGBA")
        # reference hotspot: (41, 20) at 256 px
        entries.append((s, img, (round(41 * s / 256), round(20 * s / 256))))
    build_cur(entries, out_path)


def main():
    os.makedirs(DST, exist_ok=True)
    bake_arrow(os.path.join(DST, "arrow_eoa.cur"))
    print("arrow_eoa.cur  <- kimi_arrow.svg (vector, crisp)")
    for name, rel in STATIC.items():
        data = open(os.path.join(CURSORS, rel), "rb").read()
        img, hotspot, ref = largest_cur_entry(data)
        bake_from_image(img, ref, hotspot, os.path.join(DST, f"{name}_eoa.cur"))
        print(f"{name}_eoa.cur  <- {rel} (from {ref}px)")
    for name, rel in ANIMATED.items():
        frame = first_ani_frame(os.path.join(CURSORS, rel))
        img, hotspot, ref = largest_cur_entry(frame)
        bake_from_image(img, ref, hotspot, os.path.join(DST, f"{name}_eoa.cur"))
        print(f"{name}_eoa.cur  <- {rel} frame 1 (from {ref}px)")
    print("done ->", DST)


if __name__ == "__main__":
    main()
