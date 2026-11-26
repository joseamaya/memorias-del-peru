class_name AlliedWarrior
extends CharacterBody3D
## Vecino que sale a la defensa junto al jugador.
##
## Versión mínima y legible: busca al chanca más cercano, se le acerca y golpea.
## Si no queda ninguno, vuelve junto al jugador. No muere: los chancas van a por
## el jugador, y una IA de aliados completa no cabe en la slice. Es bloqueo.

const BODY_RADIUS: float = 0.38
const BODY_HEIGHT: float = 1.72
const GRAVITY: float = 24.0
const ALLY_LAYER: int = 16
const ATTACK_RANGE: float = 1.8
const ATTACK_DAMAGE: float = 12.0
const ATTACK_COOLDOWN: float = 1.2
const STOP_DISTANCE: float = 1.25
const BODY_COLOR: Color = Color(0.30, 0.45, 0.55)
const HEAD_COLOR: Color = Color(0.60, 0.52, 0.38)

var player: PlayerFPS = null

var _mesh: MeshInstance3D = null
var _cooldown: float = 0.0
var _slot: int = 0
var _tents: Array[CampLayout.Tent] = []


func _ready() -> void:
	collision_layer = ALLY_LAYER
	collision_mask = 3
	floor_snap_length = 0.35
	floor_max_angle = deg_to_rad(50.0)
	_build_body()
	add_to_group(&"allied_warrior")


func setup(player_node: PlayerFPS, at: Vector3, slot: int = 0) -> void:
	player = player_node
	global_position = at
	_slot = slot


## Declara las tiendas que debe rodear.
func set_obstacles(tents: Array[CampLayout.Tent]) -> void:
	_tents = tents


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_cooldown = maxf(_cooldown - delta, 0.0)
	var target: ChancaWarrior = _nearest_enemy()
	if target != null:
		_engage(target, delta)
	elif player != null and is_instance_valid(player):
		_follow_player()
	else:
		velocity.x = 0.0
		velocity.z = 0.0
	_separate_from_allies()
	_avoid_obstacles()
	# Segunda pasada: la evitación de tiendas no puede devolver a dos aliados al
	# mismo punto.
	_separate_from_allies()
	move_and_slide()


## Rodea las tiendas sin cambiar la velocidad vertical que aplica la gravedad.
func _avoid_obstacles() -> void:
	if _tents.is_empty():
		return
	var adjusted: Vector3 = CampAvoidance.steer(
		velocity, global_position, _tents, BODY_RADIUS, _slot
	)
	velocity.x = adjusted.x
	velocity.z = adjusted.z


func _engage(target: ChancaWarrior, _delta: float) -> void:
	var to_target: Vector3 = target.global_position - global_position
	to_target.y = 0.0
	var distance: float = to_target.length()
	var direction: Vector3 = to_target.normalized() if distance > 0.01 else Vector3.FORWARD
	if distance > STOP_DISTANCE:
		velocity.x = direction.x * AlliedFormation.SPEED
		velocity.z = direction.z * AlliedFormation.SPEED
	else:
		velocity.x = 0.0
		velocity.z = 0.0
		_face(direction)
		if distance <= ATTACK_RANGE and _cooldown <= 0.0 and not target.is_dead():
			target.take_damage(ATTACK_DAMAGE)
			_cooldown = ATTACK_COOLDOWN


func _follow_player() -> void:
	var forward: Vector3 = -player.global_transform.basis.z
	var desired: Vector3 = AlliedFormation.follow_velocity(
		global_position, player.global_position, forward, _slot, _tents
	)
	velocity.x = desired.x
	velocity.z = desired.z


## Empuja al aliado fuera de sus compañeros para que no se apilen en combate.
func _separate_from_allies() -> void:
	var others: Array[Vector3] = []
	for node: Node in get_tree().get_nodes_in_group(&"allied_warrior"):
		var ally: AlliedWarrior = node as AlliedWarrior
		if ally == null or ally == self:
			continue
		others.append(ally.global_position)
	if others.is_empty():
		return
	var adjusted: Vector3 = AlliedFormation.separate_velocity(
		Vector3(velocity.x, 0.0, velocity.z), global_position, others, _slot
	)
	velocity.x = adjusted.x
	velocity.z = adjusted.z


func _nearest_enemy() -> ChancaWarrior:
	var best: ChancaWarrior = null
	var best_distance: float = 32.0
	for node: Node in get_tree().get_nodes_in_group(&"chanca_warrior"):
		var enemy: ChancaWarrior = node as ChancaWarrior
		if enemy == null or enemy.is_dead() or not is_instance_valid(enemy):
			continue
		var distance: float = global_position.distance_to(enemy.global_position)
		if distance < best_distance:
			best = enemy
			best_distance = distance
	return best


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
	cap.bottom_radius = 0.22
	cap.height = 0.24
	cap.radial_segments = 7
	head.mesh = cap
	var head_cloth: StandardMaterial3D = StandardMaterial3D.new()
	head_cloth.albedo_color = HEAD_COLOR
	head_cloth.roughness = 0.95
	head.material_override = head_cloth
	head.position = Vector3(0.0, BODY_HEIGHT - 0.04, 0.0)
	add_child(head)
	var shape: CollisionShape3D = CollisionShape3D.new()
	shape.name = "Collider"
	var box: CapsuleShape3D = CapsuleShape3D.new()
	box.radius = BODY_RADIUS
	box.height = BODY_HEIGHT
	shape.shape = box
	shape.position = Vector3(0.0, BODY_HEIGHT * 0.5, 0.0)
	add_child(shape)
