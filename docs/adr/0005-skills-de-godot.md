# ADR-0005 — Skills de Godot y desviación consciente del estilo oficial

- Estado: Aceptado
- Fecha: 2026-11-10
- Relación: reemplaza la selección de skills de [ADR-0004](0004-herramientas-de-desarrollo.md); los MCPs de ADR-0004 siguen vigentes.

## Contexto

Las skills de Godot instaladas según ADR-0004 enseñan `:=` de forma explícita y declaran como objetivo Godot 4.7. La guía oficial de estilo de Godot también recomienda `:=` cuando el tipo es evidente en la misma línea:

> "In most cases, you can let the compiler infer the type using `:=`. Prefer `:=` when the type is written on the same line as the assignment".

`docs/03` prohíbe `:=` por completo y `docs/04` configura `inferred_declaration` como error. La divergencia es, por tanto, una decisión propia del proyecto, no un defecto de las skills.

Además, las skills instaladas no son oficiales de Godot Foundation: `skills.sh` es un directorio de Vercel Labs y las fuentes usadas son autores independientes (`jwynia/agent-skills`, `minhhoit/gamedev-agent-skills`, `obra/superpowers`). Las auditorías de seguridad no implican respaldo del fabricante.

## Opciones consideradas

1. **Alinear el proyecto con la guía oficial** y permitir `:=` cuando el tipo es evidente. Rechazada: cambia un estándar aceptado, debilita el tipado explícito y obliga a modificar `docs/03` y `docs/04` en plena Fase 0.
2. **Conservar todas las skills y confiar en el compilador** para corregir cada `:=`. Rechazada: el agente leería una instrucción contraria y tendría que deshacerla en cada script.
3. **Conservar solo las skills compatibles y corregir sus ejemplos.** Aceptada.

## Decisión

- **Retiradas:** `godot-best-practices` (125 usos de `:=`) y `godot-gdscript` (enseña `:=` de forma explícita). Su contenido general queda cubierto por `docs/03` y la documentación oficial vía MCP.
- **Conservadas y corregidas:** `godot-nodes-scenes` y `godot-signals-groups`. Se añadió un bloque de override al inicio de cada `SKILL.md` y se sustituyeron sus ejemplos con `:=` por tipos explícitos.
- **Conservada sin cambios:** `verification-before-completion`.
- **Sin skill propia de GDScript:** `docs/03` es la fuente de verdad y no se duplica.
- El proyecto mantiene la prohibición de `:=`; no se modifica `docs/03`.

## Consecuencias

- Las skills conservadas son copias locales corregidas. `npx skills update` las sobrescribe: tras actualizar hay que reaplicar el bloque de override y las sustituciones, o no actualizarlas.
- `npx skills check` puede informar "has local changes" en las dos skills corregidas; es el estado esperado.
- Las referencias internas de esas skills ya no contienen `:=`; si una actualización las reintroduce, el bloque de override indica reescribirlos.
- El criterio de verificación es `grep -rn ':=' .agents/skills`: no debe aparecer en ningún ejemplo de código. Las únicas menciones admitidas son las del bloque de override que explica la prohibición.
- Cualquier skill nueva que contradiga `docs/03` se retira, no se parchea, salvo decisión expresa en un ADR.
