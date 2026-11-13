# Memorias del Perú

Antología de experiencias históricas en 3D que reconstruye períodos de la historia peruana mediante exploración en primera persona, narrativa ambiental e interacción. Combate y progresión forman parte de la visión, pero quedan fuera de la etapa actual (ver [definición de éxito y horizonte](docs/01_vision_y_alcance.md#5-definición-de-éxito)).

**Objetivo de la etapa actual:** un vertical slice jugable de 2–3 minutos de la campaña 01 ([ADR-0033](docs/adr/0033-duracion-del-slice.md)); el horizonte de 10–15 minutos queda para la campaña completa.

**Campaña 01:** *Pachacútec — La defensa del Cusco* (siglo XV).

| Dato | Valor |
|---|---|
| Motor | Godot 4.7.2 ([ADR-0002](docs/adr/0002-version-de-godot.md)) |
| Lenguaje | GDScript con tipado estricto |
| Renderizador | Forward+ |
| Plataforma objetivo | Escritorio (Linux, Windows, macOS) |
| Estado | **Fase 5 — Museo explorable (en curso).** Alcance v5.1 ([ADR-0034](docs/adr/0034-una-campana-y-museo.md), [ADR-0035](docs/adr/0035-tour-libre.md)): nueve estelas con tarjeta, contador y brújula opcional (Q); el evento sale al mirar desde el mirador. Pendiente: validación de la duración (6–8 min), medición de rendimiento y prueba con jugadores ajenos (métrica 5 **no verificada**). |

## Requisitos

- Godot 4.7.2 estable (edición estándar, no .NET). Debe estar disponible en el `PATH` como `godot` para ejecutar las validaciones de línea de comandos.
- GPU compatible con Vulkan (requisito de Forward+).

## Controles (Fase 1)

| Acción | Tecla |
|---|---|
| Avanzar / Retroceder | W / S |
| Izquierda / Derecha | A / D |
| Correr | Shift izquierdo (mantener) |
| Interactuar | E |
| Saltar | Espacio (reservado, sin implementar) |
| Pausa / liberar ratón | Escape |
| Cambiar perfil gráfico (solo desarrollo) | F2 |
| Mirar | Ratón |
| Brújula del tour (mantener) | Q |

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
