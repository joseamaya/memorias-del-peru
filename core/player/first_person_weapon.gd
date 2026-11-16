class_name FirstPersonWeapon
extends Node3D
## Arma en primera persona: honda, porra y escudo.
##
## Es una malla de bloqueo, sin texturas finales. Vive bajo la cámara y cambia
## con [method set_weapon]. La campaña decide cuándo se muestra; el HUD no la
## conoce.

const REST_POSITION: Vector3 = Vector3(0.40, -0.40, -0.62)
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


## Gesto de ataque.
func play_attack() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	var forward: Vector3 = REST_POSITION + Vector3(-0.08, -0.04, -0.18)
	_tween.tween_property(self, "position", forward, ATTACK_SECONDS) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(self, "rotation_degrees",
		REST_ROTATION + Vector3(-28.0, 0.0, -18.0), ATTACK_SECONDS) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "position", REST_POSITION, RETURN_SECONDS) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.parallel().tween_property(self, "rotation_degrees", REST_ROTATION, RETURN_SECONDS) \
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
	var cord: MeshInstance3D = MeshInstance3D.new()
	var torus: TorusMesh = TorusMesh.new()
	torus.inner_radius = 0.08
	torus.outer_radius = 0.11
	torus.rings = 12
	torus.ring_segments = 8
	cord.mesh = torus
	cord.material_override = leather
	cord.rotation_degrees = Vector3(82.0, 0.0, 58.0)
	_sling.add_child(cord)
	var pebble: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.04
	sphere.height = 0.08
	sphere.radial_segments = 8
	sphere.rings = 5
	pebble.mesh = sphere
	pebble.material_override = stone
	pebble.position = Vector3(0.0, 0.06, 0.02)
	_sling.add_child(pebble)


func _build_club() -> void:
	_club = Node3D.new()
	_club.name = "Club"
	add_child(_club)
	var wood: StandardMaterial3D = _material(Color(0.34, 0.22, 0.12, 1.0), 0.95)
	var head_material: StandardMaterial3D = _material(Color(0.28, 0.18, 0.10, 1.0), 1.0)
	var handle: MeshInstance3D = MeshInstance3D.new()
	var cylinder: CylinderMesh = CylinderMesh.new()
	cylinder.top_radius = 0.035
	cylinder.bottom_radius = 0.045
	cylinder.height = 0.62
	cylinder.radial_segments = 8
	handle.mesh = cylinder
	handle.material_override = wood
	handle.position = Vector3(0.0, -0.05, 0.0)
	handle.rotation_degrees = Vector3(8.0, 0.0, -14.0)
	_club.add_child(handle)
	var head: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.09
	sphere.height = 0.16
	sphere.radial_segments = 8
	sphere.rings = 5
	head.mesh = sphere
	head.material_override = head_material
	head.position = Vector3(0.08, 0.27, 0.0)
	_club.add_child(head)
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


func _material(color: Color, roughness: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material
