class_name AlliedWarrior
extends CharacterBody3D
## Vecino que sale a la defensa junto al jugador.
##
## Versión mínima y legible: busca al chanca más cercano, se le acerca y golpea.
## Si no queda ninguno, vuelve junto al jugador. No muere: los chancas van a por
## el jugador, y una IA de aliados completa no cabe en la slice. Es bloqueo.

const BODY_RADIUS: float = 0.38
const BODY_HEIGHT: float = 1.72
const SPEED: float = 2.7
const GRAVITY: float = 24.0
const ALLY_LAYER: int = 16
const ATTACK_RANGE: float = 1.8
const ATTACK_DAMAGE: float = 12.0
const ATTACK_COOLDOWN: float = 1.2
const STOP_DISTANCE: float = 1.25
## Punto de espera detrás del jugador, no delante de su mirada.
const FOLLOW_DISTANCE: float = 3.6
## Formación de espera: tres columnas por dos filas detrás del jugador.
const SLOT_COLUMNS: int = 3
const SLOT_LATERAL: float = 1.5
const SLOT_DEPTH: float = 1.2
## Si el jugador se le echa encima, el aliado cede el paso en vez de bloquearlo.
const PERSONAL_SPACE: float = 2.4
const YIELD_SPEED: float = 3.2
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
	_avoid_obstacles()
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
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0.0
		velocity.z = 0.0
		_face(direction)
		if distance <= ATTACK_RANGE and _cooldown <= 0.0 and not target.is_dead():
			target.take_damage(ATTACK_DAMAGE)
			_cooldown = ATTACK_COOLDOWN


func _follow_player() -> void:
	var forward: Vector3 = -player.global_transform.basis.z
	var desired: Vector3 = follow_velocity(global_position, player.global_position, forward, _slot)
	velocity.x = desired.x
	velocity.z = desired.z


## Punto de espera de un aliado según su hueco de formación.
static func slot_position(player_position: Vector3, player_forward: Vector3, slot: int) -> Vector3:
	var forward: Vector3 = Vector3(player_forward.x, 0.0, player_forward.z)
	forward = forward.normalized() if forward.length_squared() > 0.001 else Vector3.FORWARD
	var side: Vector3 = Vector3(-forward.z, 0.0, forward.x)
	var row: int = floori(float(slot) / float(SLOT_COLUMNS))
	var column: int = slot % SLOT_COLUMNS
	var lateral: float = float(column - 1) * SLOT_LATERAL
	var depth: float = FOLLOW_DISTANCE + float(row) * SLOT_DEPTH
	return player_position - forward * depth + side * lateral


## Velocidad horizontal del aliado al seguir al jugador, sin estado.
##
## Espera en su hueco de formación y, si el jugador lo tiene encima o el camino
## al hueco cruza su espacio personal, lo rodea en vez de atravesarlo. Antes
## todos compartían un único punto y, en el borde de los 2,4 m, alternaban entre
## ceder y volver al punto: temblaban sin avanzar.
static func follow_velocity(
	ally_position: Vector3,
	player_position: Vector3,
	player_forward: Vector3,
	slot: int = 0,
) -> Vector3:
	var forward: Vector3 = Vector3(player_forward.x, 0.0, player_forward.z)
	forward = forward.normalized() if forward.length_squared() > 0.001 else Vector3.FORWARD
	var spot: Vector3 = slot_position(player_position, forward, slot)
	var to_ally: Vector3 = Vector3(
		ally_position.x - player_position.x, 0.0, ally_position.z - player_position.z
	)
	var to_spot: Vector3 = Vector3(spot.x - ally_position.x, 0.0, spot.z - ally_position.z)
	var distance: float = to_ally.length()
	var spot_radius: float = (
		Vector2(spot.x - player_position.x, spot.z - player_position.z).length()
	)
	if (
		distance < PERSONAL_SPACE
		or _crosses_personal_space(ally_position, spot, player_position, PERSONAL_SPACE + 0.25)
	):
		return _orbit_velocity(to_ally, to_spot, forward, spot_radius, slot)
	if to_spot.length() <= 0.4:
		return Vector3.ZERO
	return to_spot.normalized() * SPEED


## ¿El segmento aliado → hueco pasa demasiado cerca del jugador?
static func _crosses_personal_space(
	ally_position: Vector3, spot: Vector3, player_position: Vector3, radius: float
) -> bool:
	var from: Vector2 = Vector2(ally_position.x, ally_position.z)
	var to: Vector2 = Vector2(spot.x, spot.z)
	var center: Vector2 = Vector2(player_position.x, player_position.z)
	var segment: Vector2 = to - from
	var length_squared: float = segment.length_squared()
	var t: float = 0.0
	if length_squared > 0.0001:
		t = clampf((center - from).dot(segment) / length_squared, 0.0, 1.0)
	var closest: Vector2 = from + segment * t
	if t <= 0.001 and to.distance_to(center) >= from.distance_to(center):
		# El camino solo se aleja del jugador: no hay nada que rodear.
		return false
	if t >= 0.999 and from.distance_to(center) >= to.distance_to(center):
		return false
	return closest.distance_to(center) < radius


## Rodea al jugador manteniendo la distancia mientras llega a su hueco.
static func _orbit_velocity(
	to_ally: Vector3,
	to_spot: Vector3,
	forward: Vector3,
	spot_radius: float,
	slot: int,
) -> Vector3:
	var distance: float = to_ally.length()
	var radial: Vector3 = to_ally.normalized() if distance > 0.01 else -forward
	var tangent: Vector3 = Vector3(-radial.z, 0.0, radial.x)
	var toward_spot: Vector3 = (
		to_spot.normalized() if to_spot.length_squared() > 0.0001 else -radial
	)
	if absf(tangent.dot(toward_spot)) < 0.05:
		tangent = tangent if slot % 2 == 0 else -tangent
	elif tangent.dot(toward_spot) < 0.0:
		tangent = -tangent
	var radial_speed: float = 0.0
	if distance < PERSONAL_SPACE and radial.dot(forward) < 0.2:
		# Detrás o al lado: se aparta hacia fuera. Delante solo cede de lado,
		# para no retroceder por la línea de mirada del jugador.
		radial_speed = YIELD_SPEED
	elif distance > spot_radius + 0.6:
		radial_speed = -minf((distance - spot_radius) * 1.5, SPEED)
	return (tangent * SPEED + radial * radial_speed).limit_length(SPEED)


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
