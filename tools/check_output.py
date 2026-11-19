#!/usr/bin/env python3
"""Falla si la salida de Godot trae errores o advertencias de `res://`.

El criterio del proyecto es cero errores y cero advertencias de GDScript
procedentes de `res://`. Los mensajes del motor ajenos a los scripts (por
ejemplo, del controlador de vídeo) no cuentan, pero se ven en el registro.

Uso:
    set -o pipefail
    godot --headless --path . --script res://tests/run_tests.gd 2>&1 | tee /tmp/pruebas.log
    python3 tools/check_output.py /tmp/pruebas.log

Varios registros a la vez:
    python3 tools/check_output.py /tmp/import.log /tmp/pruebas.log
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

HEADER = re.compile(r"^\s*(SCRIPT ERROR|ERROR|WARNING):")
# Godot suele dejar el origen en la línea siguiente ("at: ... (res://...)").
BLOCK_LINES = 4


def _blocks(lines: list[str]) -> list[list[str]]:
    blocks: list[list[str]] = []
    index = 0
    while index < len(lines):
        if not HEADER.match(lines[index]):
            index += 1
            continue
        block: list[str] = [lines[index].rstrip()]
        cursor = index + 1
        while (
            cursor < len(lines)
            and cursor <= index + BLOCK_LINES
            and not HEADER.match(lines[cursor])
        ):
            block.append(lines[cursor].rstrip())
            cursor += 1
        blocks.append(block)
        index = cursor
    return blocks


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print("Uso: check_output.py <log>...", file=sys.stderr)
        return 2

    failures: list[tuple[str, str]] = []
    for name in argv[1:]:
        path = Path(name)
        if not path.is_file():
            print(f"No existe el registro: {name}", file=sys.stderr)
            return 2
        lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
        for block in _blocks(lines):
            text = "\n".join(block)
            is_script_error = block[0].lstrip().startswith("SCRIPT ERROR")
            if is_script_error or "res://" in text:
                failures.append((name, text))

    if not failures:
        print(f"Salida limpia: {len(argv) - 1} registro(s) sin errores ni advertencias de res://.")
        return 0

    for name, block in failures:
        print(f"--- {name} ---\n{block}\n", file=sys.stderr)
    print(
        f"Fallos: {len(failures)} bloque(s) de error o advertencia. "
        "Corrige el origen antes de continuar.",
        file=sys.stderr,
    )
    return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
