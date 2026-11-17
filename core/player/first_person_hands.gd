class_name FirstPersonHands
extends Node3D
## Mano y antebrazo en primera persona para las interacciones.
##
## Es una malla propia, sombreada y articulada visualmente: antebrazo, muñeca,
## palma, cuatro dedos de tres falanges y pulgar. Aparece durante la acción,
## entra hacia el centro de la pantalla y se retira. El interactuable elige la
## acción con `hand_action`; «Hablar» la desactiva. No tiene colisión ni
## participa en el raycast.

const REST_POSITION: Vector3 = Vector3(0.34, -0.36, -0.56)
const REST_ROTATION: Vector3 = Vector3(66.0, -14.0, 0.0)
const HAND_SCALE: float = 0.78
const REACH_SECONDS: float = 0.22
const HOLD_SECONDS: float = 0.18
const RETURN_SECONDS: float = 0.32

## X, separación, largo y radio de cada dedo. El meñique es el más corto.
const FINGER_X: Array[float] = [-0.033, -0.011, 0.011, 0.033]
const FINGER_YAW: Array[float] = [-4.0, -1.0, 1.0, 4.0]
const FINGER_LENGTH: Array[float] = [0.082, 0.096, 0.090, 0.074]
const FINGER_RADIUS: Array[float] = [0.0115, 0.0120, 0.0115, 0.0105]

var _player: PlayerFPS = null
var _tween: Tween = null
var _skin: StandardMaterial3D = null
var _sleeve: StandardMaterial3D = null
var _cuff: StandardMaterial3D = null


func _ready() -> void:
	_build_materials()
	_build_hand()
	scale = Vector3.ONE * HAND_SCALE
	visible = false
	_player = _find_player()
	if _player != null:
		_player.interacted.connect(_on_interacted)


## Indica si la mano está en cuadro (para las pruebas).
func is_showing_hand() -> bool:
	return visible


## Reproduce la acción [param action]; `none` no hace nada.
func play(action: StringName) -> void:
	if action == &"none":
		return
	var target: Array = _action_target(action)
	if _tween != null and _tween.is_valid():
		_tween.kill()
	visible = true
	position = REST_POSITION
	rotation_degrees = REST_ROTATION
	_tween = create_tween()
	_tween.tween_property(self, "position", target[0], REACH_SECONDS) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(self, "rotation_degrees", target[1], REACH_SECONDS) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_interval(HOLD_SECONDS)
	_tween.tween_property(self, "position", REST_POSITION, RETURN_SECONDS) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.parallel().tween_property(self, "rotation_degrees", REST_ROTATION, RETURN_SECONDS) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.tween_callback(_hide_hand)


func _hide_hand() -> void:
	visible = false


func _on_interacted(interactable: Interactable) -> void:
	if interactable == null:
		return
	play(interactable.hand_action)


func _find_player() -> PlayerFPS:
	var node: Node = get_parent()
	while node != null and not (node is PlayerFPS):
		node = node.get_parent()
	return node as PlayerFPS


## Posición y giro de destino para cada acción. La mano no intenta coger el
## objeto del mundo: entra hacia el centro y acompaña el gesto.
func _action_target(action: StringName) -> Array:
	match action:
		&"drink":
			return [Vector3(0.16, -0.24, -0.60), Vector3(64.0, -8.0, 8.0)]
		&"offer":
			return [Vector3(0.18, -0.32, -0.64), Vector3(66.0, -10.0, 4.0)]
		&"blow":
			return [Vector3(0.20, -0.26, -0.60), Vector3(64.0, -12.0, 6.0)]
		&"attack":
			return [Vector3(0.12, -0.44, -0.74), Vector3(74.0, -4.0, -8.0)]
		_:
			return [Vector3(0.18, -0.28, -0.64), Vector3(66.0, -10.0, 4.0)]


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


func _material(color: Color, roughness: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic_specular = 0.22
	return material


func _build_hand() -> void:
	# Antebrazo de piel y manga de unku. La muñeca queda descubierta.
	var wrist_mesh: CapsuleMesh = CapsuleMesh.new()
	wrist_mesh.radius = 0.038
	wrist_mesh.height = 0.17
	wrist_mesh.radial_segments = 16
	wrist_mesh.rings = 8
	_add_mesh(wrist_mesh, _skin, Vector3(0.0, 0.0, 0.04), Vector3(90.0, 0.0, 0.0))

	var sleeve_mesh: CylinderMesh = CylinderMesh.new()
	sleeve_mesh.top_radius = 0.060
	sleeve_mesh.bottom_radius = 0.052
	sleeve_mesh.height = 0.20
	sleeve_mesh.radial_segments = 18
	_add_mesh(sleeve_mesh, _sleeve, Vector3(0.0, 0.0, 0.18), Vector3(90.0, 0.0, 0.0))

	var cuff_mesh: CylinderMesh = CylinderMesh.new()
	cuff_mesh.top_radius = 0.061
	cuff_mesh.bottom_radius = 0.061
	cuff_mesh.height = 0.035
	cuff_mesh.radial_segments = 18
	_add_mesh(cuff_mesh, _cuff, Vector3(0.0, 0.0, 0.075), Vector3(90.0, 0.0, 0.0))

	var band_mesh: CylinderMesh = CylinderMesh.new()
	band_mesh.top_radius = 0.061
	band_mesh.bottom_radius = 0.061
	band_mesh.height = 0.022
	band_mesh.radial_segments = 18
	_add_mesh(band_mesh, _cuff, Vector3(0.0, 0.0, 0.155), Vector3(90.0, 0.0, 0.0))

	# Palma redondeada y talón de la mano.
	var palm_mesh: SphereMesh = SphereMesh.new()
	palm_mesh.radius = 0.060
	palm_mesh.height = 0.120
	palm_mesh.radial_segments = 24
	palm_mesh.rings = 12
	var palm: MeshInstance3D = _add_mesh(palm_mesh, _skin, Vector3(0.0, -0.002, -0.052), Vector3.ZERO)
	palm.scale = Vector3(0.92, 0.42, 1.05)

	var heel_mesh: SphereMesh = SphereMesh.new()
	heel_mesh.radius = 0.044
	heel_mesh.height = 0.088
	heel_mesh.radial_segments = 18
	heel_mesh.rings = 10
	var heel: MeshInstance3D = _add_mesh(heel_mesh, _skin, Vector3(0.0, -0.002, 0.010), Vector3.ZERO)
	heel.scale = Vector3(1.0, 0.46, 0.72)

	# Cuatro dedos de tres falanges, con nudillos y uñas.
	for index: int in range(FINGER_X.size()):
		var x: float = FINGER_X[index]
		var yaw: float = FINGER_YAW[index]
		var length: float = FINGER_LENGTH[index]
		var radius: float = FINGER_RADIUS[index]
		var segment: float = length / 3.0
		for joint: int in range(3):
			var capsule: CapsuleMesh = CapsuleMesh.new()
			capsule.radius = radius * (1.0 - 0.12 * float(joint))
			capsule.height = segment * 1.45
			capsule.radial_segments = 12
			capsule.rings = 6
			_add_mesh(
				capsule, _skin,
				Vector3(x, -0.006 - 0.007 * float(joint), -0.100 - segment * 0.92 * float(joint)),
				Vector3(-3.0 - 8.0 * float(joint), yaw, 0.0),
			)
		var knuckle_mesh: SphereMesh = SphereMesh.new()
		knuckle_mesh.radius = radius * 1.08
		knuckle_mesh.height = radius * 2.16
		knuckle_mesh.radial_segments = 10
		knuckle_mesh.rings = 6
		_add_mesh(knuckle_mesh, _skin, Vector3(x, -0.010, -0.105), Vector3.ZERO)
	# Pulgar: dos falanges que salen del lado interior de la palma.
	var thumb_base: CapsuleMesh = CapsuleMesh.new()
	thumb_base.radius = 0.016
	thumb_base.height = 0.055
	thumb_base.radial_segments = 14
	thumb_base.rings = 8
	_add_mesh(thumb_base, _skin, Vector3(0.056, -0.004, -0.055), Vector3(78.0, 0.0, -42.0))
	var thumb_tip: CapsuleMesh = CapsuleMesh.new()
	thumb_tip.radius = 0.013
	thumb_tip.height = 0.045
	thumb_tip.radial_segments = 12
	thumb_tip.rings = 6
	_add_mesh(thumb_tip, _skin, Vector3(0.074, -0.004, -0.085), Vector3(82.0, 0.0, -30.0))

func _add_mesh(mesh: Mesh, material: Material, at: Vector3, rotation_euler: Vector3) -> MeshInstance3D:
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = at
	instance.rotation_degrees = rotation_euler
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	add_child(instance)
	return instance
