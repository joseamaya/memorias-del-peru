#!/usr/bin/env python3
"""Comprueba que todas las pruebas se ejecutan y están documentadas.

Tres guardas:

1. El ejecutor `tests/run_tests.gd` solo lee el directorio `tests/`; una prueba
   dentro de una subcarpeta dejaría de ejecutarse en silencio.
2. Toda prueba de `tests/test_*.gd` figura en la sección activa de `docs/06`
   (§3, antes de §3.5) y toda prueba citada allí existe.
3. Todo recorrido de integración (`*_check.gd` y `arc_playthrough.gd`) se
   ejecuta en `.github/workflows/ci.yml`, y todo script que la CI ejecuta existe.

Uso:
    python3 tools/check_test_inventory.py
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TESTS = ROOT / "tests"
DOC = ROOT / "docs" / "06_estrategia_de_pruebas.md"
CI = ROOT / ".github" / "workflows" / "ci.yml"
ACTIVE_TESTS_END = "### 3.5"


def main() -> int:
    failures: list[str] = []

    nested = sorted(
        path.relative_to(ROOT).as_posix()
        for path in TESTS.rglob("test_*.gd")
        if path.parent != TESTS
    )
    for path in nested:
        failures.append(
            f"{path}: el ejecutor solo lee tests/; muévelo a tests/ o amplía run_tests.gd."
        )

    test_files = {path.stem for path in TESTS.glob("test_*.gd")}
    active_doc = DOC.read_text(encoding="utf-8").split(ACTIVE_TESTS_END, 1)[0]
    documented = set(re.findall(r"\btest_[a-z0-9_]+\b", active_doc))
    for name in sorted(test_files - documented):
        failures.append(f"tests/{name}.gd no figura en docs/06 §3.")
    for name in sorted(documented - test_files):
        failures.append(f"docs/06 §3 cita {name}, pero tests/{name}.gd no existe.")

    ci_text = CI.read_text(encoding="utf-8")
    ci_scripts = set(
        re.findall(r"res://(tests/[A-Za-z0-9_./-]+\.gd)", ci_text)
    )
    for path in sorted(ci_scripts):
        if not (ROOT / path).exists():
            failures.append(f"ci.yml ejecuta {path}, que no existe.")

    integration = {path.name for path in TESTS.glob("*_check.gd")}
    integration.add("arc_playthrough.gd")
    ci_names = {Path(path).name for path in ci_scripts}
    for name in sorted(integration - ci_names):
        failures.append(f"tests/{name} no se ejecuta en ci.yml.")

    if failures:
        print("Inventario de pruebas incumplido:", file=sys.stderr)
        for failure in failures:
            print(f"  - {failure}", file=sys.stderr)
        return 1

    print(
        f"Inventario de pruebas OK: {len(test_files)} archivos documentados; "
        f"{len(integration)} recorridos de integración en CI."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
