# Memorias del Perú

Antología de experiencias históricas en 3D que reconstruye períodos de la historia peruana mediante exploración en primera persona, narrativa ambiental, interacción y RPG. La campaña 01 es un **RPG histórico en primera persona de tres actos** ([ADR-0038](docs/adr/0038-campana-rpg.md), [ADR-0039](docs/adr/0039-tres-actos-y-gris.md)).

**Objetivo de la etapa actual:** la campaña 01 jugable de 40–50 minutos, en tres actos ([biblia de la campaña](campaigns/01_pachacutec/documentation/biblia_campana.md)).

**Campaña 01:** *Pachacútec — La defensa del Cusco* (siglo XV).

| Dato | Valor |
|---|---|
| Motor | Godot 4.7.2 ([ADR-0002](docs/adr/0002-version-de-godot.md)) |
| Lenguaje | GDScript con tipado estricto |
| Renderizador | Forward+ |
| Plataforma objetivo | Escritorio (Linux, Windows, macOS) |
| Estado | **Fase 7 — Actos II y III en gris (en curso).** El modelo de museo queda superado ([ADR-0038](docs/adr/0038-campana-rpg.md)); la campaña pasa a tres actos ([ADR-0039](docs/adr/0039-tres-actos-y-gris.md)): llacta, paso y Cusco de 1438. La Fase 6 cerró con el acto I jugable: cuatro encargos, diálogo, diario y mensajero al tercero; los nueve textos viven en la «Memoria». Pendiente: los actos II y III en gris, el combate en escena y el arte. |

## Requisitos

- Godot 4.7.2 estable (edición estándar, no .NET). Debe estar disponible en el `PATH` como `godot` para ejecutar las validaciones de línea de comandos.
- GPU compatible con Vulkan (requisito de Forward+).

## Controles (Fase 1)

| Acción | Tecla |
|---|---|
| Avanzar / Retroceder | W / S |
| Izquierda / Derecha | A / D |
| Correr | Shift izquierdo (mantener) |
| Interactuar / avanzar diálogo | E |
| Diario | J |
| Saltar | Espacio (reservado, sin implementar) |
| Pausa / liberar ratón | Escape |
| Cambiar perfil gráfico (solo desarrollo) | F2 |
| Mirar | Ratón |

## Iteración rápida (desarrollo)

```bash
godot --path . -- --skip-intro --spawn=plaza
godot --path . -- --profile=0      # Bajo, para medir rendimiento
```

`--skip-intro` entra directo al mundo, `--spawn=spawn|plaza|mirador` elige el punto de aparición y `--profile=0..3` el perfil gráfico (0 Bajo, 1 Medio, 2 Alto, 3 Ultra; por defecto Medio).

## Documentación

| Documento | Contenido |
|---|---|
| [AGENTS.md](AGENTS.md) | Reglas obligatorias para agentes de IA y colaboradores |
| [docs/00_especificacion.md](docs/00_especificacion.md) | Especificación original v1.0 (origen del proyecto) |
| [docs/01_vision_y_alcance.md](docs/01_vision_y_alcance.md) | Visión, pilares, alcance, definición de éxito y horizonte |
| [docs/02_arquitectura.md](docs/02_arquitectura.md) | Capas, dependencias, sistemas Core y diseño técnico |
| [docs/03_estandares_de_codigo.md](docs/03_estandares_de_codigo.md) | Tipado estricto, estilo y convenciones de nombres |
| [docs/04_configuracion_del_proyecto.md](docs/04_configuracion_del_proyecto.md) | Contenido requerido de `project.godot` e Input Map |
| [docs/05_plan_de_implementacion.md](docs/05_plan_de_implementacion.md) | Fases, entregables, tareas y criterios de aceptación |
| [docs/06_estrategia_de_pruebas.md](docs/06_estrategia_de_pruebas.md) | Validación, pruebas automatizadas y verificación manual |
| [docs/07_convenciones_historicas.md](docs/07_convenciones_historicas.md) | Clasificación de contenido histórico y fuentes |
| [docs/08_entorno_y_rendimiento.md](docs/08_entorno_y_rendimiento.md) | Entorno atmosférico, perfiles gráficos y métricas |
| [docs/adr/](docs/adr/) | Registro de decisiones arquitectónicas |
| [docs/bitacora.md](docs/bitacora.md) | Cambios que no llegan al umbral de un ADR |
| [campaigns/01_pachacutec/documentation/](campaigns/01_pachacutec/documentation/) | Documentación de la campaña Pachacútec |

## Validación rápida

```bash
godot --headless --path . --import
```

```bash
godot --headless --path . --script res://tests/run_tests.gd
```

Detalles en [docs/06_estrategia_de_pruebas.md](docs/06_estrategia_de_pruebas.md).
