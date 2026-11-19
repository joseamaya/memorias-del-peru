# Memorias del Perú

Antología de cuatro **RPG históricos de mundo abierto regional** en primera persona. Cada campaña tiene un protagonista común, un periodo, una región continua y explorable, una comunidad con vida propia y una historia que se vive desde abajo.

**Campaña en desarrollo:** *Pachacútec — El despertar del Sol* (siglo XV), en la región del valle del Cusco y su aproximación occidental.

| Dato | Valor |
|---|---|
| Motor | Godot 4.7.2 |
| Lenguaje | GDScript con tipado estricto |
| Renderizador | Forward+ |
| Plataforma | Linux y Windows (verificados); macOS como objetivo, sin probar |
| Fase | **F0 cerrada; F1 — Spikes técnicos en curso.** La base de reloj, estado, guardado, NPC, streaming y navegación (1.3–1.6) está implementada. La campaña lineal I–V se conserva como historial y banco de pruebas; F4-L y F5-L quedan congeladas. Ver [docs/05](docs/05_plan_de_implementacion.md) y la [ficha de F1](docs/fases/F1-spikes-tecnicos.md) |

> **Estado honesto del repositorio.** El código actual implementa la versión lineal de 40–50 minutos: cinco actos, tres escenarios y un arco cerrado. No es todavía un mundo abierto. La F0 documental está cerrada; la F1 de spikes técnicos está en curso. No se construye terreno ni se producen assets definitivos hasta validar la arquitectura y la vertical slice. Ver [docs/11](docs/11_diseno_de_mundo.md), [docs/12](docs/12_campanas.md) y [docs/13](docs/13_pipeline_de_escenarios.md).

## Requisitos

- Godot 4.7.2 estable (edición estándar, no .NET). Debe estar disponible en el `PATH` como `godot` para ejecutar las validaciones de línea de comandos.
- GPU compatible con Vulkan (requisito de Forward+).
- Python 3.12 o superior para `gdtoolkit` (`requirements-dev.txt`), solo para lint y formato de archivos nuevos.
- Blender 5.3.0 para el pipeline de modelos (opcional para jugar).

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
| [docs/00_especificacion.md](docs/00_especificacion.md) | Especificación original (historial; superada por el nuevo diseño) |
| [docs/01_vision_y_alcance.md](docs/01_vision_y_alcance.md) | Visión, pilares, alcance y definición de éxito |
| [docs/02_arquitectura.md](docs/02_arquitectura.md) | Capas, sistemas de mundo, persistencia, navegación y streaming |
| [docs/03_estandares_de_codigo.md](docs/03_estandares_de_codigo.md) | Tipado estricto, estilo y convenciones |
| [docs/04_configuracion_del_proyecto.md](docs/04_configuracion_del_proyecto.md) | Contenido requerido de `project.godot` e Input Map |
| [docs/05_plan_de_implementacion.md](docs/05_plan_de_implementacion.md) | Fases, entregables y criterios de aceptación |
| [docs/fases/](docs/fases/) | Tareas de la fase activa, dependencias, criterios por tarea y evidencia |
| [docs/06_estrategia_de_pruebas.md](docs/06_estrategia_de_pruebas.md) | Validación, pruebas automatizadas y verificación manual |
| [docs/07_convenciones_historicas.md](docs/07_convenciones_historicas.md) | Clasificación de contenido histórico y geográfico |
| [docs/08_entorno_y_rendimiento.md](docs/08_entorno_y_rendimiento.md) | Entorno atmosférico, perfiles gráficos y presupuestos |
| [docs/09_biblia_narrativa.md](docs/09_biblia_narrativa.md) | Biblia narrativa de la antología: campañas, fases y reglas de guion |
| [docs/10_plantilla_guion_de_escena.md](docs/10_plantilla_guion_de_escena.md) | Plantilla de escena de mundo y de secuencia controlada |
| [docs/11_diseno_de_mundo.md](docs/11_diseno_de_mundo.md) | GDD de mundo abierto: bucle, escala, NPC, misiones, progresión y economía |
| [docs/12_campanas.md](docs/12_campanas.md) | Concepto, región y estado de las cuatro campañas |
| [docs/13_pipeline_de_escenarios.md](docs/13_pipeline_de_escenarios.md) | Terrain3D, Cyclops, Blender, Godot y validación |
| [docs/14_auditoria_y_migracion.md](docs/14_auditoria_y_migracion.md) | Estado del repositorio, clasificación de sistemas y migración |
| [docs/15_resumen_de_la_redefinicion.md](docs/15_resumen_de_la_redefinicion.md) | Mapa de entregables, decisiones pendientes y siguiente paso |
| [docs/bitacora.md](docs/bitacora.md) | Registro cronológico de cambios y decisiones |
| [campaigns/01_pachacutec/documentation/](campaigns/01_pachacutec/documentation/) | Biblia, guion, expediente, registro histórico y dossier de la región |

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

```bash
godot --headless --path . --script res://tests/combat_arena_check.gd
```

Exportar y arrancar el build de Linux:

```bash
godot --headless --path . --export-release "Linux" build/linux/memorias-del-peru.x86_64
./build/linux/memorias-del-peru.x86_64 --headless --quit-after 10
```

Medición de rendimiento por acto (tres pasadas; `--profile=0` Bajo, `--profile=1` Medio):

```bash
godot --path . --disable-vsync --resolution 1920x1080 \
    res://tests/scenes/measure_performance.tscn -- --profile=1
```

Auditar una escena (draw calls, primitivas y luces con sombra):

```bash
godot --path . --resolution 1280x720 -s res://tools/scene_audit.gd -- \
    --scene=res://campaigns/01_pachacutec/scenes/world/ciudad.tscn --frames=20
```

Duración de una partida (requiere jugarla):

```bash
godot --path . -- --session PCH-DUR-1
python3 tools/session_duration.py PCH-DUR-1
```

Niveles de audio (picos, RMS y clips antes de escuchar):

```bash
python3 tools/audio_levels.py
```

Detalles en [docs/06_estrategia_de_pruebas.md](docs/06_estrategia_de_pruebas.md).
