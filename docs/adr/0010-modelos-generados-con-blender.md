# ADR-0010 — Modelos generados por script con Blender 5.x

- Estado: Aceptado
- Fecha: 2026-11-11

## Contexto

El §7 del [alcance del vertical slice](../../campaigns/01_pachacutec/documentation/alcance_vertical_slice.md) fija **Blender 4.x LTS** para los modelos. El equipo de desarrollo tiene instalado Blender 5.3.0 (snap) y no tiene la 4.x. Además, los modelos de la Fase 4 los prepara un agente de IA, que no puede usar la interfaz de Blender. Para un proyecto que exige trazabilidad, un `.blend` editado a mano tampoco deja ver en git qué cambió.

Se valoró conectar Blender en vivo mediante un servidor MCP de terceros. Eso exige instalar un addon dentro de Blender (prohibido sin ADR por el §7 y por [AGENTS.md](../../AGENTS.md) §3) y ejecuta Python arbitrario. Sus integraciones de descarga de assets y de generación por IA chocan con el registro histórico y complican las licencias. Lo único que aporta frente a ejecutar Blender sin interfaz es ver el modelo en directo.

## Opciones consideradas

1. Instalar Blender 4.x LTS junto a la 5.x. Rechazada: el resultado es el mismo `.glb` glTF 2.0 y la versión no cambia ninguna regla de §7.
2. Blender con servidor MCP en vivo. Rechazada por lo expuesto en el contexto; se puede reconsiderar con un ADR propio si hace falta iterar en directo.
3. Script de Python (`bpy`/`bmesh`) versionado que construye y exporta cada modelo, ejecutado con `blender --background --factory-startup`. Aceptada.

## Decisión

Opción 3.

- **Versión:** Blender **5.x** (verificado con 5.3.0). Sustituye a «Blender 4.x LTS» del §7 del alcance.
- **Generador:** `campaigns/01_pachacutec/assets/blender/pch_models.py`. Es determinista: semilla fija por modelo y sin dependencias fuera de Blender.
- **Comando** desde la raíz del repositorio:
  ```bash
  blender --background --factory-startup --python campaigns/01_pachacutec/assets/blender/pch_models.py -- [--preview DIR] [nombre ...]
  ```
  Después hay que importar con `godot --headless --path . --import`.
- `--factory-startup` garantiza que no intervienen addons ni preferencias del usuario.
- **Salida:** los `.glb` y sus `.import` se versionan en `assets/models/`. No se guardan `.blend`.
- **Colisión:** las mallas con sufijo `-convcolonly` se convierten en colisión convexa al importar en Godot.
- Los `.glb` siguen sujetos a las reglas de §7.1 y a `test_model_files_valid`. Un modelo hecho a mano en Blender se admite igual si cumple esas reglas. En ese caso deja de generarlo el script y el cambio se anota en §7.1.

## Consecuencias

- Cualquier modelo se reproduce con un comando, y sus cambios se revisan como código.
- Blender 5.x pasa a ser una herramienta de desarrollo, no una dependencia de runtime.
- La revisión visual se hace con los renders de `--preview` (EEVEE sin interfaz) y con capturas en el juego.
- La calidad depende de la geometría procedural: estilo low-poly con colores planos por material, sin texturas pintadas ni esculpido.
- El script no hace rigging ni animación. Para los personajes, el alcance prevé un cuerpo base riggeado; eso queda sin resolver aquí y se decidirá cuando se aborden.
- Los modelos son **reconstrucciones (R)**: su forma concreta sigue a las fichas del registro histórico, pero no está documentada como hecho.
