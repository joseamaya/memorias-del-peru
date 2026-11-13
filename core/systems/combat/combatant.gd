class_name Combatant
extends Node
## Combatiente del RPG: envuelve un [CharacterState], un arma y el aliento.
##
## No conoce la escena ni la UI. La campaña decide a quién apunta, reproduce la
## animación y resuelve el proyectil; este nodo aplica las reglas: coste de
## aliento, espera entre golpes, daño, aturdimiento y derribo.
##
## El rango de habilidad lo aporta el [CharacterState]; el uso de la habilidad
## se registra cuando el golpe acierta, no al lanzarlo.

signal attacked(damage: float)
signal damaged(amount: float, remaining: float)
signal defeated
signal fled

enum State {
	READY,
	ATTACKING,
	STAGGERED,
	FLEEING,
	DOWN,
}

## Estado del personaje.
@export var character: CharacterState = null
## Arma equipada.
@export var weapon: CombatWeapon = null
## Aliento; si es `null`, atacar no cuesta.
@export var stamina: StaminaComponent = null
## Bando: `player`, `llacta`, `chanca`…
@export var team: StringName = &"player"
## Tiempo de aturdimiento tras recibir un golpe.
@export var stagger_seconds: float = 0.35

var state: State = State.READY

var _cooldown: float = 0.0
var _stagger: float = 0.0


func _process(delta: float) -> void:
	advance(delta)


## Avanza esperas y aturdimiento. Público para las pruebas.
func advance(delta: float) -> void:
	if delta <= 0.0:
		return
	if _cooldown > 0.0:
		_cooldown = maxf(_cooldown - delta, 0.0)
	if _stagger > 0.0:
		_stagger = maxf(_stagger - delta, 0.0)
	if state == State.ATTACKING and _cooldown <= 0.0:
		state = State.READY
	elif state == State.STAGGERED and _stagger <= 0.0:
		state = State.READY


## Indica si puede atacar ahora mismo.
func can_attack() -> bool:
	if character == null or not character.is_alive():
		return false
	if weapon == null or weapon.is_shield():
		return false
	if state != State.READY:
		return false
	if stamina != null and stamina.get_current() < weapon.stamina_cost:
		return false
	return true


## Ejecuta un ataque con la carga indicada (0–1) y devuelve el daño.
##
## Devuelve 0 si no puede atacar. Consume aliento y arranca la espera; el daño
## se aplica al objetivo desde la campaña con [method take_damage].
func attack(charge: float) -> float:
	if not can_attack():
		return 0.0
	if stamina != null:
		stamina.consume(weapon.stamina_cost)
	var damage: float = CombatMath.damage(weapon, character.get_skill(_skill_for_weapon()), charge)
	state = State.ATTACKING
	_cooldown = weapon.cooldown_seconds
	attacked.emit(damage)
	return damage


## Registra un acierto: sube la habilidad correspondiente al arma.
func register_hit() -> void:
	if character != null and weapon != null:
		character.register_skill_use(_skill_for_weapon(), 1)


## Aplica daño y pérdida de ánimo. Un golpe deja al combatiente aturdido.
func take_damage(amount: float, morale_loss: float = 0.0) -> void:
	if character == null or not character.is_alive() or amount <= 0.0:
		return
	character.damage(amount)
	if not is_zero_approx(morale_loss):
		character.change_morale(-morale_loss)
	damaged.emit(amount, character.get_health())
	if not character.is_alive():
		state = State.DOWN
		defeated.emit()
		return
	state = State.STAGGERED
	_stagger = stagger_seconds


## Huye: deja de atacar y lo anuncia. La campaña decide el movimiento.
func flee() -> void:
	if state == State.DOWN or state == State.FLEEING:
		return
	state = State.FLEEING
	fled.emit()


## Indica si está derribado.
func is_down() -> bool:
	return state == State.DOWN


## Indica si está huyendo.
func is_fleeing() -> bool:
	return state == State.FLEEING


## Vuelve al estado inicial para un nuevo combate.
func reset() -> void:
	state = State.READY
	_cooldown = 0.0
	_stagger = 0.0


func _skill_for_weapon() -> StringName:
	if weapon == null:
		return &"mano"
	return &"honda" if weapon.is_ranged() else &"mano"
