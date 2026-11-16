#!/usr/bin/env python3
"""Resume la duración por acto de un registro de sesión.

El juego escribe una línea por marca cuando se arranca con `--session <código>`
(ver `core/autoload/session_log.gd`). Este script lee ese registro y calcula
cuánto duró cada acto entre su marca `act` y la del acto siguiente.

Uso:
    python3 tools/session_duration.py PCH-DUR-1
    python3 tools/session_duration.py --file /ruta/sesion.log
    python3 tools/session_duration.py PCH-DUR-1 --json

Los registros viven en `user://sesiones`, que en Linux es
`~/.local/share/godot/app_userdata/Memorias del Perú/sesiones`.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path

STAMP = re.compile(r"^\+(?P<minutes>\d{2}):(?P<seconds>\d{2})\.(?P<millis>\d{3})$")

# Slugs de `SessionLog.mark(&"act", ...)` en el orden de la campaña.
ACTS: tuple[tuple[str, str], ...] = (
    ("llacta", "I — La casa que se vacía"),
    ("paso", "II — El paso y la ciudad dividida"),
    ("cusco", "III — La guerra de los chancas"),
    ("posguerra", "IV — El precio de la victoria"),
    ("obra", "V — El nombre nuevo"),
)
END_MARKS: frozenset[str] = frozenset({"act_five_end", "session_end"})

DEFAULT_USER_DIR = Path.home() / ".local/share/godot/app_userdata/Memorias del Perú/sesiones"


@dataclass(frozen=True)
class Mark:
    """Una marca del registro, con su tiempo en milisegundos."""

    milliseconds: int
    event: str
    detail: str


@dataclass(frozen=True)
class ActSpan:
    """Duración de un acto y marcas que la delimitan."""

    slug: str
    label: str
    start: int
    end: int
    closed_by: str

    @property
    def seconds(self) -> float:
        return (self.end - self.start) / 1000.0


def parse_log(text: str) -> list[Mark]:
    """Convierte el contenido de un registro en marcas ordenadas."""
    marks: list[Mark] = []
    for raw in text.splitlines():
        if not raw or raw.startswith("#"):
            continue
        parts = raw.split("\t")
        if len(parts) < 2:
            continue
        match = STAMP.match(parts[0])
        if match is None:
            continue
        milliseconds = (
            int(match.group("minutes")) * 60_000
            + int(match.group("seconds")) * 1_000
            + int(match.group("millis"))
        )
        detail = parts[2] if len(parts) > 2 else ""
        marks.append(Mark(milliseconds, parts[1], detail))
    return marks


def act_spans(marks: list[Mark]) -> list[ActSpan]:
    """Calcula los tramos entre marcas `act`, en el orden de la campaña."""
    starts: dict[str, int] = {}
    for mark in marks:
        if mark.event == "act" and mark.detail not in starts:
            starts[mark.detail] = mark.milliseconds
    ends: dict[str, tuple[int, str]] = {}
    ordered = [slug for slug, _label in ACTS]
    for index, slug in enumerate(ordered):
        start = starts.get(slug)
        if start is None:
            continue
        end: tuple[int, str] | None = None
        for later in ordered[index + 1 :]:
            later_start = starts.get(later)
            if later_start is not None and later_start >= start:
                end = (later_start, "act " + later)
                break
        if end is None:
            for mark in marks:
                if mark.event in END_MARKS and mark.milliseconds >= start:
                    end = (mark.milliseconds, mark.event)
                    break
        if end is not None:
            ends[slug] = end
    spans: list[ActSpan] = []
    for slug, label in ACTS:
        if slug not in starts:
            continue
        end_ms, closed_by = ends.get(slug, (starts[slug], "sin cierre"))
        spans.append(ActSpan(slug, label, starts[slug], end_ms, closed_by))
    return spans


def format_seconds(seconds: float) -> str:
    """Devuelve `MM:SS` redondeado al segundo."""
    total = int(round(seconds))
    return f"{total // 60:02d}:{total % 60:02d}"


def report(spans: list[ActSpan]) -> str:
    """Tabla legible con cada acto y el total."""
    if not spans:
        return "Sin marcas «act»: el registro no contiene una partida por actos."
    lines = ["Acto\tMarca\tInicio\tFin\tDuración"]
    for span in spans:
        lines.append(
            f"{span.label}\t{span.slug}\t{format_seconds(span.start / 1000.0)}"
            f"\t{format_seconds(span.end / 1000.0)}\t{format_seconds(span.seconds)}"
        )
    total = sum(span.seconds for span in spans)
    complete = all(span.closed_by != "sin cierre" for span in spans)
    lines.append(f"Total\t\t\t\t{format_seconds(total)}")
    if not complete:
        lines.append("Aviso: hay actos sin marca de cierre; el total está incompleto.")
    return "\n".join(lines)


def find_log(code: str, directory: Path) -> Path:
    """Busca el registro del código en la carpeta de sesiones."""
    candidate = directory / f"{code}.log"
    if candidate.exists():
        return candidate
    raise FileNotFoundError(f"No existe el registro {candidate}")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Duración por acto de una sesión.")
    parser.add_argument("code", nargs="?", help="código de sesión, por ejemplo PCH-DUR-1")
    parser.add_argument("--file", type=Path, help="ruta directa al registro")
    parser.add_argument("--dir", type=Path, default=DEFAULT_USER_DIR, help="carpeta de sesiones")
    parser.add_argument("--json", action="store_true", help="salida JSON")
    args = parser.parse_args(argv)
    if args.file is not None:
        path = args.file
    elif args.code:
        try:
            path = find_log(args.code, args.dir)
        except FileNotFoundError as error:
            print(error, file=sys.stderr)
            return 1
    else:
        parser.error("indica un código de sesión o --file")
    if not path.exists():
        print(f"No existe el registro {path}", file=sys.stderr)
        return 1
    spans = act_spans(parse_log(path.read_text(encoding="utf-8")))
    if args.json:
        payload = {
            "path": str(path),
            "acts": [
                {
                    "slug": span.slug,
                    "label": span.label,
                    "seconds": round(span.seconds, 3),
                    "closed_by": span.closed_by,
                }
                for span in spans
            ],
            "total_seconds": round(sum(span.seconds for span in spans), 3),
        }
        print(json.dumps(payload, ensure_ascii=False, indent=2))
        return 0
    print(report(spans))
    return 0


if __name__ == "__main__":
    sys.exit(main())
