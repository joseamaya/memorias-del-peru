class_name AmbushEnemy
extends CharacterBody3D
## Explorador chanca del acto II.
##
## Usa un modelo propio del proyecto teñido como chanca y una porra simple. La
## lógica de combate vive en [EnemyCombatant]; este nodo la mueve, orienta al
## enemigo hacia el jugador y aplica el daño.

const SPEED: float = 2.4
const MORALE_LOSS: float = 15.0

var player: Node3D = null
var paso: Node = null
var character: CharacterState = null
var brain: EnemyCombatant = null

var _resolved: bool = false
var _visual: RealisticCharacterVisual = null
var _current_clip: StringName = &""


func _ready() -> void:
	collision_layer = 8
	collision_mask = 1
	_visual = RealisticCharacterVisual.new()
	_visual.name = "Visual"
	_visual.model_file = "pch_npc_commoner.glb"
	_visual.tint = Color(0.64, 0.44, 0.34, 1.0)
	_visual.with_porra = true
	add_child(_visual)
	var shape: CollisionShape3D = CollisionShape3D.new()
	var capsule_shape: CapsuleShape3D = CapsuleShape3D.new()
	capsule_shape.radius = 0.35
	capsule_shape.height = 1.75
	shape.shape = capsule_shape
	shape.position = Vector3(0.0, 0.875, 0.0)
	add_child(shape)
	character = CharacterState.new()
	character.name = "CharacterState"
	character.max_health = 60.0
	character.health = 60.0
	character.max_morale = 80.0
	character.morale = 80.0
	add_child(character)
	brain = EnemyCombatant.new()
	brain.character = character
	brain.weapon = _make_weapon()
	brain.team = &"chanca"
	brain.alert_radius = 30.0
	brain.flee_morale = 25.0
	add_child(brain)


## Asigna el objetivo y la escena que recibe el daño del jugador.
func setup(target: Node3D, scene: Node) -> void:
	player = target
	paso = scene


func _physics_process(delta: float) -> void:
	if _resolved or player == null or paso == null or brain == null:
		return
	if paso.call("is_ambush_active") != true:
		return
	if not character.is_alive():
		_resolve()
		return
	var distance: float = global_position.distance_to(player.global_position)
	var intent: EnemyCombatant.Intent = brain.think(delta, distance, true)
	if intent != EnemyCombatant.Intent.IDLE:
		_face(player.global_position)
	match intent:
		EnemyCombatant.Intent.APPROACH:
			_play_visual(&"Walk")
			_move_towards(player.global_position)
		EnemyCombatant.Intent.FLEE:
			_play_visual(&"Walk")
			var away: Vector3 = global_position + (global_position - player.global_position).normalized() * 10.0
			_move_towards(away)
			if distance > 30.0:
				_resolve()
		EnemyCombatant.Intent.ATTACK:
			var damage: float = brain.attack(1.0)
			if damage > 0.0:
				_play_visual(&"Sword_Attack")
				paso.call("apply_player_damage", damage)
		EnemyCombatant.Intent.IDLE:
			_play_visual(&"Idle")


## Aplica un golpe del jugador. Al perder la moral, el cerebro ordena huir.
func take_hit(amount: float) -> void:
	if _resolved or brain == null:
		return
	brain.take_damage(amount, MORALE_LOSS)
	_play_visual(&"Hit_Chest")
	if not character.is_alive():
		_resolve()


## Indica si ya no cuenta para la emboscada (derribado o huido).
func is_resolved() -> bool:
	return _resolved or not character.is_alive() or brain.is_fleeing()


## Indica si sigue en pie y en el combate.
func is_alive() -> bool:
	return not _resolved and character.is_alive() and not brain.is_fleeing()


func _play_visual(clip: StringName) -> void:
	if _visual == null or _current_clip == clip:
		return
	_current_clip = clip
	_visual.play(clip)


## Gira el cuerpo hacia el objetivo; el modelo mira hacia -Z.
func _face(target: Vector3) -> void:
	var flat: Vector3 = Vector3(target.x, global_position.y, target.z)
	if flat.distance_to(global_position) > 0.05:
		look_at(flat, Vector3.UP)


## Visual del enemigo, para las pruebas.
func visual() -> RealisticCharacterVisual:
	return _visual


func _move_towards(target: Vector3) -> void:
	var direction: Vector3 = target - global_position
	direction.y = 0.0
	if direction.length() < 0.05:
		velocity = Vector3.ZERO
		return
	direction = direction.normalized()
	velocity = direction * SPEED
	move_and_slide()


func _resolve() -> void:
	if _resolved:
		return
	_resolved = true
	visible = false
	set_physics_process(false)
	if paso != null:
		paso.call("on_enemy_resolved")


static func _make_weapon() -> CombatWeapon:
	var weapon: CombatWeapon = CombatWeapon.new()
	weapon.kind = CombatWeapon.Kind.SLING
	weapon.damage_min = 8.0
	weapon.damage_max = 14.0
	weapon.range_min = 2.0
	weapon.range_max = 22.0
	weapon.charge_full_seconds = 1.0
	weapon.stamina_cost = 0.0
	weapon.cooldown_seconds = 2.0
	return weapon
