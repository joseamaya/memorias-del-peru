#!/usr/bin/env python3
"""Postproducción del tráiler de *Memorias del Perú — Pachacútec*.

Genera, de forma reproducible:

- Las tarjetas final y de portada (9:16 y 16:9) a partir de un fotograma.
- Los guiones de filtros de ffmpeg con los rótulos en español y los
  subtítulos en inglés ya quemados en la imagen.
- Los archivos .srt en español e inglés.

Uso:
    python3 tools/trailer_post.py --stage all
    python3 tools/trailer_post.py --stage cards
    python3 tools/trailer_post.py --stage filters

Las capturas de origen se generan con `tests/scenes/trailer_capture.tscn`.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageDraw, ImageEnhance, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent.parent
BUILD = ROOT / "build" / "trailer"
IMAGES = BUILD / "img"
FILTERS = BUILD / "filters"
SUBS = BUILD / "subs"
FONT_PATH = ROOT / "shared_assets" / "ui" / "fonts" / "EBGaramond-Variable.ttf"

CREAM = (242, 227, 192, 255)
GOLD = (216, 179, 106, 255)
DIM = (208, 196, 172, 255)

FRAMES_V = ROOT / "build" / "trailer" / "frames_v"
FRAMES_H = ROOT / "build" / "trailer" / "frames_h"

# (inicio, fin, líneas en español, líneas en inglés)
FULL_CARDS: list[tuple[float, float, list[str], list[str]]] = [
    (0.6, 3.6, ["SIGLO XV. LOS ANDES.", "EL CUSCO AÚN NO ES UN IMPERIO."],
     ["15th century. The Andes.", "Cusco is not yet an empire."]),
    (4.2, 6.8, ["UNA LLACTA. UNA NOTICIA.", "UNA DECISIÓN."],
     ["A llacta. News.", "A decision."]),
    (7.2, 9.2, ["TU HERMANO QUIERE IR."], ["Your brother wants to go."]),
    (9.7, 12.8, ["APRENDE LA HONDA."], ["Learn the sling."]),
    (13.2, 14.8, ["LA LLACTA TE NECESITA."], ["The llacta needs you."]),
    (15.2, 17.2, ["NO TODOS QUIEREN RESISTIR."], ["Not all want to resist."]),
    (17.7, 19.8, ["LOS CHANCAS VIENEN."], ["The Chancas are coming."]),
    (20.2, 22.3, ["LA RESPUESTA ESTÁ EN TUS MANOS."],
     ["The answer is in your hands."]),
    (22.7, 28.6, ["DEFIENDE EL CUSCO."], ["Defend Cusco."]),
    (29.2, 31.9, ["CADA DECISIÓN DEJA UNA CASA EN PIE."],
     ["Every decision leaves a house standing."]),
]

SHORT_CARDS: list[tuple[float, float, list[str], list[str]]] = [
    (0.15, 1.5, ["SIGLO XV. LOS ANDES."], ["The Andes, 15th century."]),
    (1.65, 3.0, ["UNA LLACTA. UNA NOTICIA."], ["A llacta. News."]),
    (3.15, 5.5, ["APRENDE LA HONDA."], ["Learn the sling."]),
    (5.65, 7.05, ["TU HERMANO QUIERE IR."], ["Your brother wants to go."]),
    (7.15, 9.05, ["LOS CHANCAS VIENEN."], ["The Chancas are coming."]),
    (9.15, 11.05, ["DEFIENDE EL CUSCO."], ["Defend Cusco."]),
    (11.15, 12.25, ["CADA DECISIÓN DEJA UNA CASA EN PIE."],
     ["Every decision leaves a house standing."]),
]

# Cortes del tráiler corto, en fotogramas a 30 fps.
SHORT_SEGMENTS: list[tuple[int, int]] = [
    (30, 78),    # mirador
    (120, 165),  # plaza
    (288, 363),  # honda
    (522, 567),  # mensajero
    (690, 750),  # emboscada
    (798, 858),  # defensa
    (870, 888),  # acto IV: la casa ausente
    (912, 930),  # acto V: la casa reparada
]

LAYOUT = {
    "v": {
        "size": (1080, 1920),
        "es_size": 56,
        "es_sub_size": 34,
        "es_y": 190,
        "es_sub_y": 262,
        "en_size": 40,
        "en_y": 1396,
        "en_step": 50,
        "title_size": 72,
        "subtitle_size": 30,
        "cta_size": 28,
        "cover_title_y": 0.055,
        "cover_name_y": 0.12,
        "cover_sub_y": 0.18,
    },
    "h": {
        "size": (1920, 1080),
        "es_size": 52,
        "es_sub_size": 31,
        "es_y": 96,
        "es_sub_y": 160,
        "en_size": 33,
        "en_y": 886,
        "en_step": 44,
        "title_size": 84,
        "subtitle_size": 36,
        "cta_size": 32,
        "cover_title_y": 0.075,
        "cover_name_y": 0.18,
        "cover_sub_y": 0.255,
    },
}


def font(size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(FONT_PATH), size)


def centered(draw: ImageDraw.ImageDraw, text: str, face: ImageFont.FreeTypeFont,
             y: int, fill: tuple[int, int, int, int]) -> None:
    left, _top, right, _bottom = draw.textbbox((0, 0), text, font=face)
    x = (draw.im.size[0] - (right - left)) // 2
    draw.text((x + 2, y + 3), text, font=face, fill=(0, 0, 0, 210))
    draw.text((x, y), text, font=face, fill=fill)


def backdrop(path: Path, size: tuple[int, int], blur: float,
             brightness: float) -> Image.Image:
    image = Image.open(path).convert("RGB").resize(size, Image.Resampling.LANCZOS)
    if blur:
        image = image.filter(ImageFilter.GaussianBlur(blur))
    image = ImageEnhance.Brightness(image).enhance(brightness)
    image = ImageEnhance.Color(image).enhance(0.75)
    return image.convert("RGBA")


def gradient(image: Image.Image, top: int, bottom: int) -> Image.Image:
    width, height = image.size
    overlay = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    for y in range(height):
        alpha = 0
        if y < height * 0.32:
            alpha = int(top * (1 - y / (height * 0.32)))
        elif y > height * 0.62:
            alpha = int(bottom * ((y - height * 0.62) / (height * 0.38)))
        if alpha:
            draw.line([(0, y), (width, y)], fill=(8, 6, 4, alpha))
    return Image.alpha_composite(image, overlay)


def endcard(source: Path, key: str, name: str) -> None:
    layout = LAYOUT[key]
    width, height = layout["size"]
    image = backdrop(source, (width, height), 9, 0.58)
    image = gradient(image, top=196, bottom=222)
    draw = ImageDraw.Draw(image)
    draw.line([(width * 0.2, height * 0.29), (width * 0.8, height * 0.29)],
              fill=(226, 190, 116, 255), width=2)
    centered(draw, "MEMORIAS DEL PERÚ", font(layout["title_size"]),
             int(height * 0.33), CREAM)
    centered(draw, "PACHACÚTEC — EL DESPERTAR DEL SOL",
             font(layout["subtitle_size"]), int(height * 0.45),
             (234, 198, 122, 255))
    draw.line([(width * 0.34, height * 0.52), (width * 0.66, height * 0.52)],
              fill=(226, 190, 116, 255), width=1)
    centered(draw, "PRÓXIMAMENTE", font(layout["cta_size"]),
             int(height * 0.575), CREAM)
    centered(draw, "COMING SOON", font(max(22, layout["cta_size"] - 4)),
             int(height * 0.575) + layout["cta_size"] + 14,
             (234, 198, 122, 255))
    centered(draw, "Reconstrucción histórica · A work of historical fiction",
             font(max(21, layout["cta_size"] - 7)), int(height * 0.685),
             (232, 222, 204, 255))
    image.convert("RGB").save(IMAGES / name)
    print("card", IMAGES / name)


def cover(source: Path, key: str, name: str) -> None:
    layout = LAYOUT[key]
    width, height = layout["size"]
    image = backdrop(source, (width, height), 1, 0.82)
    image = gradient(image, top=232, bottom=248)
    draw = ImageDraw.Draw(image)
    centered(draw, "MEMORIAS DEL PERÚ", font(layout["title_size"]),
             int(height * layout["cover_title_y"]), CREAM)
    centered(draw, "PACHACÚTEC", font(int(layout["title_size"] * 0.62)),
             int(height * layout["cover_name_y"]), GOLD)
    centered(draw, "EL DESPERTAR DEL SOL", font(layout["subtitle_size"]),
             int(height * layout["cover_sub_y"]), CREAM)
    centered(draw, "PRÓXIMAMENTE · COMING SOON", font(layout["subtitle_size"]),
             int(height * 0.88), GOLD)
    image.convert("RGB").save(IMAGES / name)
    print("cover", IMAGES / name)


def escape(text: str) -> str:
    return text.replace("\\", "\\\\").replace("'", "’").replace(":", "\\:")


def draw_line(text: str, size: int, y: int, start: float, end: float) -> str:
    return (
        f"drawtext=fontfile={FONT_PATH}:text='{escape(text)}':"
        f"fontcolor=0xF2E3C0:fontsize={size}:"
        f"borderw=4:bordercolor=0x120D09:"
        f"shadowcolor=0x000000@0.7:shadowx=2:shadowy=3:"
        f"x=(w-text_w)/2:y={y}:enable='between(t,{start:.2f},{end:.2f})'"
    )


def text_chain(cards: list[tuple[float, float, list[str], list[str]]],
               key: str) -> str:
    layout = LAYOUT[key]
    chain: list[str] = []
    for start, end, es, en in cards:
        for index, line in enumerate(es):
            size = layout["es_size"] if index == 0 else layout["es_sub_size"]
            y = layout["es_y"] if index == 0 else layout["es_sub_y"]
            chain.append(draw_line(line, size, y, start, end))
        for index, line in enumerate(en):
            chain.append(draw_line(line, layout["en_size"],
                                   layout["en_y"] + index * layout["en_step"],
                                   start, end))
    return ",".join(chain)


GRADE = (
    "curves=preset=medium_contrast,"
    "eq=saturation=1.06:brightness=0.005,"
    "vignette=angle=PI/6"
)


def write_filters() -> None:
    FILTERS.mkdir(parents=True, exist_ok=True)
    for key in ("v", "h"):
        full = (
            "[0:v]" + GRADE + "," + text_chain(FULL_CARDS, key)
            + ",fade=t=in:st=0:d=0.6[v0];\n"
            "[1:v]fade=t=out:st=2.55:d=0.45[v1];\n"
            "[v0][v1]concat=n=2:v=1:a=0[v]"
        )
        (FILTERS / f"full_{key}.txt").write_text(full, encoding="utf-8")

        segments = []
        for index, (start, end) in enumerate(SHORT_SEGMENTS):
            segments.append(
                f"[0:v]trim=start_frame={start}:end_frame={end},"
                f"setpts=PTS-STARTPTS[s{index}]"
            )
        joins = "".join(f"[s{index}]" for index in range(len(SHORT_SEGMENTS)))
        short = (
            ";\n".join(segments) + ";\n"
            + f"{joins}concat=n={len(SHORT_SEGMENTS)}:v=1:a=0,"
            + GRADE + "," + text_chain(SHORT_CARDS, key) + "[vb];\n"
            + "[1:v]fade=t=out:st=2.25:d=0.45[v1];\n"
            + "[vb][v1]concat=n=2:v=1:a=0[v]"
        )
        (FILTERS / f"short_{key}.txt").write_text(short, encoding="utf-8")
    print("filters", FILTERS)


def timestamp(seconds: float) -> str:
    millis = int(round(seconds * 1000))
    hours, millis = divmod(millis, 3_600_000)
    minutes, millis = divmod(millis, 60_000)
    secs, millis = divmod(millis, 1000)
    return f"{hours:02d}:{minutes:02d}:{secs:02d},{millis:03d}"


def write_srt(path: Path, cards: list[tuple[float, float, list[str], list[str]]],
              language: int) -> None:
    blocks: list[str] = []
    for index, (start, end, es, en) in enumerate(cards, start=1):
        lines = es if language == 0 else en
        blocks.append(
            f"{index}\n{timestamp(start)} --> {timestamp(end)}\n"
            + "\n".join(lines) + "\n"
        )
    path.write_text("\n".join(blocks), encoding="utf-8")
    print("srt", path)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--stage", choices=("all", "cards", "filters", "subs"),
                        default="all")
    args = parser.parse_args()

    IMAGES.mkdir(parents=True, exist_ok=True)
    SUBS.mkdir(parents=True, exist_ok=True)

    if args.stage in ("all", "cards"):
        for source, key, title, sub, build in (
            (FRAMES_V / "000935.jpg", "v", 74, 32, endcard),
            (FRAMES_H / "000935.jpg", "h", 86, 38, endcard),
        ):
            if source.exists():
                build(source, key, f"endcard_{'9x16' if key == 'v' else '16x9'}.png")
            else:
                print("skip", source)
        for source, key in ((FRAMES_V / "000560.jpg", "v"),
                            (FRAMES_H / "000560.jpg", "h")):
            if source.exists():
                cover(source, key,
                      f"cover_{'9x16' if key == 'v' else '16x9'}.png")
            else:
                print("skip", source)

    if args.stage in ("all", "filters"):
        write_filters()

    if args.stage in ("all", "subs"):
        write_srt(SUBS / "trailer_35s_es.srt", FULL_CARDS, 0)
        write_srt(SUBS / "trailer_35s_en.srt", FULL_CARDS, 1)
        write_srt(SUBS / "trailer_15s_es.srt", SHORT_CARDS, 0)
        write_srt(SUBS / "trailer_15s_en.srt", SHORT_CARDS, 1)


if __name__ == "__main__":
    main()
