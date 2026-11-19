# 04 — Configuración del proyecto (`project.godot`)

Este documento define **qué** debe contener `project.godot`. El archivo se creó desde el editor de la versión instalada y se ajusta a mano, para que `config_version` y las claves coincidan exactamente con esa versión.

> Claves verificadas con **Godot 4.7.2** el 2026-11-10 (versión fijada; ADR-0002, histórico).

## 1. Aplicación

| Clave | Valor |
|---|---|
| `application/config/name` | `"Memorias del Perú"` |
| `application/config/features` | versión instalada + `"Forward Plus"` |
| `application/run/main_scene` | `res://core/ui/title_screen.tscn`: la portada es el punto de entrada y no depende de una campaña concreta |

## 2. Renderizado

| Clave | Valor |
|---|---|
| `rendering/renderer/rendering_method` | `"forward_plus"` |
| `rendering/renderer/rendering_method.mobile` | no se configura (solo escritorio) |

Las opciones gráficas (sombras, niebla volumétrica, SSAO, etc.) **no** se fijan aquí de forma rígida: se aplican en tiempo de ejecución por perfiles (ver [08_entorno_y_rendimiento.md](08_entorno_y_rendimiento.md)). `project.godot` solo contiene valores por defecto de arranque. Muchas claves de `ProjectSettings` se leen únicamente al iniciar el motor, por lo que los perfiles **no** modifican `ProjectSettings` en ejecución: actúan sobre `Environment`, luces, `Viewport` y `RenderingServer`.

## 3. Ventana

| Clave | Valor | Motivo |
|---|---|---|
| `display/window/size/viewport_width` | `1920` | Resolución base |
| `display/window/size/viewport_height` | `1080` | Resolución base |
| `display/window/stretch/mode` | `"canvas_items"` | La UI escala con la ventana; el 3D se renderiza a la escala del perfil gráfico (68 % en Medio) |
| `display/window/stretch/aspect` | `"expand"` | Soporta 16:10, 21:9 sin bandas |
| `display/window/vsync/vsync_mode` | Habilitado (por defecto) | Configurable en perfiles futuros |

## 4. Input Map

Se usan **teclas físicas** (`physical_keycode`) para que WASD conserve su posición en distribuciones AZERTY/QWERTZ y en teclados latinoamericanos.

| Acción | Evento | Notas |
|---|---|---|
| `move_forward` | W (física) | |
| `move_backward` | S (física) | |
| `move_left` | A (física) | |
| `move_right` | D (física) | |
| `run` | Shift izquierdo (`KEY_SHIFT`, `location = left`) | `InputEventKey.location` (disponible desde 4.3; la versión mínima del proyecto es 4.4) distingue izquierda/derecha |
| `interact` | E (física) | En uso |
| `jump` | Espacio | Reservado: sin lógica |
| `pause` | Escape | Procesado por `GameManager` |
| `journal` | J | Abre y cierra el diario |
| `attack` | Ratón izquierdo | Honda, porra o escudo según el arma activa |
| `block` | Ratón derecho | Solo el escudo reduce daño |
| `weapon_1` | 1 | Honda |
| `weapon_2` | 2 | Porra |
| `weapon_3` | 3 | Escudo |

Zona muerta: valor por defecto (0.5) — irrelevante para teclado, se revisará al añadir mando.

Verificación obligatoria: una prueba automatizada comprueba que cada acción existe (`InputMap.has_action`) y tiene al menos un evento (ver [06_estrategia_de_pruebas.md](06_estrategia_de_pruebas.md)).

## 5. Advertencias de GDScript

Valores: `0` = ignorar, `1` = advertencia, `2` = error.

**Política:** ninguna categoría queda en `1`. Cada una es un error que bloquea (`2`) o se ignora (`0`) con motivo documentado. Lista completa revisada con **Godot 4.7.2** el 2026-11-10; cambiar una categoría requiere decisión del responsable y entrada en la bitácora.

| Clave (`debug/gdscript/warnings/…`) | Valor | Propósito |
|---|---|---|
| `enable` | `true` | |
| `directory_rules` | `{ "res://addons": 0 }` | Ignora advertencias en addons de terceros. En 4.7 sustituye a `exclude_addons` |
| `untyped_declaration` | `2` | Prohíbe variables/parámetros/retornos sin tipo |
| `inferred_declaration` | `2` | Prohíbe `:=`; tipo siempre explícito |
| `unassigned_variable` | `2` | Uso de una variable antes de asignarla |
| `unassigned_variable_op_assign` | `2` | Igual con asignación compuesta |
| `unsafe_property_access` | `2` | |
| `unsafe_method_access` | `2` | |
| `unsafe_cast` | `2` | |
| `unsafe_call_argument` | `2` | |
| `unsafe_void_return` | `2` | Uso o retorno de un valor `void` |
| `unused_variable` | `2` | |
| `unused_local_constant` | `2` | |
| `unused_private_class_variable` | `2` | |
| `unused_parameter` | `2` | Los parámetros no usados (p. ej. en métodos base) se nombran con prefijo `_`, que el motor excluye de esta advertencia |
| `unused_signal` | `2` | La advertencia se produce cuando una señal se declara y la propia clase nunca la emite. Regla: no se declaran señales “para el futuro”; una señal nace con su emisor (coherente con “no introducir sistemas de fases futuras”) |
| `shadowed_variable` | `2` | |
| `shadowed_variable_base_class` | `2` | |
| `shadowed_global_identifier` | `2` | |
| `unreachable_code` | `2` | |
| `unreachable_pattern` | `2` | |
| `standalone_expression` | `2` | |
| `standalone_ternary` | `2` | |
| `incompatible_ternary` | `2` | |
| `static_called_on_instance` | `2` | Llamar un método estático desde una instancia |
| `missing_tool` | `2` | Script que usa APIs de editor sin `@tool` |
| `redundant_static_unload` | `2` | |
| `redundant_await` | `2` | |
| `assert_always_true` / `assert_always_false` | `2` | |
| `int_as_enum_without_cast` | `2` | Entero usado como enum sin cast explícito |
| `int_as_enum_without_match` | `2` | Entero usado como enum sin `match` exhaustivo |
| `enum_variable_without_default` | `2` | Variable de enum sin valor inicial explícito |
| `empty_file` | `2` | Archivo de script vacío |
| `deprecated_keyword` | `2` | |
| `confusable_identifier` | `2` | Identificadores visualmente confundibles |
| `confusable_local_declaration` | `2` | |
| `confusable_local_usage` | `2` | |
| `confusable_capture_reassignment` | `2` | |
| `confusable_temporary_modification` | `2` | |
| `property_used_as_function` | `2` | |
| `constant_used_as_function` | `2` | |
| `function_used_as_property` | `2` | |
| `return_value_discarded` | `0` | Ruido excesivo con APIs del motor (p. ej. `connect`) |
| `integer_division` | `0` | La división entera es legítima y GDScript no tiene un operador distinto para expresarla, por lo que la advertencia no puede resolverse sin supresión. Regla compensatoria en docs/03: en cálculos de coma flotante se usan literales y variables `float`; una división `int / int` intencionada lleva comentario |
| `narrowing_conversion` | `2` | |

Las categorías no listadas conservan el valor por defecto de 4.7.2 y ninguna queda en `1`: `inference_on_variant`, `native_method_override`, `get_node_default_without_onready` y `onready_with_export` ya vienen en `2`; `missing_await` viene en `0`.

Criterio de aceptación: con esta configuración, el proyecto abre y se ejecuta con **cero** errores y **cero** advertencias de GDScript procedentes de `res://`. Los mensajes del motor ajenos a los scripts (p. ej. del controlador de vídeo) no cuentan, pero se anotan en el informe si aparecen.

## 6. Física

| Clave | Valor |
|---|---|
| `physics/common/physics_ticks_per_second` | `60` (por defecto) |
| `physics/3d/default_gravity` | `9.8` (por defecto) |
| `physics/common/physics_interpolation` | `false` inicialmente; se evalúa (ver arquitectura §4) |

## 7. Capas de colisión (nombradas)

| Capa | Nombre (`layer_names/3d_physics/layer_N`) | Uso |
|---|---|---|
| 1 | `world` | Terreno, arquitectura |
| 2 | `player` | Cuerpo del jugador |
| 3 | `interactable` | Colliders de objetos interactuables |
| 4 | `npc` | Personajes |

Asignación por tipo de cuerpo:

| Cuerpo | `collision_layer` | `collision_mask` | Notas |
|---|---|---|---|
| `PlayerFPS` | `player` | `world` + `npc` | Colisiona con el mundo y con personajes; no con colliders solo interactuables |
| Geometría del mundo | `world` | — (cuerpos estáticos) | |
| Collider de interactuable | `interactable` | — | Si además debe bloquear físicamente al jugador, se añade `world` a su capa |
| NPC | `npc` | `world` + `player` | Configuración definitiva al implementar personajes |
| `InteractionRay` | — | `world` + `interactable` | El mundo bloquea la línea de visión: no se interactúa a través de paredes |

## 8. Autoloads

Un autoload solo se registra en `project.godot` cuando tiene una responsabilidad real (docs/02 §3).

| Nombre | Ruta | Fase |
|---|---|---|
| `GameManager` | `res://core/autoload/game_manager.gd` | 1 |
| `AudioManager` | `res://core/autoload/audio_manager.gd` | 2 |
| `GraphicsSettings` | `res://core/systems/graphics/graphics_settings.gd` | 3 |
| `CampaignState` | `res://core/autoload/campaign_state.gd` | 3 |
| `SessionLog` | `res://core/autoload/session_log.gd` | 3 |
| `SaveManager` | `res://core/autoload/save_manager.gd` | F1 |
| `WorldClock` | `res://core/world/world_clock.gd` | F1 |
| `WorldState` | `res://core/world/world_state.gd` | F1 |
| `ContentRegistry` | `res://core/systems/campaigns/content_registry.gd` | F1 |

> **Estado:** los cinco primeros están implementados. Los cuatro de F1 son la configuración prevista; no se registran hasta que existan con sus pruebas y el responsable apruebe el sistema.

## 8.1. Addons

Ningún addon está adoptado todavía. Los candidatos son **Terrain3D 1.1.0** y **Cyclops Level Builder 1.5.2**, ambos MIT. Se instalan solo después de los spikes de F1, con versión fijada, licencia registrada y verificación de importación/exportación. `res://addons` queda excluido de las advertencias de GDScript (ver §5) y del lint de archivos nuevos.

## 8.2. Ajustes de mundo (previstos)

| Clave | Valor | Estado |
|---|---|---|
| `memorias/world/sector_size` | `256` | Previsto |
| `memorias/world/stream_radius` | `2` | Previsto |
| `memorias/world/unload_radius` | `3` | Previsto |
| `memorias/world/time_scale` | `2.0` (minutos reales por hora de juego) | Previsto |
| `memorias/campaign/first` | `res://campaigns/01_pachacutec/campaign.tres` | Implementado |

## 9. Localización

En `internationalization/locale/translations` se registran los archivos de textos generados a partir de las tablas CSV de docs/02 §7. Idioma inicial y por defecto: `es`.
