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
## La mano del arma se construye a tamaño real y compensa la escala del arma.
const HAND_SCALE: float = 1.0 / WEAPON_SCALE

var _sling: Node3D = null
var _club: Node3D = null
var _shield: Node3D = null
var _skin: StandardMaterial3D = null
var _sleeve: StandardMaterial3D = null
var _cuff: StandardMaterial3D = null
var _kind: CombatWeapon.Kind = CombatWeapon.Kind.SLING
var _tween: Tween = null


func _ready() -> void:
	_build_materials()
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
	var cord: MeshInstance3D = MeshInstance3D.new()
	var torus: TorusMesh = TorusMesh.new()
	torus.inner_radius = 0.095
	torus.outer_radius = 0.105
	torus.rings = 18
	torus.ring_segments = 5
	cord.mesh = torus
	cord.material_override = leather
	cord.rotation_degrees = Vector3(82.0, 0.0, 58.0)
	_sling.add_child(cord)
	var pouch: MeshInstance3D = MeshInstance3D.new()
	var pouch_mesh: SphereMesh = SphereMesh.new()
	pouch_mesh.radius = 0.045
	pouch_mesh.height = 0.09
	pouch_mesh.radial_segments = 10
	pouch_mesh.rings = 5
	pouch.mesh = pouch_mesh
	pouch.material_override = leather
	pouch.scale = Vector3(1.0, 0.55, 0.85)
	pouch.position = Vector3(0.0, 0.025, 0.02)
	_sling.add_child(pouch)
	var pebble: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.034
	sphere.height = 0.068
	sphere.radial_segments = 8
	sphere.rings = 5
	pebble.mesh = sphere
	pebble.material_override = stone
	pebble.position = Vector3(0.0, 0.055, 0.02)
	_sling.add_child(pebble)
	_build_hand(_sling, Vector3(0.0, 0.10, 0.0), 1.0)


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
	_build_hand(_club, Vector3(0.0, -0.04, 0.0), -1.0)
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


func _build_materials() -> void:
	_skin = _material(Color(0.63, 0.46, 0.35, 1.0), 0.72)
	_skin.rim_enabled = true
	_skin.rim = 0.12
	_skin.rim_tint = 0.42
	_skin.subsurf_scatter_enabled = true
	_skin.subsurf_scatter_strength = 0.10
	_skin.subsurf_scatter_skin_mode = true
	_sleeve = _material(Color(0.30, 0.20, 0.13, 1.0), 0.92)
	_cuff = _material(Color(0.52, 0.14, 0.10, 1.0), 0.85)


## Mano cerrada alrededor del agarre. Sin ella, la honda y la porra se leían
## como objetos flotando en la esquina de la cámara. La manga sale del puño
## hacia el borde de la pantalla.
func _build_hand(parent: Node3D, grip: Vector3, sleeve_direction: float) -> void:
	var hand: Node3D = Node3D.new()
	hand.name = "HoldingHand"
	hand.position = grip
	hand.scale = Vector3.ONE * HAND_SCALE
	parent.add_child(hand)
	var fist_instance: MeshInstance3D = MeshInstance3D.new()
	var fist: CapsuleMesh = CapsuleMesh.new()
	fist.radius = 0.042
	fist.height = 0.105
	fist.radial_segments = 12
	fist.rings = 5
	fist_instance.mesh = fist
	fist_instance.material_override = _skin
	_prepare_hand_mesh(fist_instance)
	hand.add_child(fist_instance)
	# Dorso de la mano y nudillos, hacia la cámara. Sin esto el puño se lee
	# como una bola de piel y no como una mano que agarra.
	var back_instance: MeshInstance3D = MeshInstance3D.new()
	var back: BoxMesh = BoxMesh.new()
	back.size = Vector3(0.070, 0.082, 0.014)
	back_instance.mesh = back
	back_instance.material_override = _skin
	back_instance.position = Vector3(0.0, 0.0, 0.040)
	_prepare_hand_mesh(back_instance)
	hand.add_child(back_instance)
	for index: int in range(4):
		var knuckle: MeshInstance3D = MeshInstance3D.new()
		var sphere: SphereMesh = SphereMesh.new()
		sphere.radius = 0.013
		sphere.height = 0.026
		sphere.radial_segments = 8
		sphere.rings = 4
		knuckle.mesh = sphere
		knuckle.material_override = _skin
		knuckle.position = Vector3(-0.026, -0.030 + 0.020 * float(index), 0.050)
		_prepare_hand_mesh(knuckle)
		hand.add_child(knuckle)
	var thumb: MeshInstance3D = MeshInstance3D.new()
	var thumb_mesh: CapsuleMesh = CapsuleMesh.new()
	thumb_mesh.radius = 0.013
	thumb_mesh.height = 0.052
	thumb_mesh.radial_segments = 8
	thumb_mesh.rings = 3
	thumb.mesh = thumb_mesh
	thumb.material_override = _skin
	thumb.position = Vector3(0.040, 0.036, 0.046)
	thumb.rotation_degrees = Vector3(0.0, 0.0, -58.0)
	_prepare_hand_mesh(thumb)
	hand.add_child(thumb)
	var sleeve_instance: MeshInstance3D = MeshInstance3D.new()
	var sleeve: CylinderMesh = CylinderMesh.new()
	sleeve.top_radius = 0.032
	sleeve.bottom_radius = 0.038
	sleeve.height = 0.12
	sleeve.radial_segments = 10
	sleeve_instance.mesh = sleeve
	sleeve_instance.material_override = _sleeve
	sleeve_instance.position = Vector3(0.0, sleeve_direction * 0.090, 0.0)
	_prepare_hand_mesh(sleeve_instance)
	hand.add_child(sleeve_instance)
	var cuff_instance: MeshInstance3D = MeshInstance3D.new()
	var cuff: CylinderMesh = CylinderMesh.new()
	cuff.top_radius = 0.039
	cuff.bottom_radius = 0.039
	cuff.height = 0.026
	cuff.radial_segments = 10
	cuff_instance.mesh = cuff
	cuff_instance.material_override = _cuff
	cuff_instance.position = Vector3(0.0, sleeve_direction * 0.034, 0.0)
	_prepare_hand_mesh(cuff_instance)
	hand.add_child(cuff_instance)


func _prepare_hand_mesh(instance: MeshInstance3D) -> void:
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.gi_mode = GeometryInstance3D.GI_MODE_DISABLED


func _material(color: Color, roughness: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material
