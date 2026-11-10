# ADR-0004 — Herramientas de desarrollo: skills y servidores MCP

- Estado: Aceptado
- Fecha: 2026-11-10

## Contexto

[AGENTS.md](../../AGENTS.md) §3 prohíbe dependencias externas (addons) sin un ADR aceptado. Se incorporan skills de agente y servidores MCP para verificar APIs de Godot y reforzar el proceso de trabajo documentado. No forman parte del juego ni se exportan.

## Opciones consideradas

1. No instalar herramientas; solo reglas en `AGENTS.md`. Rechazada: no aporta verificación de API ni automatiza el proceso.
2. Instalarlas a nivel global del usuario. Rechazada: la configuración no sería reproducible ni compartida con el repositorio.
3. Instalarlas a nivel de proyecto. Aceptada: configuración versionada y alcance limitado al repositorio.

## Decisión

Opción 3.

- **Skills** en `.agents/skills/` (ruta de compatibilidad que OpenCode descubre) y `skills-lock.json` versionado:
  - `godot-best-practices` — `jwynia/agent-skills`
  - `godot-gdscript`, `godot-nodes-scenes`, `godot-signals-groups` — `minhhoit/gamedev-agent-skills`
  - `verification-before-completion` — `obra/superpowers`
- **MCPs** en el `opencode.json` del proyecto:
  - `context7` (remoto): consulta de documentación.
  - `godot-docs` (local, desactivado hasta instalar Godot): documentación oficial de la versión instalada.
- Solo se admiten MCPs que **no añadan archivos** al proyecto Godot.

## Consecuencias

- Ni skills ni MCPs son dependencias de runtime; no afectan a `project.godot` ni a las exportaciones.
- Las instrucciones de un skill nunca prevalecen sobre `AGENTS.md` ni sobre los ADR.
- Un MCP que requiera `addons/` (por ejemplo, un editor Godot en vivo) necesita un ADR nuevo.
- Actualizaciones con `npx skills update`; `skills-lock.json` es la referencia de contenido.
- La instalación se verifica con `npx skills list -a opencode` y `opencode mcp list`.
- Los skills de Godot pueden describir una versión posterior a la fijada; prevalece siempre la versión exacta de ADR-0002 y la API comprobada con `godot --help` o `--doctool`.
