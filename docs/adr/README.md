# Registro de decisiones arquitectónicas (ADR)

Un ADR documenta una decisión significativa: contexto, opciones, decisión y consecuencias. Se crea cuando:

- Se cambia un contrato de Core o una regla de dependencia.
- Se añade una dependencia externa (addon, herramienta).
- Se desvía de la especificación o de estos documentos.
- Se elige entre alternativas técnicas con impacto duradero.

Estados: **Propuesto** → **Aceptado** → (opcionalmente) **Reemplazado por ADR-XXXX**. Un ADR aceptado no se edita en su fondo; se reemplaza con uno nuevo.

Plantilla:

```markdown
# ADR-NNNN — Título
- Estado: Propuesto | Aceptado | Reemplazado por ADR-XXXX
- Fecha: AAAA-MM-DD
## Contexto
## Opciones consideradas
## Decisión
## Consecuencias
```

| ADR | Título | Estado |
|---|---|---|
| [0001](0001-estructura-de-repositorio.md) | Estructura del repositorio: `docs/` y `tests/` | Aceptado |
| [0002](0002-version-de-godot.md) | Versión de Godot | Propuesto (bloquea Fase 1) |
| [0003](0003-deteccion-de-interactuables.md) | Detección de interactuables | Propuesto (se decide en Fase 2) |
| [0004](0004-herramientas-de-desarrollo.md) | Herramientas de desarrollo: skills y servidores MCP | Aceptado (selección de skills reemplazada por ADR-0005) |
| [0005](0005-skills-de-godot.md) | Skills de Godot y desviación consciente del estilo oficial | Aceptado |
