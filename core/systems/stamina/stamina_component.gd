class_name StaminaComponent
extends Node
## Estamina de un actor.
##
## Es un nodo hijo de quien tenga estamina (el jugador; en el futuro, NPC).
## Emite [signal stamina_changed] solo cuando el valor cambia.

signal stamina_changed(current: float, maximum: float)

@export var max_stamina: float = 100.0
@export var regeneration_per_second: float = 8.0
@export var regeneration_delay_seconds: float = 1.5

var _current: float = 0.0
var _time_since_spend: float = 0.0


func _ready() -> void:
	_current = max_stamina
	_time_since_spend = regeneration_delay_seconds
	stamina_changed.emit(_current, max_stamina)


func _process(delta: float) -> void:
	if _current >= max_stamina:
		return
	_time_since_spend += delta
	if _time_since_spend < regeneration_delay_seconds:
		return
	_current = minf(_current + regeneration_per_second * delta, max_stamina)
	stamina_changed.emit(_current, max_stamina)


## Devuelve la estamina actual.
func get_current() -> float:
	return _current


## Devuelve la estamina máxima.
func get_maximum() -> float:
	return max_stamina


## Indica si queda algo de estamina.
func has_stamina() -> bool:
	return _current > 0.0


## Consume estamina y devuelve lo realmente consumido.
func consume(amount: float) -> float:
	if amount <= 0.0:
		return 0.0
	var consumed: float = minf(amount, _current)
	if consumed <= 0.0:
		return 0.0
	_current -= consumed
	_time_since_spend = 0.0
	stamina_changed.emit(_current, max_stamina)
	return consumed


## Recupera estamina y devuelve lo realmente recuperado.
func restore(amount: float) -> float:
	if amount <= 0.0:
		return 0.0
	var restored: float = minf(amount, max_stamina - _current)
	if restored <= 0.0:
		return 0.0
	_current += restored
	stamina_changed.emit(_current, max_stamina)
	return restored


## Busca un componente de estamina entre los hijos directos de [param owner_node].
static func find_in(owner_node: Node) -> StaminaComponent:
	for child: Node in owner_node.get_children():
		if child is StaminaComponent:
			return child as StaminaComponent
	return null
