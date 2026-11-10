# 03 — Estándares de código

## 1. Tipado estricto (obligatorio)

```gdscript
var health: float = 100.0
var movement_speed: float = 5.0
var is_running: bool = false
var visited_zones: Array[StringName] = []
var npc_by_id: Dictionary[StringName, Node3D] = {}

func calculate_damage(base_damage: float) -> float:
	return base_damage * 1.5
```

| Regla | Detalle |
|---|---|
| Variables | Siempre `var nombre: Tipo = valor`. **Prohibido** `:=` (la advertencia `INFERRED_DECLARATION` está configurada como error). |
| Constantes | `const NAME: Tipo = valor`. |
| Parámetros y retorno | Todos tipados; `-> void` explícito. |
| Variables de bucle | `for item: Tipo in coleccion:` |
| Colecciones | `Array[T]` y `Dictionary[K, V]` siempre (la versión mínima, 4.4, admite ambos). |
| `Variant` | Evitar. Si es inevitable (p. ej. datos de `JSON`), convertir de inmediato a un tipo concreto con comprobación. |
| Conversiones | `as` seguido de comprobación de `null`, o `is` antes del cast. Nunca acceder a miembros de un resultado sin tipar. |
| Nodos | `@onready var head: Node3D = $Head` (tipo explícito). Preferir `%NombreUnico` para nodos internos de una escena; nunca rutas absolutas `/root/...`. |
| Señales | Con parámetros tipados: `signal stamina_changed(current: float, maximum: float)`. Conectar con `Callable` (`signal.connect(_on_x)`), no con cadenas. |
| Parámetros no usados | Prefijo `_` (`func interact(_interactor: Node3D) -> void:`) para no disparar `UNUSED_PARAMETER`. |
| Divisiones | En cálculos de coma flotante, operandos `float` (`1.0`, no `1`). Una división `int / int` intencionada lleva comentario (la advertencia `INTEGER_DIVISION` está desactivada, ver docs/04 §5). |
| Señales futuras | Prohibido declarar una señal que la clase no emite todavía (`UNUSED_SIGNAL` es error). |
| Textos de jugador | Nunca literales en código: claves de traducción con `tr()` (ver docs/02 §7). |

Supresiones (`@warning_ignore`): solo con comentario que justifique por qué no hay alternativa y mención en el informe de entrega.

## 2. Estilo

Basado en la guía oficial de estilo de GDScript.

- Indentación con tabuladores.
- Longitud de línea orientativa: 100 caracteres.
- Orden dentro de un script:
  1. `@tool` (si aplica), `class_name`, `extends`
  2. Comentario de documentación (`##`)
  3. Señales
  4. Enums
  5. Constantes
  6. Variables `@export` (agrupadas con `@export_group`)
  7. Variables públicas
  8. Variables privadas (`_prefijo`)
  9. Variables `@onready`
  10. Métodos virtuales del motor (`_init`, `_ready`, `_unhandled_input`, `_process`, `_physics_process`)
  11. Métodos públicos
  12. Métodos privados
  13. Callbacks de señales (`_on_<emisor>_<señal>`)

## 3. Nombres

| Elemento | Convención | Ejemplo |
|---|---|---|
| Clases (`class_name`) | PascalCase | `PlayerFPS`, `Interactable` |
| Archivos y carpetas | snake_case | `player_fps.gd`, `quero_chicha.tscn` |
| Funciones y variables | snake_case | `get_interaction_text()` |
| Privados | `_snake_case` | `_bob_phase` |
| Constantes y enums | CONSTANT_CASE | `MAX_STAMINA` |
| Señales | snake_case en pasado o estado | `stamina_changed`, `interactable_focused` |
| Nodos en escena | PascalCase | `InteractionRay` |
| Acciones de entrada | snake_case | `move_forward` |

## 4. Diseño

- Responsabilidad única: un script, una responsabilidad. Si un script necesita una sección “y además…”, dividirlo.
- Funciones cortas (orientativo: ≤ 30 líneas) y con un solo nivel de abstracción.
- Sin valores mágicos: `@export` para lo ajustable por diseño, `const` para lo fijo.
- Sin lógica de negocio en escenas (`.tscn`): las escenas componen nodos; la lógica vive en scripts.
- Sin código duplicado: si se repite en dos campañas, se evalúa moverlo a Core (con ADR si cambia contratos).
- Documentar con `##` toda clase pública y todo método público de Core (aparece en la ayuda del editor).

## 5. Control de versiones

- Mensajes de commit en español, en imperativo, con prefijo de área: `core(player): añade head bobbing`, `docs: …`, `pachacutec(world): …`.
- Un commit = un cambio coherente.
- `.godot/` no se versiona; los archivos `*.import` sí (necesarios para reproducir la importación en Godot 4).
- Los archivos `*.uid` generados por Godot 4.4+ también se versionan: estabilizan las referencias entre recursos.
