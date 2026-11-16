class_name CombatLoadout
extends Node
## Selección de arma del jugador: honda, porra y escudo.
##
## No conoce la escena ni la UI. La campaña le pasa el [CharacterState], el
## aliento y el [Combatant]; este nodo cambia el arma activa, cobra la munición
## de la honda y expone el bloqueo del escudo. La munición se guarda fuera
## (la campaña decide si persiste entre actos).

signal weapon_changed(index: int, weapon: CombatWeapon)
signal ammo_changed(remaining: int)
signal blocking_changed(blocking: bool)

enum Slot {
	SLING,
	CLUB,
	SHIELD,
}

const DEFAULT_STONES: int = 12

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


func _ready() -> void:
	_build_weapons()
	_equip_current()


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
	if index == _index:
		return true
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


## Indica si el arma activa puede atacar ahora.
func can_attack() -> bool:
	if combatant == null or is_shield():
		return false
	if is_ranged() and _ammo <= 0:
		return false
	return combatant.can_attack()


## Ataca con el arma activa. La honda consume una piedra.
func attack(charge: float) -> float:
	if not can_attack():
		return 0.0
	if is_ranged():
		_ammo = maxi(_ammo - 1, 0)
		ammo_changed.emit(_ammo)
	return combatant.attack(charge)


## Registra el acierto en la habilidad del arma.
func register_hit() -> void:
	if combatant != null:
		combatant.register_hit()


func _set_blocking(value: bool) -> void:
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
	return weapon
