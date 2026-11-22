class_name PlayerCombat
extends Node
## Combate del jugador en primera persona: honda, porra y escudo.
##
## Envuelve [CharacterState], [Combatant] y [CombatLoadout] de Core y añade lo
## que estos no pueden saber: la entrada del jugador, el rayo hacia el enemigo,
## el arma en pantalla y el aviso del HUD. La campaña decide cuándo se arma
## ([method set_armed]); hasta entonces no hay arma ni se puede atacar.

signal died
signal damaged(amount: float)

## Capa física de los enemigos; solo el rayo de golpe la consulta.
const ENEMY_LAYER: int = 8
## Carga mínima de un toque, para que un clic rápido no salga a cero.
const MIN_CHARGE: float = 0.15
const WEAPON_PATH: String = "Head/Camera3D/FirstPersonWeapon"

var player: PlayerFPS = null
var hud: PlayerHud = null
var character: CharacterState = null
var stamina: StaminaComponent = null
var combatant: Combatant = null
var loadout: CombatLoadout = null

var _weapon_view: FirstPersonWeapon = null
var _armed: bool = false
var _charging: bool = false
var _shield_click: bool = false
var _charge_elapsed: float = 0.0
var _pending_damage: float = 0.0
## Multiplicador del daño recibido; la manta de la defensa lo baja.
var _damage_scale: float = 1.0


## Crea el estado del jugador y lo ata al HUD. Debe llamarse una sola vez.
func setup(player_node: PlayerFPS, hud_node: PlayerHud) -> void:
	player = player_node
	hud = hud_node
	character = CharacterState.new()
	character.name = "CharacterState"
	character.max_health = 120.0
	character.health = 120.0
	add_child(character)
	stamina = StaminaComponent.find_in(player)
	combatant = Combatant.new()
	combatant.name = "Combatant"
	combatant.team = &"player"
	add_child(combatant)
	combatant.character = character
	combatant.stamina = stamina
	loadout = CombatLoadout.new()
	loadout.name = "Loadout"
	add_child(loadout)
	loadout.character = character
	loadout.stamina = stamina
	loadout.combatant = combatant
	combatant.attacked.connect(_on_attack_rolled)
	loadout.attack_started.connect(_on_attack_started)
	loadout.attack_active.connect(_on_attack_active)
	loadout.blocking_changed.connect(_on_blocking_changed)
	loadout.weapon_changed.connect(_on_weapon_changed)
	loadout.ammo_changed.connect(_on_ammo_changed)
	_weapon_view = player.get_node_or_null(WEAPON_PATH) as FirstPersonWeapon
	_on_weapon_changed(loadout.current_index(), loadout.current_weapon())
	_on_ammo_changed(loadout.ammo())
	set_armed(false)
	# Fuerza al HUD a buscar el estado del jugador y enganchar la salud.
	if hud != null:
		hud.set_status("")


func is_armed() -> bool:
	return _armed


## Arma o desarma al jugador. Desarmado no hay arma en pantalla ni golpes.
func set_armed(value: bool) -> void:
	_armed = value
	_charging = false
	_shield_click = false
	if _weapon_view != null:
		_weapon_view.visible = value
	if not value:
		loadout.set_blocking(false)
	_update_hud_ammo()


## Ajusta el daño recibido (1 = normal, 0,85 = con manta).
func set_damage_scale(value: float) -> void:
	_damage_scale = clampf(value, 0.1, 1.0)


func get_damage_scale() -> float:
	return _damage_scale


func get_health() -> float:
	return character.get_health() if character != null else 0.0


func is_dead() -> bool:
	return character == null or not character.is_alive()


## Ataca con la carga dada (0–1). Público para las pruebas y para la batalla.
func try_attack(charge: float = 1.0) -> float:
	if not _armed or player == null or player.is_controls_locked():
		return 0.0
	return loadout.attack(clampf(charge, 0.0, 1.0))


## Cambia de arma: 0 honda, 1 porra, 2 escudo.
func select_weapon(index: int) -> bool:
	if not _armed:
		return false
	return loadout.switch_to(index)


## Devuelve al jugador a la vida con la salud completa.
func revive() -> void:
	if character != null:
		character.revive()


## Aplica un golpe recibido, con parry o bloqueo si el escudo está alzado.
func take_damage(amount: float) -> void:
	if amount <= 0.0 or is_dead():
		return
	var final: float = loadout.resolve_incoming_damage(amount * _damage_scale)
	character.damage(final)
	if hud != null:
		hud.flash_damage()
	damaged.emit(final)
	if not character.is_alive():
		_die()


func _unhandled_input(event: InputEvent) -> void:
	if not _armed or player == null or player.is_controls_locked():
		return
	if event.is_action_pressed("attack"):
		_start_charge()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_released("attack"):
		_release_charge()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("block"):
		loadout.set_blocking(true)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_released("block"):
		loadout.set_blocking(false)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("weapon_1"):
		loadout.switch_to(0)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("weapon_2"):
		loadout.switch_to(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("weapon_3"):
		loadout.switch_to(2)
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if _charging:
		_charge_elapsed += delta
	# El arma solo se ve armada y con los controles libres. Así no reaparece al
	# cerrar el diario si el blockout no la había equipado.
	if _weapon_view != null and player != null:
		_weapon_view.visible = _armed and not player.is_controls_locked()


func _start_charge() -> void:
	if loadout.is_shield():
		# Con el escudo, el clic izquierdo mantiene el bloqueo mientras se
		# aprieta. Antes se quedaba levantado para siempre porque la suelta no
		# tenía ningún estado que cerrar.
		loadout.set_blocking(true)
		_shield_click = true
		return
	_charging = true
	_charge_elapsed = 0.0


func _release_charge() -> void:
	if _shield_click:
		_shield_click = false
		loadout.set_blocking(false)
		return
	if not _charging:
		return
	_charging = false
	var weapon: CombatWeapon = loadout.current_weapon()
	var full: float = weapon.charge_full_seconds if weapon != null else 1.0
	var ratio: float = 1.0 if full <= 0.0 else _charge_elapsed / full
	loadout.attack(clampf(ratio, MIN_CHARGE, 1.0))


func _on_attack_rolled(damage: float) -> void:
	_pending_damage = damage


func _on_attack_started(weapon: CombatWeapon) -> void:
	if _weapon_view != null and weapon != null:
		_weapon_view.play_attack(
			weapon.windup_seconds + weapon.active_seconds, weapon.recovery_seconds
		)


## El golpe llega: rayo desde la cámara contra la capa de enemigos.
func _on_attack_active(weapon: CombatWeapon) -> void:
	if weapon == null or player == null:
		return
	var from: Vector3 = player.camera.global_position
	var forward: Vector3 = -player.camera.global_transform.basis.z
	var to: Vector3 = from + forward * weapon.range_max
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		from, to, ENEMY_LAYER
	)
	query.exclude = [player.get_rid()]
	var hit: Dictionary = player.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return
	var point: Vector3 = hit["position"]
	# El mínimo solo vale para la honda: en cuerpo a cuerpo el rayo toca la
	# superficie del rival y rechazar por cercanía anulaba todos los golpes.
	if weapon.is_ranged() and from.distance_to(point) < weapon.range_min:
		return
	var collider: Object = hit["collider"]
	if collider == null or not collider.has_method(&"take_damage"):
		return
	collider.call(&"take_damage", _pending_damage)
	loadout.register_hit()


func _on_blocking_changed(value: bool) -> void:
	if _weapon_view != null:
		_weapon_view.set_blocking(value)


func _on_weapon_changed(_index: int, weapon: CombatWeapon) -> void:
	if _weapon_view != null and weapon != null:
		_weapon_view.set_weapon(weapon.kind)
	_update_hud_ammo()


func _on_ammo_changed(_remaining: int) -> void:
	_update_hud_ammo()


## La munición solo se muestra con el arma en la mano. `set_ammo` recibe además
## si el arma activa es la honda, para que el HUD no enseñe «Piedras: 12» con el
## jugador desarmado.
func _update_hud_ammo() -> void:
	if hud != null:
		hud.set_ammo(loadout.ammo(), _armed and loadout.is_ranged())


func _die() -> void:
	_armed = false
	_charging = false
	_shield_click = false
	if _weapon_view != null:
		_weapon_view.visible = false
	loadout.set_blocking(false)
	died.emit()
