class_name TaskPoint
extends Interactable
## Punto de encargo del acto I: una acción concreta en un objeto del mundo.
##
## No muestra tarjetas ni marcadores: el jugador lo enfoca, ve la acción en la
## indicación («Acarrear agua») y pulsa E. Consume aliento y avisa una sola vez.
## La campaña decide qué significa cada encargo.

signal completed(task_id: StringName)

## Identificador del encargo (`agua`, `maiz`, `telar`, `pirca`).
@export var task_id: StringName = &""
## Clave de la indicación de interacción.
@export var prompt_key: StringName = &"PCH_TASK"
## Aliento que cuesta completar la acción.
@export var stamina_cost: float = 10.0

var _done: bool = false


## Indica si el encargo sigue disponible.
func is_available() -> bool:
	return not _done and task_id != &""


## Texto de la indicación, ya traducido.
func get_interaction_text() -> String:
	return tr(String(prompt_key))


## Ejecuta la acción del encargo una sola vez.
func interact(interactor: Node3D) -> void:
	if not is_available():
		return
	var stamina: StaminaComponent = StaminaComponent.find_in(interactor)
	if stamina != null:
		stamina.consume(stamina_cost)
	_done = true
	completed.emit(task_id)


## Indica si el encargo ya se completó.
func is_done() -> bool:
	return _done


## Vuelve a dejarlo disponible, para pruebas o reinicios.
func reset() -> void:
	_done = false
