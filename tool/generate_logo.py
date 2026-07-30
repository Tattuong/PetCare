"""Generate PetCare 3D app icon — premium glossy paw, square 1024x1024."""
from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter

SIZE = 1024
ROOT = Path(__file__).resolve().parents[1]
LOGO = ROOT / "assets" / "logo.png"
ICON = ROOT / "assets" / "icon_foreground.png"

# Brand palette (lavender + green + peach — matches app UI)
BG_TOP = (245, 240, 255)
BG_BOTTOM = (255, 248, 235)
PURPLE = (123, 104, 210)
PURPLE_DARK = (88, 72, 168)
PURPLE_LIGHT = (180, 165, 235)
GREEN = (72, 181, 122)
GREEN_DARK = (45, 140, 95)
GREEN_LIGHT = (140, 225, 175)
ORANGE = (255, 168, 88)
ORANGE_DARK = (230, 130, 55)
WHITE = (255, 255, 255)


def _lerp(a: int, b: int, t: float) -> int:
    return int(a + (b - a) * t)


def _lerp_color(c1: tuple[int, int, int], c2: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    return (_lerp(c1[0], c2[0], t), _lerp(c1[1], c2[1], t), _lerp(c1[2], c2[2], t))


def _vertical_gradient(size: int, top: tuple[int, int, int], bottom: tuple[int, int, int]) -> Image.Image:
    img = Image.new("RGB", (size, size))
    px = img.load()
    for y in range(size):
        t = y / max(size - 1, 1)
        c = _lerp_color(top, bottom, t)
        for x in range(size):
            px[x, y] = c
    return img


def _radial_glow(size: int, center: tuple[float, float], radius: float, color: tuple[int, int, int], alpha: float) -> Image.Image:
    layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    px = layer.load()
    cx, cy = center
    max_a = int(255 * alpha)
    for y in range(size):
        for x in range(size):
            d = math.hypot(x - cx, y - cy)
            if d > radius:
                continue
            t = 1 - d / radius
            a = int(max_a * (t**1.8))
            px[x, y] = (color[0], color[1], color[2], a)
    return layer


def _sphere(size: int, center: tuple[float, float], radius: float, base: tuple[int, int, int], dark: tuple[int, int, int], light: tuple[int, int, int]) -> Image.Image:
    """Glossy 3D sphere with top-left lighting."""
    layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    px = layer.load()
    cx, cy = center
    r = radius
    for y in range(int(cy - r - 8), int(cy + r + 12)):
        if y < 0 or y >= size:
            continue
        for x in range(int(cx - r - 8), int(cx + r + 12)):
            if x < 0 or x >= size:
                continue
            dx = (x - cx) / r
            dy = (y - cy) / r
            d2 = dx * dx + dy * dy
            if d2 > 1.05:
                continue
            if d2 > 1.0:
                # Soft antialiased edge shadow
                px[x, y] = (30, 25, 45, int(40 * (d2 - 1.0) * 20))
                continue
            z = math.sqrt(max(0.0, 1.0 - d2))
            nx, ny, nz = dx, dy, z
            lx, ly, lz = -0.45, -0.55, 0.7
            ln = math.sqrt(lx * lx + ly * ly + lz * lz)
            diffuse = max(0.0, (nx * lx + ny * ly + nz * lz) / ln)
            spec = max(0.0, (nx * 0.2 + ny * -0.6 + nz * 0.75)) ** 28
            t = 0.25 + 0.75 * diffuse
            body = _lerp_color(dark, light if diffuse > 0.55 else base, t)
            spec_amt = int(220 * spec)
            px[x, y] = (
                min(255, body[0] + spec_amt),
                min(255, body[1] + spec_amt),
                min(255, body[2] + spec_amt),
                255,
            )
    return layer


def _drop_shadow(size: int, shape: Image.Image, offset: tuple[int, int] = (0, 18), blur: int = 22, opacity: int = 90) -> Image.Image:
    shadow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    alpha = shape.split()[3]
    black = Image.new("RGBA", shape.size, (25, 20, 40, opacity))
    black.putalpha(alpha)
    shadow.paste(black, offset, black)
    return shadow.filter(ImageFilter.GaussianBlur(blur))


def _compose_paw(size: int) -> Image.Image:
    canvas = _vertical_gradient(size, BG_TOP, BG_BOTTOM).convert("RGBA")

    # Ambient glow blobs
    for center, radius, color, alpha in [
        ((size * 0.35, size * 0.32), size * 0.38, PURPLE_LIGHT, 0.22),
        ((size * 0.72, size * 0.78), size * 0.32, ORANGE, 0.16),
        ((size * 0.5, size * 0.55), size * 0.45, GREEN_LIGHT, 0.10),
    ]:
        canvas = Image.alpha_composite(canvas, _radial_glow(size, center, radius, color, alpha))

    cx, cy = size * 0.5, size * 0.54
    s = size / 1024.0

    paw_layers: list[Image.Image] = []

    # Toe beans (back layer)
    toe_specs = [
        (cx - 118 * s, cy - 118 * s, 56 * s, GREEN, GREEN_DARK, GREEN_LIGHT),
        (cx - 38 * s, cy - 158 * s, 62 * s, GREEN, GREEN_DARK, GREEN_LIGHT),
        (cx + 38 * s, cy - 158 * s, 62 * s, GREEN, GREEN_DARK, GREEN_LIGHT),
        (cx + 118 * s, cy - 118 * s, 56 * s, GREEN, GREEN_DARK, GREEN_LIGHT),
    ]
    for tx, ty, tr, base, dark, light in toe_specs:
        paw_layers.append(_sphere(size, (tx, ty), tr, base, dark, light))

    # Main pad (elliptical via scaled sphere)
    pad = _sphere(size, (cx, cy + 18 * s), 132 * s, PURPLE, PURPLE_DARK, PURPLE_LIGHT)
    pad = pad.resize((int(size * 1.08), int(size * 0.92)), Image.Resampling.LANCZOS)
    pad = pad.crop((
        int(pad.width * 0.04),
        int(pad.height * 0.08),
        int(pad.width * 0.96),
        int(pad.height * 0.92),
    ))
    pad = pad.resize((size, size), Image.Resampling.LANCZOS)
    paw_layers.insert(0, pad)

    # Heart badge (3D orange gem)
    hx, hy = cx + 148 * s, cy - 132 * s
    heart = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    hd = ImageDraw.Draw(heart)
    hr = 46 * s
    hd.ellipse([hx - hr, hy - hr, hx, hy + 8 * s], fill=(*ORANGE_DARK, 255))
    hd.ellipse([hx, hy - hr, hx + hr, hy + 8 * s], fill=(*ORANGE_DARK, 255))
    hd.polygon([(hx - hr, hy), (hx + hr, hy), (hx, hy + hr * 1.35)], fill=(*ORANGE_DARK, 255))
    heart = heart.filter(ImageFilter.GaussianBlur(2))
    gloss = _sphere(size, (hx - 8 * s, hy - 10 * s), 38 * s, ORANGE, ORANGE_DARK, (255, 220, 180))
    heart = Image.alpha_composite(heart, gloss)
    paw_layers.append(heart)

    # Merge paw
    paw = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    for layer in paw_layers:
        paw = Image.alpha_composite(paw, layer)

    # Ground shadow
    shadow_oval = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow_oval)
    sd.ellipse([cx - 200 * s, cy + 120 * s, cx + 200 * s, cy + 190 * s], fill=(40, 30, 60, 70))
    shadow_oval = shadow_oval.filter(ImageFilter.GaussianBlur(16))
    canvas = Image.alpha_composite(canvas, shadow_oval)

    paw_shadow = _drop_shadow(size, paw, offset=(0, int(22 * s)), blur=int(20 * s), opacity=85)
    canvas = Image.alpha_composite(canvas, paw_shadow)
    canvas = Image.alpha_composite(canvas, paw)

    # Subtle vignette
    vig = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    vd = ImageDraw.Draw(vig)
    vd.ellipse([-size * 0.08, -size * 0.08, size * 1.08, size * 1.08], outline=(60, 40, 80, 35), width=int(28 * s))
    canvas = Image.alpha_composite(canvas, vig)

    return canvas.convert("RGB")


def main() -> None:
    LOGO.parent.mkdir(parents=True, exist_ok=True)
    icon = _compose_paw(SIZE)
    for path in (LOGO, ICON):
        icon.save(path, format="PNG", optimize=True)
        print(f"Saved {path} ({SIZE}x{SIZE})")


if __name__ == "__main__":
    main()
