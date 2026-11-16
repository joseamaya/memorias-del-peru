class_name CombatLoadout
extends Node
## Selección de arma del jugador: honda, porra y escudo.
##
## No conoce la escena ni la UI. La campaña le pasa el [CharacterState], el
## aliento y el [Combatant]; este nodo cambia el arma activa, cobra la munición
## de la honda, expone el bloqueo del escudo y lleva el compás del golpe:
## anticipación, ventana activa y recuperación. El impacto lo resuelve la
## campaña cuando recibe [signal attack_active].

signal weapon_changed(index: int, weapon: CombatWeapon)
signal ammo_changed(remaining: int)
signal blocking_changed(blocking: bool)
## El golpe arrancó: el arma empieza a subir.
signal attack_started(weapon: CombatWeapon)
## El golpe llega: aquí la campaña lanza el rayo y aplica el daño.
signal attack_active(weapon: CombatWeapon)
## El golpe terminó y el control vuelve.
signal attack_finished
## El escudo paró el golpe dentro de la ventana perfecta.
signal parried
## El escudo absorbió parte del golpe sin ser perfecto.
signal blocked

enum Slot {
	SLING,
	CLUB,
	SHIELD,
}

enum AttackPhase {
	WINDUP,
	ACTIVE,
	RECOVERY,
	DONE,
}

const DEFAULT_STONES: int = 12
## Aliento que consume un golpe bloqueado sin parry.
const BLOCK_STAMINA_COST: float = 5.0

## Personaje que aporta las habilidades.
@export var character: CharacterState = null
## Aliento del jugador.
@export var stamina: StaminaComponent = null
## Combatiente que aplica las reglas de ataque.
@export var combatant: Combatant = null

var _weapons: Array[CombatWeapon] = []
var _index: int = int(Slot.SLING)
var _ammo: int = DEFAULT_STONES
var _blocking: bool = false
var _block_elapsed: float = 0.0
var _attacking: bool = false
var _attack_elapsed: float = 0.0
var _attack_phase: AttackPhase = AttackPhase.DONE
var _attack_weapon: CombatWeapon = null


func _ready() -> void:
	_build_weapons()
	_equip_current()


func _process(delta: float) -> void:
	advance(delta)


## Arma activa.
func current_weapon() -> CombatWeapon:
	if _index < 0 or _index >= _weapons.size():
		return null
	return _weapons[_index]


## Índice del arma activa.
func current_index() -> int:
	return _index


## Cambia de arma y devuelve si el índice era válido.
func switch_to(index: int) -> bool:
	if index < 0 or index >= _weapons.size():
		return false
	if _attacking:
		_cancel_attack()
	_index = index
	_set_blocking(false)
	_equip_current()
	weapon_changed.emit(_index, current_weapon())
	return true


## Munición restante de la honda.
func ammo() -> int:
	return _ammo


## Fija la munición (al entrar en un acto o al restaurar una partida).
func set_ammo(value: int) -> void:
	_ammo = maxi(value, 0)
	ammo_changed.emit(_ammo)


## Indica si el arma activa ataca a distancia.
func is_ranged() -> bool:
	var weapon: CombatWeapon = current_weapon()
	return weapon != null and weapon.is_ranged()


## Indica si el arma activa es un escudo.
func is_shield() -> bool:
	var weapon: CombatWeapon = current_weapon()
	return weapon != null and weapon.is_shield()


## Alcance máximo del arma activa, en metros.
func range_max() -> float:
	var weapon: CombatWeapon = current_weapon()
	return weapon.range_max if weapon != null else 0.0


## Proporción de daño que bloquea el arma activa; 0 si no es escudo.
func block_ratio() -> float:
	var weapon: CombatWeapon = current_weapon()
	return weapon.block_ratio if weapon != null and weapon.is_shield() else 0.0


## Indica si el jugador mantiene el bloqueo.
func is_blocking() -> bool:
	return _blocking


## Activa o desactiva el bloqueo. Solo el escudo reduce daño.
func set_blocking(value: bool) -> void:
	_set_blocking(value)


## Indica si el bloqueo está dentro de la ventana de parry.
func is_parry_window() -> bool:
	var weapon: CombatWeapon = current_weapon()
	return (
		_blocking
		and weapon != null
		and weapon.is_shield()
		and _block_elapsed <= weapon.parry_window_seconds
	)


## Indica si el arma activa puede atacar ahora.
func can_attack() -> bool:
	if _attacking or combatant == null or is_shield():
		return false
	if is_ranged() and _ammo <= 0:
		return false
	return combatant.can_attack()


## Ataca con el arma activa. La honda consume una piedra y devuelve el daño
## calculado; el impacto se resuelve al recibir [signal attack_active].
func attack(charge: float) -> float:
	if not can_attack():
		return 0.0
	if is_ranged():
		_ammo = maxi(_ammo - 1, 0)
		ammo_changed.emit(_ammo)
	var damage: float = combatant.attack(charge)
	if damage <= 0.0:
		return 0.0
	_attacking = true
	_attack_elapsed = 0.0
	_attack_phase = AttackPhase.WINDUP
	_attack_weapon = current_weapon()
	attack_started.emit(_attack_weapon)
	return damage


## Avanza el compás del golpe y la ventana de parry. Público para las pruebas.
func advance(delta: float) -> void:
	if delta <= 0.0:
		return
	if _blocking:
		_block_elapsed += delta
	if not _attacking:
		return
	_attack_elapsed += delta
	var previous: AttackPhase = _attack_phase
	var next: AttackPhase = _phase_at(_attack_elapsed, _attack_weapon)
	if next == previous:
		return
	_attack_phase = next
	if next == AttackPhase.ACTIVE:
		attack_active.emit(_attack_weapon)
	elif next == AttackPhase.RECOVERY and previous == AttackPhase.WINDUP:
		attack_active.emit(_attack_weapon)
	elif next == AttackPhase.DONE:
		# Un tirón de frame puede saltarse la ventana activa entera. El golpe
		# ocurrió igual: se emite antes de cerrar para no perder el impacto.
		if previous == AttackPhase.WINDUP:
			attack_active.emit(_attack_weapon)
		_finish_attack()


## Fase actual del golpe.
func current_phase() -> AttackPhase:
	return _attack_phase


## Tiempo transcurrido del golpe.
func attack_elapsed() -> float:
	return _attack_elapsed


## Indica si hay un golpe en curso.
func is_attacking() -> bool:
	return _attacking


## Resuelve un golpe recibido: parry, bloqueo parcial o daño completo.
##
## Devuelve el daño que debe aplicarse. El parry perfecto no consume aliento;
## el bloqueo normal consume [constant BLOCK_STAMINA_COST].
func resolve_incoming_damage(amount: float) -> float:
	if amount <= 0.0 or not _blocking or not is_shield():
		return amount
	if is_parry_window():
		parried.emit()
		return 0.0
	if stamina != null:
		stamina.consume(BLOCK_STAMINA_COST)
	blocked.emit()
	return amount * (1.0 - block_ratio())


## Registra el acierto en la habilidad del arma.
func register_hit() -> void:
	if combatant != null:
		combatant.register_hit()


func _phase_at(elapsed: float, weapon: CombatWeapon) -> AttackPhase:
	if weapon == null:
		return AttackPhase.DONE
	if elapsed < weapon.windup_seconds:
		return AttackPhase.WINDUP
	if elapsed < weapon.windup_seconds + weapon.active_seconds:
		return AttackPhase.ACTIVE
	if elapsed < weapon.windup_seconds + weapon.active_seconds + weapon.recovery_seconds:
		return AttackPhase.RECOVERY
	return AttackPhase.DONE


func _finish_attack() -> void:
	_attacking = false
	_attack_weapon = null
	_attack_phase = AttackPhase.DONE
	attack_finished.emit()


func _cancel_attack() -> void:
	if _attacking:
		_finish_attack()


func _set_blocking(value: bool) -> void:
	if value and not _blocking:
		_block_elapsed = 0.0
	if _blocking == value:
		return
	_blocking = value
	blocking_changed.emit(_blocking)


func _equip_current() -> void:
	if combatant != null:
		combatant.weapon = current_weapon()


func _build_weapons() -> void:
	if not _weapons.is_empty():
		return
	_weapons = [_make_sling(), _make_club(), _make_shield()]


func _make_sling() -> CombatWeapon:
	var weapon: CombatWeapon = CombatWeapon.new()
	weapon.kind = CombatWeapon.Kind.SLING
	weapon.damage_min = 18.0
	weapon.damage_max = 32.0
	weapon.range_min = 3.0
	weapon.range_max = 28.0
	weapon.charge_full_seconds = 1.2
	weapon.stamina_cost = 10.0
	weapon.cooldown_seconds = 0.8
	weapon.windup_seconds = 0.30
	weapon.active_seconds = 0.10
	weapon.recovery_seconds = 0.40
	weapon.lunge_distance = 0.0
	return weapon


func _make_club() -> CombatWeapon:
	var weapon: CombatWeapon = CombatWeapon.new()
	weapon.kind = CombatWeapon.Kind.CLUB
	weapon.damage_min = 28.0
	weapon.damage_max = 42.0
	weapon.range_min = 0.8
	weapon.range_max = 1.6
	weapon.charge_full_seconds = 0.5
	weapon.stamina_cost = 14.0
	weapon.cooldown_seconds = 0.9
	weapon.windup_seconds = 0.22
	weapon.active_seconds = 0.14
	weapon.recovery_seconds = 0.34
	weapon.lunge_distance = 0.25
	return weapon


func _make_shield() -> CombatWeapon:
	var weapon: CombatWeapon = CombatWeapon.new()
	weapon.kind = CombatWeapon.Kind.SHIELD
	weapon.damage_min = 0.0
	weapon.damage_max = 0.0
	weapon.range_min = 0.0
	weapon.range_max = 0.0
	weapon.charge_full_seconds = 0.0
	weapon.stamina_cost = 0.0
	weapon.cooldown_seconds = 0.0
	weapon.block_ratio = 0.7
	weapon.parry_window_seconds = 0.15
	return weapon
