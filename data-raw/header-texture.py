# Generates inst/typst/assets/header-texture.png: a faint white golden-angle
# (sunflower) spiral of small diamonds, about 10% opaque, on a transparent
# background. Original work, produced entirely by this script; it does not
# derive from any third-party or institutional brand asset.
#
# Run from the package root: python data-raw/header-texture.py
import math
from PIL import Image, ImageDraw

W, H, K = 600, 400, 4
GOLDEN_ANGLE = math.radians(137.50776)
CX, CY = 285, 185
N_POINTS = 2100
SPACING = 7.9
ALPHA = 26

big = Image.new("L", (W * K, H * K), 0)
draw = ImageDraw.Draw(big)
for i in range(1, N_POINTS):
    r = SPACING * math.sqrt(i)
    theta = i * GOLDEN_ANGLE
    x, y = CX + r * math.cos(theta), CY + r * math.sin(theta)
    if x < -10 or x > W + 10 or y < -10 or y > H + 10:
        continue
    s = 1.15 + 1.45 * min(r / 330.0, 1.0)
    ang = theta + math.pi / 2
    ca, sa = math.cos(ang), math.sin(ang)
    base = [(0, -s * 1.25), (s * 0.8, 0), (0, s * 1.25), (-s * 0.8, 0)]
    draw.polygon(
        [((x + px * ca - py * sa) * K, (y + px * sa + py * ca) * K) for px, py in base],
        fill=255,
    )

mask = big.resize((W, H), Image.LANCZOS)
img = Image.new("RGBA", (W, H), (255, 255, 255, 0))
img.putalpha(mask.point(lambda v: round(v * ALPHA / 255)))
img.save("inst/typst/assets/header-texture.png", optimize=True)
