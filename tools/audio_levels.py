#!/usr/bin/env python3
"""Mide niveles de los audios del juego para revisar la mezcla.

Decodifica cada archivo a mono 48 kHz con ffmpeg y calcula pico, RMS y
muestras al límite. Sirve para detectar clips, archivos casi mudos y saltos
grandes entre efectos antes de escucharlos.

Uso:
    python3 tools/audio_levels.py
    python3 tools/audio_levels.py --json
    python3 tools/audio_levels.py shared_assets/audio/respiracion.wav
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path

import numpy as np

AUDIO_DIR = Path(__file__).resolve().parent.parent / "shared_assets" / "audio"
SUFFIXES = {".wav", ".ogg"}
PEAK_LIMIT_DB = -0.5
SILENT_RMS_DB = -40.0
SAMPLE_RATE = 48000


def decode(path: Path) -> np.ndarray:
    """Decodifica el archivo a estéreo float32 con ffmpeg.

    No se baja a mono: sumar canales sube el pico hasta 3 dB y daría falsos
    avisos de clip.
    """
    result = subprocess.run(
        [
            "ffmpeg", "-v", "error", "-i", str(path),
            "-f", "f32le", "-ac", "2", "-ar", str(SAMPLE_RATE), "-",
        ],
        check=True,
        capture_output=True,
    )
    return np.frombuffer(result.stdout, dtype="<f4")


def analyze(path: Path) -> dict[str, object]:
    """Devuelve duración, pico, RMS y muestras al límite."""
    samples = decode(path)
    if samples.size == 0:
        return {"path": str(path), "error": "sin muestras"}
    peak = float(np.max(np.abs(samples)))
    rms = float(np.sqrt(np.mean(samples * samples)))
    peak_db = 20.0 * np.log10(max(peak, 1e-9))
    rms_db = 20.0 * np.log10(max(rms, 1e-9))
    clipped = int(np.count_nonzero(np.abs(samples) >= 0.999))
    return {
        "path": str(path),
        "seconds": round(samples.size / (SAMPLE_RATE * 2), 2),
        "peak_db": round(float(peak_db), 1),
        "rms_db": round(float(rms_db), 1),
        "clipped_samples": clipped,
    }


def report(rows: list[dict[str, object]]) -> str:
    """Tabla legible con avisos de mezcla."""
    lines = ["Archivo\tDuración\tPico\tRMS\tAviso"]
    for row in rows:
        if "error" in row:
            lines.append(f"{Path(str(row['path'])).name}\t—\t—\t—\t{row['error']}")
            continue
        warnings: list[str] = []
        if float(row["peak_db"]) > PEAK_LIMIT_DB:
            warnings.append("pico alto")
        if int(row["clipped_samples"]) > 0:
            warnings.append("clip digital")
        if float(row["rms_db"]) < SILENT_RMS_DB:
            warnings.append("casi mudo")
        lines.append(
            f"{Path(str(row['path'])).name}\t{row['seconds']} s"
            f"\t{row['peak_db']} dB\t{row['rms_db']} dB"
            f"\t{', '.join(warnings) if warnings else 'ok'}"
        )
    return "\n".join(lines)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Niveles de los audios del juego.")
    parser.add_argument("files", nargs="*", type=Path, help="archivos concretos")
    parser.add_argument("--json", action="store_true", help="salida JSON")
    args = parser.parse_args(argv)
    if args.files:
        paths = args.files
    else:
        paths = sorted(
            path for path in AUDIO_DIR.iterdir() if path.suffix.lower() in SUFFIXES
        )
    if not paths:
        print("No hay archivos de audio que medir.", file=sys.stderr)
        return 1
    rows = [analyze(path) for path in paths]
    if args.json:
        print(json.dumps(rows, ensure_ascii=False, indent=2))
    else:
        print(report(rows))
    return 0


if __name__ == "__main__":
    sys.exit(main())
