# ADR-0022 — Skills de producción de arte y de técnica de shaders

- Estado: Aceptado
- Fecha: 2026-11-12
- Amplía: [ADR-0005](0005-skills-de-godot.md) (selección de skills); el resto de [ADR-0004](0004-herramientas-de-desarrollo.md) sigue vigente

## Contexto

La Fase 4 genera modelos con Blender ([ADR-0010](0010-modelos-generados-con-blender.md)), personajes con esqueleto ([ADR-0016](0016-personajes-realistas-makehuman.md), [ADR-0017](0017-cabezas-rocketbox.md)), ropa con textiles ([ADR-0018](0018-ropa-textiles-caida-y-muelles.md), [ADR-0020](0020-ropa-cortada-y-cosida.md)) y texturas triplanares ([ADR-0014](0014-texturas-de-detalle-triplanares.md)). Las skills que hay ahora solo cubren la estructura de escenas, las señales y la verificación. Ninguna cubre:

- la validación de modelos 3D: topología, UVs, escala, pivotes, LOD y glTF;
- el registro de procedencia y licencia de los recursos descargados;
- la matemática de los efectos de shader.

El catálogo `gamedev-skills/awesome-gamedev-agent-skills` (en skills.sh) es la versión actual de `minhhoit/gamedev-agent-skills`, de donde vienen `godot-nodes-scenes` y `godot-signals-groups`. Pertenece a un autor independiente (Abhishek Barali) y no es oficial de Godot Foundation. Toma Godot 4.7.2 como referencia, la misma versión que [ADR-0002](0002-version-de-godot.md).

Se revisó el catálogo el 2026-11-12. Todas las skills de Godot usan `:=` (entre 2 y 29 veces cada una), así que [ADR-0005](0005-skills-de-godot.md) obliga a retirarlas. Hay dos skills que no son de un motor concreto y no contienen `:=`.

## Opciones consideradas

1. **Instalar el catálogo completo o el paquete `godot`.** Rechazada: añadiría 16 skills de Godot que contradicen `docs/03`, y tendrían que retirarse o parchearse una a una.
2. **Instalar y parchear `godot-animation` y `godot-3d-essentials`.** Rechazada por ahora: ADR-0005 prefiere retirar a parchear, y su contenido ya está cubierto por la documentación oficial vía MCP y por las pruebas del proyecto.
3. **Instalar solo las skills que no son de un motor concreto, sin `:=` y útiles para la fase activa.** Aceptada.

## Decisión

Se instalan a nivel de proyecto, copiadas y sin modificar, en `.agents/skills/`, con su entrada en `skills-lock.json`. El origen es `gamedev-skills/awesome-gamedev-agent-skills`, instalado con `npx skills add … -a opencode --copy`.

| Skill | Uso en el proyecto |
|---|---|
| `create-game-assets` | `references/three-d-pipeline.md` (validación de modelos 3D e importación glTF) y `references/provenance.md` (registro de licencias de recursos descargados, como la lana CC0 de ADR-0020 o Rocketbox) |
| `shader-programming` | Técnica de efectos (fresnel, contorno, post-proceso) en GLSL, como apoyo a los `.gdshader` de tela y terreno |

Reglas de uso:

- Ninguna de las dos se parchea. Si una actualización introduce `:=` o contradice `docs/03`, se retira según ADR-0005.
- La clasificación y las fuentes de contenido histórico siguen [docs/07](../07_convenciones_historicas.md). El registro de procedencia de la skill solo complementa la licencia del archivo; no sustituye a la ficha histórica.
- Las partes de `create-game-assets` sobre arte 2D, pixel art y generación de imágenes con IA no se aplican al slice. Generar arte con IA requeriría un ADR propio.
- Los scripts de `create-game-assets/scripts/` (Python con Pillow) son opcionales. No forman parte de las validaciones de [docs/06](../06_estrategia_de_pruebas.md) y no se instala Pillow por ellos sin pedirlo.

## Consecuencias

- Las skills no son dependencias de runtime y no afectan a `project.godot` ni a las exportaciones.
- En la evaluación de riesgo de skills.sh, Gen y Socket marcan las dos skills como seguras. Snyk da riesgo bajo a `shader-programming` y medio a `create-game-assets`. Se leyeron sus scripts: solo abren imágenes locales con Pillow, sin red ni procesos externos. El riesgo medio se atribuye a la instrucción `pip install` de la skill.
- Verificación:
  - `npx skills list -a opencode` muestra las dos con origen `gamedev-skills/awesome-gamedev-agent-skills`;
  - `grep -rn ':=' .agents/skills/create-game-assets .agents/skills/shader-programming` no devuelve nada.
- `npx skills update` puede actualizarlas sin conflicto porque no tienen cambios locales; tras actualizar se repite la comprobación de `:=`.
- **Disponibilidad para Claude Code.** Claude Code busca las skills de proyecto en `.claude/skills/`, no en la ruta de OpenCode.
  - Cada skill de `.agents/skills/` (las cinco del proyecto, no solo las dos nuevas) tiene un enlace simbólico relativo en `.claude/skills/<nombre>` que apunta a `../../.agents/skills/<nombre>`.
  - Hay una sola copia de cada skill: el bloque de override de ADR-0005 y cualquier actualización llegan a los dos agentes.
  - Las skills se instalan o se retiran siempre en `.agents/skills/`, y después se crea o se borra su enlace.
  - `npx skills list -a claude-code` debe mostrar las mismas skills que `-a opencode`.
  - Godot ignora las carpetas que empiezan por punto, así que `.claude/` no entra en el proyecto ni en las exportaciones.
  - En Windows, los enlaces simbólicos requieren `core.symlinks` activado en git.
