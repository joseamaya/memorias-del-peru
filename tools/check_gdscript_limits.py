#!/usr/bin/env python3
"""Ratchet de tamaño para GDScript.

Un archivo de 2.300 líneas no se arregla en un día, pero tampoco debe seguir
creciendo. Los archivos grandes que ya existen quedan congelados en su tamaño
actual; cualquier archivo nuevo debe caber en MAX_NEW_LINES. Así el proyecto
puede dividirse poco a poco sin una reescritura ni un reformateo masivo.

Uso:
    python3 tools/check_gdscript_limits.py
"""

from __future__ import annotations

import sys
from pathlib import Path

MAX_NEW_LINES = 400

ROOT = Path(__file__).resolve().parent.parent
SEARCH_DIRS = ("core", "campaigns", "tests", "tools")

# Archivos heredados: no pueden crecer. Al dividir uno, se baja su límite o se
# elimina de esta tabla en el mismo commit.
GRANDFATHERED = {
    "campaigns/01_pachacutec/scripts/world/ciudad.gd": 2407,
    "campaigns/01_pachacutec/scripts/world/llacta.gd": 2286,
    "campaigns/01_pachacutec/scripts/world/paso.gd": 1381,
    "campaigns/01_pachacutec/scripts/world/npc_actor.gd": 682,
    "core/ui/hud.gd": 612,
    "core/player/player_fps.gd": 606,
    "campaigns/01_pachacutec/scripts/world/dressed_mannequin.gd": 500,
}


def count_lines(path: Path) -> int:
    with path.open("r", encoding="utf-8") as handle:
        return sum(1 for _ in handle)


def main() -> int:
    failures: list[str] = []
    for directory in SEARCH_DIRS:
        base = ROOT / directory
        if not base.exists():
            continue
        for path in sorted(base.rglob("*.gd")):
            relative = path.relative_to(ROOT).as_posix()
            lines = count_lines(path)
            limit = GRANDFATHERED.get(relative)
            if limit is None:
                if lines > MAX_NEW_LINES:
                    failures.append(
                        f"{relative}: {lines} líneas; un archivo nuevo debe tener "
                        f"como máximo {MAX_NEW_LINES}. Divídelo por responsabilidad."
                    )
            elif lines > limit:
                failures.append(
                    f"{relative}: {lines} líneas; el límite heredado es {limit}. "
                    "Un archivo congelado no puede crecer: extrae la parte nueva."
                )
    if failures:
        print("Límites de GDScript incumplidos:")
        for failure in failures:
            print(f"  - {failure}")
        return 1
    print(f"Límites de GDScript OK (nuevos ≤ {MAX_NEW_LINES} líneas; "
          f"{len(GRANDFATHERED)} heredados congelados).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
