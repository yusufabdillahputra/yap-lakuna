"""Menurunkan ikon semua platform dari master `render.mjs`.

    node tools/brand/render.mjs /tmp/brand
    python3 tools/brand/make_icons.py /tmp/brand

Menulis ikon Android (legacy + adaptive), iOS, macOS, Windows (.ico), web,
dan aset store di docs/rilis/aset/. Jalankan dari mana saja; jalur dihitung
dari lokasi skrip ini.
"""

import json
import re
import sys
from pathlib import Path

from PIL import Image

HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent
APP = REPO / "lakuna_flutter"


def load(src: Path, name: str) -> Image.Image:
    return Image.open(src / name).convert("RGBA")


def save(img: Image.Image, size: int, dest: Path, rgb: bool = False) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    out = img.resize((size, size), Image.LANCZOS)
    if rgb:
        bg = Image.new("RGB", out.size, (255, 255, 255))
        bg.paste(out, mask=out.split()[3])
        out = bg
    out.save(dest, optimize=True)


def main(src: Path) -> None:
    rounded = load(src, "master-rounded.png")
    square = load(src, "master-square.png")
    macos = load(src, "master-macos.png")

    # Android legacy (< 8.0); 8.0+ memakai ikon adaptive (XML).
    res = APP / "android/app/src/main/res"
    for folder, size in {
        "mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192,
    }.items():
        save(rounded, size, res / f"mipmap-{folder}/ic_launcher.png")

    # iOS: kotak penuh tanpa alfa (iOS membulatkan sendiri).
    ios = APP / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    for image in json.loads((ios / "Contents.json").read_text())["images"]:
        base = float(image["size"].split("x")[0])
        scale = int(image["scale"].rstrip("x"))
        save(square, round(base * scale), ios / image["filename"], rgb=True)

    # macOS: kotak membulat dengan margin grid Apple.
    mac = APP / "macos/Runner/Assets.xcassets/AppIcon.appiconset"
    for path in mac.glob("app_icon_*.png"):
        size = int(re.search(r"(\d+)", path.stem).group(1))
        save(macos, size, path)

    # Windows .ico (16–256).
    ico = APP / "windows/runner/resources/app_icon.ico"
    rounded.resize((256, 256), Image.LANCZOS).save(
        ico, sizes=[(s, s) for s in (16, 24, 32, 48, 64, 128, 256)]
    )

    # Web (Fase 2) dan ikon .deb Linux (memakai Icon-512.png).
    web = APP / "web"
    save(rounded, 16, web / "favicon.png")
    save(rounded, 192, web / "icons/Icon-192.png")
    save(rounded, 512, web / "icons/Icon-512.png")
    save(square, 192, web / "icons/Icon-maskable-192.png")
    save(square, 512, web / "icons/Icon-maskable-512.png")

    # Aset store: ikon Play 512 (kotak penuh, Play membulatkan) dan
    # feature graphic 1024×500 tanpa alfa.
    store = REPO / "docs/rilis/aset"
    save(square, 512, store / "ikon-512.png")
    Image.open(src / "feature-graphic.png").convert("RGB").save(
        store / "feature-graphic.png", optimize=True
    )


if __name__ == "__main__":
    main(Path(sys.argv[1]))
