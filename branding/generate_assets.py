#!/usr/bin/env python3
"""Generate NIGHTHAWK OS PNG assets (wallpaper, icons, boot logo)."""
import struct, zlib, os

OUT = os.path.dirname(os.path.abspath(__file__))
os.makedirs(os.path.join(OUT, "png"), exist_ok=True)

def write_png(path, w, h, pixel_fn):
    raw = b""
    for y in range(h):
        raw += b"\x00" + b"".join(bytes(pixel_fn(x, y)) for x in range(w))
    def chunk(t, d):
        c = struct.pack(">I", len(d)) + t + d
        return c + struct.pack(">I", zlib.crc32(t + d) & 0xFFFFFFFF)
    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(raw, 9))
    png += chunk(b"IEND", b"")
    with open(path, "wb") as f:
        f.write(png)

def gradient_png(path, w, h):
    def px(x, y):
        t = y / h
        r = int(6 + (10 - 6) * t)
        g = int(6 + (9 - 6) * t)
        b = int(8 + (12 - 8) * t) + int(6 * t)
        return (r, g, b, 255)
    write_png(path, w, h, px)

def glow_png(path, w, h, cx, cy, max_r, color):
    def px(x, y):
        dx = (x - cx) / max_r
        dy = (y - cy) / max_r
        d = (dx * dx + dy * dy) ** 0.5
        if d > 1.0:
            return (4, 4, 6, 255)
        f = max(0.0, 1.0 - d) ** 2
        return (int(192 * f), int(16 * f), int(38 * f), 255)
    write_png(path, w, h, px)

# Wallpaper: 1280x720 dark gradient + crimson glow
w, h = 1280, 720
def wallpaper_px(x, y):
    t = y / h
    r = int(6 + 4 * t); g = int(6 + 3 * t); b = int(8 + 4 * t)
    dx = (x - 640) / 430.0; dy = (y - 330) / 430.0
    d = (dx * dx + dy * dy) ** 0.5
    glow = max(0.0, 1.0 - d) ** 2 * 0.55
    r = min(255, int(r + 200 * glow)); g = max(0, int(g - 6 * glow)); b = max(0, int(b - 12 * glow))
    return (r, g, b, 255)
write_png(os.path.join(OUT, "png", "nighthawk-wallpaper.png"), w, h, wallpaper_px)

# Boot logo: 512x512 crimson hawk mark on near-black
def boot_px(x, y):
    cx, cy = 256, 300
    d = ((x - cx) / 260.0) ** 2 + ((y - cy) / 300.0) ** 2
    if d > 1.0:
        return (10, 10, 14, 255)
    return (224, 6, 19, 255)
write_png(os.path.join(OUT, "png", "nighthawk-logo.png"), 512, 512, boot_px)

print("NIGHTHAWK PNG assets generated")
