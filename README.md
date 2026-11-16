# Memorias del Perú

Antología de experiencias históricas en 3D que reconstruye períodos de la historia peruana mediante exploración en primera persona, narrativa ambiental, interacción y RPG.

**Campaña en desarrollo:** *Pachacútec — El despertar del Sol* (siglo XV), en cinco actos y con una duración objetivo de 40–50 minutos.

| Dato | Valor |
|---|---|
| Motor | Godot 4.7.2 |
| Lenguaje | GDScript con tipado estricto |
| Renderizador | Forward+ |
| Plataforma objetivo | Escritorio (Linux, Windows, macOS) |
| Fase | **Fase 4 — Arte, audio y equilibrio.** El arco completo (I–V), el guion, el guion de escenas y los sistemas de campaña están cerrados; las 117 pruebas pasan. Queda el pase visual, sonoro y la brecha de rendimiento en Medio |

## Requisitos

- Godot 4.7.2 estable (edición estándar, no .NET). Debe estar disponible en el `PATH` como `godot` para ejecutar las validaciones de línea de comandos.
- GPU compatible con Vulkan (requisito de Forward+).

## Controles

| Acción | Tecla |
|---|---|
| Avanzar / Retroceder | W / S |
| Izquierda / Derecha | A / D |
| Correr | Shift izquierdo (mantener) |
| Interactuar / avanzar diálogo | E |
| Continuar tras la tarjeta de fin | E o Intro (R como atajo) |
| Diario | J |
| Saltar | Espacio (reservado, sin implementar) |
| Pausa / liberar ratón | Escape |
| Cambiar perfil gráfico (solo desarrollo) | F2 |
| Mirar | Ratón |

## Iteración rápida (desarrollo)

```bash
godot --path .                              # portada
godot --path . -- --profile=0               # perfil Bajo
godot --path . res://tests/scenes/player_sandbox.tscn   # banco de pruebas del jugador
```

Los argumentos `--profile=0..3` eligen perfil gráfico (0 Bajo, 1 Medio, 2 Alto, 3 Ultra; por defecto Medio).

## Documentación

| Documento | Contenido |
|---|---|
| [AGENTS.md](AGENTS.md) | Reglas obligatorias para agentes de IA y colaboradores |
| [docs/00_especificacion.md](docs/00_especificacion.md) | Especificación original (origen del proyecto) |
| [docs/01_vision_y_alcance.md](docs/01_vision_y_alcance.md) | Visión, pilares, alcance y definición de éxito |
| [docs/02_arquitectura.md](docs/02_arquitectura.md) | Capas, dependencias, sistemas Core y diseño técnico |
| [docs/03_estandares_de_codigo.md](docs/03_estandares_de_codigo.md) | Tipado estricto, estilo y convenciones de nombres |
| [docs/04_configuracion_del_proyecto.md](docs/04_configuracion_del_proyecto.md) | Contenido requerido de `project.godot` e Input Map |
| [docs/05_plan_de_implementacion.md](docs/05_plan_de_implementacion.md) | Fases, entregables y criterios de aceptación |
| [docs/06_estrategia_de_pruebas.md](docs/06_estrategia_de_pruebas.md) | Validación, pruebas automatizadas y verificación manual |
| [docs/07_convenciones_historicas.md](docs/07_convenciones_historicas.md) | Clasificación de contenido histórico y fuentes |
| [docs/08_entorno_y_rendimiento.md](docs/08_entorno_y_rendimiento.md) | Entorno atmosférico, perfiles gráficos y métricas |
| [docs/09_biblia_narrativa.md](docs/09_biblia_narrativa.md) | Biblia narrativa de la antología: campañas, actos y reglas de guion |
| [docs/10_plantilla_guion_de_escena.md](docs/10_plantilla_guion_de_escena.md) | Plantilla reutilizable de guion de escena: bloqueo, cámara, banderas y aceptación |
| [docs/bitacora.md](docs/bitacora.md) | Registro cronológico de cambios |
| [campaigns/01_pachacutec/documentation/](campaigns/01_pachacutec/documentation/) | Biblia, guion, guion de escenas, expediente y registro histórico de la campaña |

## Validación rápida

```bash
godot --headless --path . --import
```

```bash
godot --headless --path . --script res://tests/run_tests.gd
```

```bash
godot --headless --path . --script res://tests/arc_playthrough.gd
```

Medición de rendimiento por acto:

```bash
godot --path . --disable-vsync --resolution 1920x1080 \
    res://tests/scenes/measure_performance.tscn -- --profile=0
```

Detalles en [docs/06_estrategia_de_pruebas.md](docs/06_estrategia_de_pruebas.md).
