# Memorias del Perú

Antología de experiencias históricas en 3D que reconstruye períodos de la historia peruana mediante exploración en primera persona, narrativa ambiental, interacción y RPG. La campaña 01 es un **RPG histórico en primera persona de tres actos**.

**Objetivo de la etapa actual:** la campaña 01 jugable de 40–50 minutos, en tres actos ([biblia de la campaña](campaigns/01_pachacutec/documentation/biblia_campana.md)).

**Campaña 01:** *Pachacútec — La defensa del Cusco* (siglo XV).

| Dato | Valor |
|---|---|
| Motor | Godot 4.7.2 |
| Lenguaje | GDScript con tipado estricto |
| Renderizador | Forward+ |
| Plataforma objetivo | Escritorio (Linux, Windows, macOS) |
| Estado | **Fase 8 — Arte, audio y cierre (en curso).** La campaña se organiza en tres actos: llacta, paso y Cusco de 1438. La Fase 7 cerró con el arco completo en gris, la víspera de los pururaucas y la partida continua automatizada (`ARCO_OK`). El acto I usa los **modelos MakeHuman/Rocketbox** (CC0/MIT) ya versionados, con cara, ropa y animaciones propias; UAL1 se mantiene para la multitud del Cusco y como respaldo; el campamento, los chancas y los NPC del acto III usan los modelos propios. El acto II tiene paisaje y el Cusco deja el bloqueo gris: plaza de tierra, santuario, catorce casas, muro de pirca, terrazas y multitud. El acto I cumple los 60 FPS en Medio; el paso y el Cusco quedan cerca con los modelos propios y carga alta, pendientes de medir en reposo. El prototipo de tejedora vestida en Blender se conserva como referencia, fuera de escena. Pendiente: validación de autor y pulido de personajes. |

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
godot --path . res://campaigns/01_pachacutec/scenes/world/paso.tscn    # acto II en gris
godot --path . res://campaigns/01_pachacutec/scenes/world/ciudad.tscn  # acto III en gris
godot --path . -- --act=2   # empezar en el acto II
godot --path . -- --act=3   # empezar en el acto III
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
| [docs/bitacora.md](docs/bitacora.md) | Registro cronológico de cambios y decisiones |
| [campaigns/01_pachacutec/documentation/](campaigns/01_pachacutec/documentation/) | Documentación de la campaña Pachacútec |

## Validación rápida

```bash
godot --headless --path . --import
```

```bash
godot --headless --path . --script res://tests/run_tests.gd
```

Detalles en [docs/06_estrategia_de_pruebas.md](docs/06_estrategia_de_pruebas.md).
