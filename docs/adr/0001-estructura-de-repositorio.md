# ADR-0001 — Estructura del repositorio: `docs/` y `tests/`

- Estado: Aceptado
- Fecha: 2026-11-10

## Contexto

La especificación ([docs/00_especificacion.md](../00_especificacion.md)) define la estructura oficial (`core/`, `shared_assets/`, `campaigns/`) y ubica la documentación de campaña en `campaigns/<campaña>/documentation/`. No prevé un lugar para la documentación transversal del proyecto ni para las pruebas automatizadas, que la propia especificación exige (§12).

## Opciones consideradas

1. Toda la documentación transversal dentro de `README.md` y `AGENTS.md`. Rechazada: documentos demasiado extensos y difíciles de mantener.
2. Documentación transversal en `core/documentation/`. Rechazada: mezcla código de Core con documentos que también rigen campañas y assets.
3. Añadir `docs/` y `tests/` en la raíz.

## Decisión

Opción 3.

- `docs/`: documentación transversal (visión, arquitectura, estándares, configuración, plan, pruebas, convenciones históricas, rendimiento) y `docs/adr/`.
- `tests/`: ejecutor de pruebas, pruebas `test_*.gd` y escenas de prueba (`tests/scenes/`).
- La documentación propia de cada campaña permanece en `campaigns/<campaña>/documentation/`.
- `CLAUDE.md` en la raíz solo importa `AGENTS.md` para que distintos agentes compartan las mismas reglas.

## Consecuencias

- Las escenas de `tests/` no forman parte del juego distribuido; se excluyen en los presets de exportación cuando estos se creen.
- `tests/` puede depender de `core/` y de `campaigns/`; nada del juego depende de `tests/`.
