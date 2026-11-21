class_name CharacterState
extends Node
## Estado de un personaje del RPG: salud, ánimo, habilidades y reputación.
##
## No conoce la UI ni la campaña. La UI se suscribe a las señales. El aliento
## sigue viviendo en [StaminaComponent]; este nodo no lo duplica.
##
## Las habilidades suben por uso, no por experiencia: cada umbral de
## [constant SKILL_THRESHOLDS] concede un rango, de 0 a 5. La reputación se
## mueve entre −2 y +2 por grupo (llacta, comitiva, Cusco).

signal health_changed(current: float, maximum: float)
signal morale_changed(current: float, maximum: float)
signal skill_changed(skill: StringName, rank: int)
signal reputation_changed(group: StringName, value: int)
signal died

## Usos necesarios para cada rango de habilidad. El índice 0 da el rango 1.
const SKILL_THRESHOLDS: Array[int] = [3, 8, 15, 24, 35]
## Rango máximo de una habilidad.
const MAX_SKILL_RANK: int = 5
## Límite de reputación por grupo.
const MIN_REPUTATION: int = -2
const MAX_REPUTATION: int = 2

@export var max_health: float = 100.0
@export var max_morale: float = 100.0

var health: float = 100.0
var morale: float = 100.0

var _skill_uses: Dictionary[StringName, int] = {}
var _skill_ranks: Dictionary[StringName, int] = {}
var _reputation: Dictionary[StringName, int] = {}


func _ready() -> void:
	health = clampf(health, 0.0, max_health)
	morale = clampf(morale, 0.0, max_morale)


## Devuelve la salud actual.
func get_health() -> float:
	return health


## Devuelve el máximo de salud.
func get_max_health() -> float:
	return max_health


## Devuelve el ánimo actual.
func get_morale() -> float:
	return morale


## Devuelve el máximo de ánimo.
func get_max_morale() -> float:
	return max_morale


## Indica si el personaje sigue en pie.
func is_alive() -> bool:
	return health > 0.0


## Aplica daño. Al llegar a cero emite [signal died] una sola vez.
func damage(amount: float) -> void:
	if amount <= 0.0 or not is_alive():
		return
	var was_alive: bool = is_alive()
	health = clampf(health - amount, 0.0, max_health)
	health_changed.emit(health, max_health)
	if was_alive and not is_alive():
		died.emit()


## Devuelve al personaje a la vida. Sin valor, con la salud completa.
func revive(health_value: float = -1.0) -> void:
	var target: float = max_health if health_value < 0.0 else health_value
	health = clampf(target, 1.0, max_health)
	health_changed.emit(health, max_health)


## Recupera salud sin pasar del máximo.
func heal(amount: float) -> void:
	if amount <= 0.0 or not is_alive():
		return
	health = clampf(health + amount, 0.0, max_health)
	health_changed.emit(health, max_health)


## Cambia el ánimo dentro de sus límites.
func change_morale(delta: float) -> void:
	if is_zero_approx(delta):
		return
	morale = clampf(morale + delta, 0.0, max_morale)
	morale_changed.emit(morale, max_morale)


## Rango actual de una habilidad, de 0 a 5.
func get_skill(skill: StringName) -> int:
	return _skill_ranks.get(skill, 0)


## Usos acumulados de una habilidad.
func get_skill_uses(skill: StringName) -> int:
	return _skill_uses.get(skill, 0)


## Suma usos a una habilidad y devuelve su rango resultante.
##
## Emite [signal skill_changed] solo cuando el rango cambia.
func register_skill_use(skill: StringName, uses: int = 1) -> int:
	if skill == &"" or uses <= 0:
		return get_skill(skill)
	var previous_rank: int = get_skill(skill)
	var total: int = get_skill_uses(skill) + uses
	_skill_uses[skill] = total
	var rank: int = rank_for_uses(total)
	_skill_ranks[skill] = rank
	if rank != previous_rank:
		skill_changed.emit(skill, rank)
	return rank


## Fija los usos de una habilidad y recalcula su rango (restauración de estado).
func set_skill_uses(skill: StringName, uses: int) -> void:
	if skill == &"":
		return
	var previous_rank: int = get_skill(skill)
	var total: int = maxi(uses, 0)
	_skill_uses[skill] = total
	var rank: int = rank_for_uses(total)
	_skill_ranks[skill] = rank
	if rank != previous_rank:
		skill_changed.emit(skill, rank)


## Reputación actual con un grupo.
func get_reputation(group: StringName) -> int:
	return _reputation.get(group, 0)


## Fija la reputación con un grupo, dentro de los límites.
func set_reputation(group: StringName, value: int) -> void:
	if group == &"":
		return
	var clamped: int = clampi(value, MIN_REPUTATION, MAX_REPUTATION)
	if clamped == get_reputation(group):
		return
	_reputation[group] = clamped
	reputation_changed.emit(group, clamped)


## Suma o resta reputación con un grupo y devuelve el valor resultante.
func change_reputation(group: StringName, delta: int) -> int:
	set_reputation(group, get_reputation(group) + delta)
	return get_reputation(group)


## Rango que corresponde a un número de usos.
static func rank_for_uses(uses: int) -> int:
	var rank: int = 0
	for threshold: int in SKILL_THRESHOLDS:
		if uses >= threshold:
			rank += 1
	return mini(rank, MAX_SKILL_RANK)


## Vuelve al estado inicial: salud y ánimo llenos, sin usos ni reputación.
func reset() -> void:
	health = max_health
	morale = max_morale
	_skill_uses.clear()
	_skill_ranks.clear()
	_reputation.clear()
	health_changed.emit(health, max_health)
	morale_changed.emit(morale, max_morale)
