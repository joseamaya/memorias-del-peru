# ADR-0002 — Versión de Godot

- Estado: **Aceptado**
- Fecha: 2026-11-10

## Contexto

La especificación ([docs/00_especificacion.md](../00_especificacion.md)) indica “Godot 4.x”. Varias decisiones dependen de la versión menor:

| Funcionalidad usada en los documentos | Versión mínima |
|---|---|
| Advertencias `untyped_declaration` / `inferred_declaration` | 4.2 |
| Variables de bucle tipadas (`for x: T in ...`) | 4.2 |
| `InputEventKey.location` (Shift izquierdo vs derecho) | 4.3 |
| Indicador `--import` en línea de comandos | Verificado en 4.7.2 |
| `Dictionary[K, V]` tipado | 4.4 |
| Interpolación de física en 3D | 4.4 |

Verificación realizada el 2026-11-10: Godot instalado como `godot` en el `PATH` con la versión **4.7.2.stable.official.ed1daf0bf** (edición estándar, sin .NET).

## Decisión

Usar **Godot 4.7.2-stable**, edición estándar (GDScript, sin .NET). Es la versión exacta de todos los colaboradores.

## Pasos de aceptación (completados)

1. [x] Instalar Godot y dejarlo accesible como `godot` en el `PATH`.
2. [x] Ejecutar `godot --version` y registrar la salida: `4.7.2.stable.official.ed1daf0bf`.
3. [x] Confirmar los indicadores de línea de comandos con `godot --help`: `--headless`, `--import`, `--check-only` y `--script` existen.
4. [x] Revisar las categorías de `debug/gdscript/warnings/` de 4.7.2 y actualizar [docs/04](../04_configuracion_del_proyecto.md) §5: ninguna queda en `1`; `exclude_addons` se sustituye por `directory_rules`.
5. [x] Cambiar el estado a “Aceptado”.

## Consecuencias

- Todos los colaboradores usan la misma versión exacta; las actualizaciones de versión menor requieren un ADR nuevo y una revalidación completa.
- El mínimo 4.4 no se rebaja sin un ADR nuevo, porque los documentos usan funcionalidades de esa versión (tabla de arriba).
