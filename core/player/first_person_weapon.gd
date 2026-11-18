class_name FirstPersonWeapon
extends Node3D
## Arma en primera persona: honda, porra y escudo.
##
## Es una malla de bloqueo, sin texturas finales. Vive bajo la cámara y cambia
## con [method set_weapon]. La campaña decide cuándo se muestra; el HUD no la
## conoce.

const REST_POSITION: Vector3 = Vector3(0.40, -0.33, -0.62)
const REST_ROTATION: Vector3 = Vector3(-8.0, 18.0, 10.0)
const ATTACK_SECONDS: float = 0.18
const RETURN_SECONDS: float = 0.28
const BLOCK_POSITION: Vector3 = Vector3(0.0, -0.28, -0.48)
const WEAPON_SCALE: float = 0.60

var _sling: Node3D = null
var _club: Node3D = null
var _shield: Node3D = null
var _kind: CombatWeapon.Kind = CombatWeapon.Kind.SLING
var _tween: Tween = null


func _ready() -> void:
	_build_sling()
	_build_club()
	_build_shield()
	scale = Vector3.ONE * WEAPON_SCALE
	position = REST_POSITION
	rotation_degrees = REST_ROTATION
	set_weapon(CombatWeapon.Kind.SLING)


## Muestra el arma indicada.
func set_weapon(kind: CombatWeapon.Kind) -> void:
	_kind = kind
	if _sling != null:
		_sling.visible = kind == CombatWeapon.Kind.SLING
	if _club != null:
		_club.visible = kind == CombatWeapon.Kind.CLUB
	if _shield != null:
		_shield.visible = kind == CombatWeapon.Kind.SHIELD
	position = REST_POSITION
	rotation_degrees = REST_ROTATION


## Arma visible (para las pruebas).
func current_kind() -> CombatWeapon.Kind:
	return _kind


## Gesto de ataque. Los tiempos se sincronizan con el compás del arma:
## [param forward_seconds] cubre anticipación y ventana activa; [param
## return_seconds], la recuperación.
func play_attack(forward_seconds: float = ATTACK_SECONDS,
		return_seconds: float = RETURN_SECONDS) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	var forward: Vector3 = REST_POSITION + Vector3(-0.08, -0.04, -0.18)
	_tween.tween_property(self, "position", forward, maxf(forward_seconds, 0.01)) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(self, "rotation_degrees",
		REST_ROTATION + Vector3(-28.0, 0.0, -18.0), maxf(forward_seconds, 0.01)) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "position", REST_POSITION, maxf(return_seconds, 0.01)) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.parallel().tween_property(self, "rotation_degrees", REST_ROTATION,
		maxf(return_seconds, 0.01)) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


## Bloqueo con escudo. En las demás armas no mueve nada.
func set_blocking(value: bool) -> void:
	if _kind != CombatWeapon.Kind.SHIELD:
		return
	if _tween != null and _tween.is_valid():
		_tween.kill()
	var target: Vector3 = BLOCK_POSITION if value else REST_POSITION
	var target_rotation: Vector3 = Vector3(-4.0, 0.0, 0.0) if value else REST_ROTATION
	_tween = create_tween()
	_tween.tween_property(self, "position", target, 0.14) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(self, "rotation_degrees", target_rotation, 0.14) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _build_sling() -> void:
	_sling = Node3D.new()
	_sling.name = "Sling"
	add_child(_sling)
	var leather: StandardMaterial3D = _material(Color(0.36, 0.24, 0.15, 1.0), 0.9)
	var stone: StandardMaterial3D = _material(Color(0.48, 0.46, 0.42, 1.0), 1.0)
	var grip: Vector3 = Vector3(0.0, 0.10, 0.0)
	var ring_center: Vector3 = Vector3(0.0, 0.015, 0.0)
	var cord: MeshInstance3D = MeshInstance3D.new()
	var torus: TorusMesh = TorusMesh.new()
	torus.inner_radius = 0.085
	torus.outer_radius = 0.095
	torus.rings = 18
	torus.ring_segments = 5
	cord.mesh = torus
	cord.material_override = leather
	# El aro cuelga vertical, de frente: el puño lo sujeta por el borde superior
	# y el antebrazo queda detrás, sin atravesarlo.
	cord.transform = Transform3D(Basis(Vector3(1.0, 0.0, 0.0), Vector3(0.0, 0.0, 1.0),
		Vector3(0.0, -1.0, 0.0)), ring_center)
	_sling.add_child(cord)
	var pouch: MeshInstance3D = MeshInstance3D.new()
	var pouch_mesh: SphereMesh = SphereMesh.new()
	pouch_mesh.radius = 0.045
	pouch_mesh.height = 0.09
	pouch_mesh.radial_segments = 10
	pouch_mesh.rings = 5
	pouch.mesh = pouch_mesh
	pouch.material_override = leather
	pouch.transform = Transform3D(Basis.from_scale(Vector3(1.0, 0.55, 0.85)), ring_center)
	_sling.add_child(pouch)
	var pebble: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.034
	sphere.height = 0.068
	sphere.radial_segments = 8
	sphere.rings = 5
	pebble.mesh = sphere
	pebble.material_override = stone
	pebble.position = ring_center + Vector3(0.0, 0.02, 0.045)
	_sling.add_child(pebble)
	_build_hand(_sling, grip, true)


func _build_club() -> void:
	_club = Node3D.new()
	_club.name = "Club"
	add_child(_club)
	var wood: StandardMaterial3D = _material(Color(0.34, 0.22, 0.12, 1.0), 0.95)
	var head_material: StandardMaterial3D = _material(Color(0.44, 0.42, 0.38, 1.0), 1.0)
	var handle: MeshInstance3D = MeshInstance3D.new()
	var cylinder: CylinderMesh = CylinderMesh.new()
	cylinder.top_radius = 0.035
	cylinder.bottom_radius = 0.045
	cylinder.height = 0.62
	cylinder.radial_segments = 8
	handle.mesh = cylinder
	handle.material_override = wood
	handle.position = Vector3(0.0, -0.05, 0.0)
	_club.add_child(handle)
	var head: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.09
	sphere.height = 0.16
	sphere.radial_segments = 8
	sphere.rings = 5
	head.mesh = sphere
	head.material_override = head_material
	head.position = Vector3(0.0, 0.27, 0.0)
	_club.add_child(head)
	_build_hand(_club, Vector3(0.0, 0.08, 0.0))
	_club.visible = false


func _build_shield() -> void:
	_shield = Node3D.new()
	_shield.name = "Shield"
	add_child(_shield)
	var leather: StandardMaterial3D = _material(Color(0.38, 0.26, 0.16, 1.0), 0.9)
	var rim: StandardMaterial3D = _material(Color(0.48, 0.42, 0.32, 1.0), 0.8)
	var face: MeshInstance3D = MeshInstance3D.new()
	var disc: CylinderMesh = CylinderMesh.new()
	disc.top_radius = 0.26
	disc.bottom_radius = 0.26
	disc.height = 0.05
	disc.radial_segments = 16
	face.mesh = disc
	face.material_override = leather
	face.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	_shield.add_child(face)
	var boss: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.075
	sphere.height = 0.12
	sphere.radial_segments = 10
	sphere.rings = 5
	boss.mesh = sphere
	boss.material_override = rim
	boss.position = Vector3(0.0, 0.0, -0.04)
	_shield.add_child(boss)
	_shield.position = Vector3(-0.18, -0.02, 0.02)
	_shield.scale = Vector3.ONE * 0.72
	_shield.visible = false


## Ejes de la mano de agarre. X: mango del arma; Z: antebrazo hacia abajo y
## hacia la cámara; Y: palma y curvatura de los dedos.
func _hand_axes(horizontal_grip: bool = false) -> Array:
	var hand_z: Vector3 = Vector3(0.22, -0.94, 0.26).normalized()
	var hand_x: Vector3 = Vector3(1.0, 0.0, 0.0) if horizontal_grip else Vector3(0.0, 1.0, 0.0)
	var hand_y: Vector3 = hand_z.cross(hand_x).normalized()
	return [hand_x, hand_y, hand_z]


## Mano de agarre del maniquí. El origen del nodo es la muñeca y [param at] es
## el punto del mango; el mango cae dentro de los dedos cerrados, en la cara
## delantera de la palma. La escala local 1.0 hereda el 0.6 del arma.
func _build_hand(parent: Node3D, at: Vector3, horizontal_grip: bool = false) -> void:
	var hand: MannequinHand = MannequinHand.new()
	hand.name = "GripHand"
	hand.grip = true
	var axes: Array = _hand_axes(horizontal_grip)
	var hand_x: Vector3 = axes[0]
	var hand_y: Vector3 = axes[1]
	var hand_z: Vector3 = axes[2]
	# El mango tiene radio 0.04: la palma se separa lo justo para que el
	# cilindro toque su cara delantera y los dedos lo envuelvan.
	var origin: Vector3 = at + hand_y * 0.056 + hand_z * 0.110
	hand.transform = Transform3D(Basis(hand_x, hand_y, hand_z), origin)
	parent.add_child(hand)


func _material(color: Color, roughness: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material
