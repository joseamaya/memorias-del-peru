# 06 — Estrategia de pruebas

Principio: **una funcionalidad está terminada cuando se comprobó**, no cuando se escribió.

## 1. Niveles de validación

| Nivel | Qué detecta | Cuándo |
|---|---|---|
| 1. Importación / análisis | Errores de sintaxis, tipado, advertencias como errores, recursos rotos | Tras cada cambio |
| 2. Pruebas automatizadas headless | Contratos (Input Map, jerarquía de escenas, lógica pura) | Tras cada cambio de código |
| 3. Carga de escenas | Escenas que no instancian o producen errores al entrar al árbol | Tras cambios en escenas |
| 4. Verificación manual en ejecución | Sensación de control, visuales, audio | Al cerrar cada tarea con impacto jugable |

## 2. Comandos

> **Pendiente de verificación.** Godot no está instalado aún, así que ningún comando de esta sección se ha comprobado. Confirmarlos con `godot --help` es una precondición de la Fase 1 (docs/05).

Importar el proyecto y detectar errores de recursos/scripts (sale al terminar):

```bash
godot --headless --path . --import
```

Validar un script concreto sin ejecutarlo:

```bash
godot --headless --path . --check-only --script res://core/player/player_fps.gd
```

Ejecutar las pruebas automatizadas:

```bash
godot --headless --path . --script res://tests/run_tests.gd
```

Criterio: el código de salida es `0` **y** la salida no contiene líneas `ERROR`, `SCRIPT ERROR` ni `WARNING` provenientes de `res://`. Como ninguna categoría de advertencia está en nivel 1 (docs/04 §5), cualquier problema de GDScript aparece como error.

## 3. Pruebas automatizadas

Sin dependencias externas en la Fase 1: un ejecutor propio mínimo en `tests/run_tests.gd` (`extends SceneTree`) que carga cada archivo `tests/test_*.gd`, ejecuta sus métodos `test_*` y termina con `quit(codigo)` (0 = éxito, 1 = fallo). La adopción de un framework (GUT, gdUnit4) requiere un ADR cuando el volumen de pruebas lo justifique.

**Riesgo a comprobar en la Fase 1:** que los autoloads (`GameManager`) estén disponibles al ejecutar con `--script`. Los scripts que usan el autoload (p. ej. `player_fps.gd`) deben compilar en ese modo. Si no lo están, el ejecutor pasa a ser una escena (`tests/run_tests.tscn` con un nodo raíz que ejecuta las pruebas), lanzada con `godot --headless --path . res://tests/run_tests.tscn`, y se actualiza §2. Las pruebas de lógica crean sus propias instancias en lugar de depender del autoload global.

**Política:** cada fase enumera aquí sus pruebas automatizadas como primera tarea al abrirse, antes de escribir código. “Pruebas en verde” significa: todas las de esta sección (de la fase actual y de las anteriores) pasan.

### Pruebas de Fase 1

| Prueba | Comprueba |
|---|---|
| `test_input_map` | Las 8 acciones existen y tienen al menos un evento |
| `test_player_scene_structure` | `player_fps.tscn` instancia; raíz `CharacterBody3D` con script `PlayerFPS`; existen `CollisionShape3D`, `Head`, `Head/Camera3D`, `Head/Camera3D/InteractionRay` con sus tipos |
| `test_pitch_clamp` | Aplicar un desplazamiento vertical grande deja el pitch en ±80° |
| `test_head_bob_no_drift` | Tras N ticks simulados de movimiento y M de reposo, la cámara vuelve a la posición base (tolerancia 1e-3) |
| `test_pause` | Sobre una instancia de `game_manager.gd` creada por la prueba: `set_paused(true)` emite `pause_changed(true)` y deja `get_tree().paused == true`; `set_paused(false)` revierte ambos; llamar dos veces con el mismo valor no emite la señal de nuevo |
| `test_mouse_mode_for_pause` | `PlayerFPS.mouse_mode_for_pause(true)` devuelve `MOUSE_MODE_VISIBLE` y `(false)` devuelve `MOUSE_MODE_CAPTURED` |
| `test_player_collision_layers` | `PlayerFPS` usa la capa `player` y la máscara `world` + `npc` (docs/04 §7) |
| `test_sandbox_loads` | La escena sandbox instancia y entra al árbol sin errores |

La aplicación efectiva del modo de ratón (`Input.mouse_mode`) depende del servidor de pantalla y no puede comprobarse en modo headless: se cubre con la lógica pura de arriba y con la verificación manual (punto 8 de §4).

Para que la lógica sea comprobable sin entrada real, los cálculos (dirección de movimiento, clamp de pitch, desplazamiento de balanceo) se aíslan en métodos puros con parámetros, invocados desde los callbacks del motor.

## 4. Verificación manual — Fase 1

Ejecutar la escena sandbox y comprobar:

1. Al iniciar, el ratón está capturado.
2. W/A/S/D mueven en relación con la dirección de la vista horizontal.
3. Mantener Shift con movimiento aumenta la velocidad; sin movimiento no ocurre nada.
4. Al soltar las teclas el jugador desacelera, no se detiene en seco.
5. Mirar al cielo/suelo: la cámara se detiene en ±80°; caminar mirando hacia abajo no reduce la velocidad.
6. No se atraviesan las paredes; se sube la rampa de 30°; no se sube la de 50°; se cae desde la plataforma de 2 m.
7. Balanceo perceptible al caminar, más marcado al correr, se desvanece al parar; sin “tirones” al arrancar.
8. Escape: ratón liberado y juego pausado. Escape otra vez: juego reanudado y ratón capturado de nuevo.
9. Moverse en círculos 2 minutos: sin deriva de la cámara.
10. Consola del editor sin errores ni advertencias.

Si el entorno de ejecución no dispone de pantalla (agente sin GUI), los puntos 1–9 se declaran **no verificados** en el informe y se solicita verificación humana.

## 5. Registro de resultados

Cada informe de entrega incluye los comandos ejecutados, su resultado y la lista manual marcada. Las limitaciones y errores pendientes se anotan en la sección correspondiente del informe y, si persisten entre fases, en el plan de implementación.
