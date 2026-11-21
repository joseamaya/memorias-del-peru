class_name ChancaWarrior
extends CharacterBody3D
## Guerrero chanca de bloqueo: se acerca, ataca con porra y cae.
##
## La campaña lo instancia en las oleadas y le pasa el jugador y su combate.
## No conoce la batalla ni el HUD: pide la intención a [EnemyCombatant], se
## mueve sobre el terreno y aplica su golpe al jugador. La malla es una cápsula
## de blockout con un casco de tela, nada definitivo.

signal died(warrior: ChancaWarrior)
signal hit_player(damage: float)

const BODY_RADIUS: float = 0.42
const BODY_HEIGHT: float = 1.75
const SPEED: float = 2.4
const FLEE_SPEED: float = 3.1
const GRAVITY: float = 24.0
const ENEMY_LAYER: int = 8
const HEALTH: float = 60.0
const MORALE: float = 100.0
const CLUB_DAMAGE_MIN: float = 9.0
const CLUB_DAMAGE_MAX: float = 15.0
const CLUB_RANGE: float = 1.8
const CLUB_COOLDOWN: float = 1.15
const BODY_COLOR: Color = Color(0.55, 0.30, 0.22)
const HEAD_COLOR: Color = Color(0.72, 0.58, 0.38)
const DEATH_SECONDS: float = 1.4

var player: PlayerFPS = null
var combat: PlayerCombat = null
var character: CharacterState = null
var combatant: EnemyCombatant = null

var _mesh: MeshInstance3D = null
var _body: CollisionShape3D = null
var _dead: bool = false
var _death_elapsed: float = 0.0


func _ready() -> void:
	collision_layer = ENEMY_LAYER
	collision_mask = 1
	floor_snap_length = 0.35
	floor_max_angle = deg_to_rad(50.0)
	_build_body()
	character = CharacterState.new()
	character.name = "CharacterState"
	character.max_health = HEALTH
	character.health = HEALTH
	character.max_morale = MORALE
	character.morale = MORALE
	add_child(character)
	combatant = EnemyCombatant.new()
	combatant.name = "Combatant"
	combatant.team = &"chanca"
	add_child(combatant)
	combatant.character = character
	combatant.weapon = _club()
	combatant.defeated.connect(_on_defeated)


## Ata al jugador y a su combate. Debe llamarse después de añadirlo al árbol.
func setup(player_node: PlayerFPS, combat_node: PlayerCombat, at: Vector3) -> void:
	player = player_node
	combat = combat_node
	global_position = at


func is_dead() -> bool:
	return _dead


func get_health() -> float:
	return character.get_health() if character != null else 0.0


## Golpe recibido. Lo aplica el rayo del jugador o una prueba.
func take_damage(amount: float) -> void:
	if _dead or amount <= 0.0:
		return
	combatant.take_damage(amount)


func _physics_process(delta: float) -> void:
	if _dead:
		_death_elapsed += delta
		if _death_elapsed >= DEATH_SECONDS:
			queue_free()
		return
	_apply_gravity(delta)
	if player == null or not is_instance_valid(player) or combat == null:
		move_and_slide()
		return
	var to_target: Vector3 = player.global_position - global_position
	to_target.y = 0.0
	var distance: float = to_target.length()
	var direction: Vector3 = to_target.normalized() if distance > 0.01 else Vector3.FORWARD
	var intent: int = combatant.think(delta, distance, true)
	match intent:
		EnemyCombatant.Intent.APPROACH:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		EnemyCombatant.Intent.ATTACK:
			velocity.x = 0.0
			velocity.z = 0.0
			_face(direction)
			if combatant.can_attack() and distance <= CLUB_RANGE:
				var damage: float = combatant.try_attack(distance)
				if damage > 0.0 and not combat.is_dead():
					combat.take_damage(damage)
					hit_player.emit(damage)
		EnemyCombatant.Intent.FLEE:
			velocity.x = -direction.x * FLEE_SPEED
			velocity.z = -direction.z * FLEE_SPEED
		_:
			velocity.x = 0.0
			velocity.z = 0.0
	move_and_slide()


func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y -= GRAVITY * delta


func _face(direction: Vector3) -> void:
	if direction.length_squared() < 0.001:
		return
	var yaw: float = atan2(-direction.x, -direction.z)
	rotation.y = lerp_angle(rotation.y, yaw, 0.2)


func _on_defeated() -> void:
	if _dead:
		return
	_dead = true
	_death_elapsed = 0.0
	collision_layer = 0
	if _body != null:
		_body.disabled = true
	if _mesh != null:
		var tween: Tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(_mesh, "rotation_degrees:x", 88.0, 0.5)
		tween.tween_property(_mesh, "position:y", 0.25, 0.5)
	died.emit(self)


func _build_body() -> void:
	_mesh = MeshInstance3D.new()
	_mesh.name = "Body"
	var capsule: CapsuleMesh = CapsuleMesh.new()
	capsule.radius = BODY_RADIUS
	capsule.height = BODY_HEIGHT
	capsule.radial_segments = 8
	capsule.rings = 4
	_mesh.mesh = capsule
	var cloth: StandardMaterial3D = StandardMaterial3D.new()
	cloth.albedo_color = BODY_COLOR
	cloth.roughness = 0.95
	_mesh.material_override = cloth
	_mesh.position = Vector3(0.0, BODY_HEIGHT * 0.5, 0.0)
	add_child(_mesh)
	var head: MeshInstance3D = MeshInstance3D.new()
	head.name = "Head"
	var cap: CylinderMesh = CylinderMesh.new()
	cap.top_radius = 0.0
	cap.bottom_radius = 0.24
	cap.height = 0.26
	cap.radial_segments = 7
	head.mesh = cap
	var head_cloth: StandardMaterial3D = StandardMaterial3D.new()
	head_cloth.albedo_color = HEAD_COLOR
	head_cloth.roughness = 0.95
	head.material_override = head_cloth
	head.position = Vector3(0.0, BODY_HEIGHT - 0.05, 0.0)
	add_child(head)
	var shape: CollisionShape3D = CollisionShape3D.new()
	shape.name = "Body"
	var box: CapsuleShape3D = CapsuleShape3D.new()
	box.radius = BODY_RADIUS
	box.height = BODY_HEIGHT
	shape.shape = box
	shape.position = Vector3(0.0, BODY_HEIGHT * 0.5, 0.0)
	_body = shape
	add_child(shape)


func _club() -> CombatWeapon:
	var weapon: CombatWeapon = CombatWeapon.new()
	weapon.kind = CombatWeapon.Kind.CLUB
	weapon.damage_min = CLUB_DAMAGE_MIN
	weapon.damage_max = CLUB_DAMAGE_MAX
	weapon.range_min = 0.7
	weapon.range_max = CLUB_RANGE
	weapon.charge_full_seconds = 0.6
	weapon.stamina_cost = 0.0
	weapon.cooldown_seconds = CLUB_COOLDOWN
	weapon.windup_seconds = 0.28
	weapon.active_seconds = 0.12
	weapon.recovery_seconds = 0.35
	return weapon
