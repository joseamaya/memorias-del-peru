# ADR-0002 — Versión de Godot

- Estado: **Propuesto** — bloquea el inicio de la Fase 1
- Fecha: 2026-11-10

## Contexto

La especificación ([docs/00_especificacion.md](../00_especificacion.md)) indica “Godot 4.x”. Varias decisiones dependen de la versión menor:

| Funcionalidad usada en los documentos | Versión mínima |
|---|---|
| Advertencias `untyped_declaration` / `inferred_declaration` | 4.2 |
| Variables de bucle tipadas (`for x: T in ...`) | 4.2 |
| `InputEventKey.location` (Shift izquierdo vs derecho) | 4.3 |
| Indicador `--import` en línea de comandos | Verificar en `godot --help` |
| `Dictionary[K, V]` tipado | 4.4 |
| Interpolación de física en 3D | 4.4 |

Al redactar este ADR, Godot **no está instalado** en la máquina de desarrollo (búsqueda en `PATH`, `/opt`, snap y flatpak sin resultados).

## Decisión propuesta

Usar la **última versión estable 4.x** disponible al iniciar la Fase 1, con mínimo 4.4, edición estándar (GDScript, sin .NET). Fijar la versión exacta (p. ej. `4.N.M-stable`) en este ADR y en `README.md`.

## Pasos para aceptar

1. Instalar Godot y dejarlo accesible como `godot` en el `PATH`.
2. Ejecutar `godot --version` y registrar aquí la salida.
3. Confirmar los indicadores de línea de comandos con `godot --help` y ajustar [06_estrategia_de_pruebas.md](../06_estrategia_de_pruebas.md) si difieren.
4. Listar todas las categorías de `debug/gdscript/warnings/` de esa versión, asignar `0` o `2` a las que no figuran en [docs/04](../04_configuracion_del_proyecto.md) §5 y añadirlas a esa tabla, de modo que ninguna quede en `1`.
5. Cambiar el estado a “Aceptado”.

## Consecuencias

- Todos los colaboradores usan la misma versión exacta; las actualizaciones de versión menor requieren un ADR nuevo y una revalidación completa.
- El mínimo 4.4 no se rebaja sin un ADR nuevo, porque los documentos usan funcionalidades de esa versión (tabla de arriba).
