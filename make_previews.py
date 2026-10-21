"""Extract cursor images from .cur/.ani files into docs/previews/ for the README."""
import os
import struct
from PIL import Image

ROOT = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(ROOT, "docs", "previews")
os.makedirs(OUT, exist_ok=True)


def cur_entries(data):
    count = struct.unpack("<H", data[4:6])[0]
    out = []
    for i in range(count):
        w, h, _, _, hx, hy, size, off = struct.unpack("<BBBBHHII", data[6 + 16 * i:22 + 16 * i])
        s = 256 if w == 0 else w
        out.append((s, size, off))
    return out


def cur_to_png_bytes(path):
    d = open(path, "rb").read()
    entries = sorted(cur_entries(d), reverse=True)
    for s, size, off in entries:
        blob = d[off:off + size]
        if blob[:8] == b"\x89PNG\r\n\x1a\n":
            return blob
    # BMP entries: let PIL handle the whole .cur
    im = Image.open(path)
    im.load()
    import io
    buf = io.BytesIO()
    im.save(buf, "PNG")
    return buf.getvalue()


def ani_first_frame_png(path):
    d = open(path, "rb").read()
    pos = d.find(b"fram")
    if pos < 0:
        raise ValueError("no fram")
    icon = d.find(b"icon", pos)
    size = struct.unpack("<I", d[icon + 4:icon + 8])[0]
    cur = d[icon + 8:icon + 8 + size]
    for s, sz, off in sorted(cur_entries(cur), reverse=True):
        blob = cur[off:off + sz]
        if blob[:8] == b"\x89PNG\r\n\x1a\n":
            return blob
    raise ValueError("no png frame")


STAGING = r"E:\05-Ai Sand Box\Kimi\tools\staging\cursor_extract"

jobs = {
    "arrow-teal": (STAGING + "/../cursor_variants/variant_G.png", lambda p: open(p, "rb").read()),
    "arrow-blue": (STAGING + "/png_005.png", lambda p: open(p, "rb").read()),
    "busy": ("cursors/bibata/Busy.ani", ani_first_frame_png),
    "work": ("cursors/bibata/Work.ani", ani_first_frame_png),
    "hand": ("cursors/bibata/Link.cur", cur_to_png_bytes),
    "text": ("cursors/bibata/Text.cur", cur_to_png_bytes),
    "crosshair": ("cursors/bibata/Cross.cur", cur_to_png_bytes),
    "help": ("cursors/bibata/Help.cur", cur_to_png_bytes),
    "unavailable": ("cursors/bibata/Unavailable.cur", cur_to_png_bytes),
    "move": ("cursors/bibata/Move.cur", cur_to_png_bytes),
    "resize-ns": ("cursors/bibata/Vert.cur", cur_to_png_bytes),
    "resize-we": ("cursors/bibata/Horz.cur", cur_to_png_bytes),
    "resize-nwse": ("cursors/bibata/Dgn1.cur", cur_to_png_bytes),
    "resize-nesw": ("cursors/bibata/Dgn2.cur", cur_to_png_bytes),
    "handwriting": ("cursors/bibata/Handwriting.cur", cur_to_png_bytes),
    "up-arrow": ("cursors/bibata/Alternate.cur", cur_to_png_bytes),
    "pin": ("cursors/bibata/Pin.cur", cur_to_png_bytes),
    "person": ("cursors/bibata/Person.cur", cur_to_png_bytes),
}

for name, (rel, fn) in jobs.items():
    png = fn(os.path.join(ROOT, rel))
    open(os.path.join(OUT, name + ".png"), "wb").write(png)
    print("ok", name)

# contact sheet: key shapes on light gray rounded cards
sheet_items = ["arrow-teal", "busy", "work", "hand", "text", "crosshair",
               "help", "unavailable", "move", "resize-nwse", "pin", "person"]
cols = 6
cell = 160
rows = (len(sheet_items) + cols - 1) // cols
sheet = Image.new("RGB", (cols * cell, rows * cell), (242, 243, 245))
for i, name in enumerate(sheet_items):
    im = Image.open(os.path.join(OUT, name + ".png")).convert("RGBA")
    im.thumbnail((110, 110), Image.LANCZOS)
    x = (i % cols) * cell + (cell - im.width) // 2
    y = (i // cols) * cell + (cell - im.height) // 2
    sheet.paste(im, (x, y), im)
sheet.save(os.path.join(OUT, "overview.png"))
print("ok overview", sheet.size)
