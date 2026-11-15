class_name FirstPersonHands
extends Node3D
## Mano y antebrazo en primera persona para las interacciones.
##
## Es una malla sencilla, propia y sin texturas: aparece durante la acción,
## entra hacia el centro de la pantalla y se retira. El interactuable elige la
## acción con `hand_action`; «Hablar» la desactiva. No tiene colisión ni
## participa en el raycast.

const REST_POSITION: Vector3 = Vector3(0.30, -0.38, -0.52)
const REST_ROTATION: Vector3 = Vector3(72.0, -12.0, 0.0)
const HAND_SCALE: float = 0.82
const REACH_SECONDS: float = 0.22
const HOLD_SECONDS: float = 0.18
const RETURN_SECONDS: float = 0.32

var _player: PlayerFPS = null
var _tween: Tween = null
var _skin: StandardMaterial3D = null
var _sleeve: StandardMaterial3D = null
var _cuff: StandardMaterial3D = null
var _nail: StandardMaterial3D = null


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
## objeto del mundo: entra hacia el centro y acompaña al gesto.
func _action_target(action: StringName) -> Array:
	match action:
		&"drink":
			return [Vector3(0.16, -0.24, -0.58), Vector3(70.0, -8.0, 6.0)]
		&"offer":
			return [Vector3(0.18, -0.32, -0.62), Vector3(72.0, -10.0, 2.0)]
		&"blow":
			return [Vector3(0.20, -0.26, -0.58), Vector3(70.0, -12.0, 4.0)]
		&"attack":
			return [Vector3(0.12, -0.44, -0.72), Vector3(78.0, -4.0, -8.0)]
		_:
			return [Vector3(0.18, -0.28, -0.62), Vector3(72.0, -10.0, 2.0)]


func _build_materials() -> void:
	_skin = StandardMaterial3D.new()
	_skin.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_skin.albedo_color = Color(0.60, 0.41, 0.30, 1.0)
	_sleeve = StandardMaterial3D.new()
	_sleeve.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_sleeve.albedo_color = Color(0.35, 0.24, 0.17, 1.0)
	_cuff = StandardMaterial3D.new()
	_cuff.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_cuff.albedo_color = Color(0.55, 0.16, 0.11, 1.0)
	_nail = StandardMaterial3D.new()
	_nail.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_nail.albedo_color = Color(0.72, 0.55, 0.44, 1.0)


func _build_hand() -> void:
	var forearm: CapsuleMesh = CapsuleMesh.new()
	forearm.radius = 0.050
	forearm.height = 0.32
	_add_mesh(forearm, _sleeve, Vector3(0.0, 0.0, 0.16), Vector3(90.0, 0.0, 0.0))
	var cuff: CylinderMesh = CylinderMesh.new()
	cuff.top_radius = 0.060
	cuff.bottom_radius = 0.060
	cuff.height = 0.045
	cuff.radial_segments = 12
	_add_mesh(cuff, _cuff, Vector3(0.0, 0.0, 0.045), Vector3(90.0, 0.0, 0.0))
	var palm: BoxMesh = BoxMesh.new()
	palm.size = Vector3(0.105, 0.034, 0.10)
	_add_mesh(palm, _skin, Vector3(0.0, -0.004, -0.055), Vector3.ZERO)
	var finger_x: Array[float] = [-0.039, -0.013, 0.013, 0.039]
	var finger_yaw: Array[float] = [-7.0, -2.0, 2.0, 7.0]
	for index: int in range(finger_x.size()):
		var finger: CapsuleMesh = CapsuleMesh.new()
		finger.radius = 0.012
		finger.height = 0.085
		_add_mesh(finger, _skin, Vector3(finger_x[index], -0.008, -0.125),
			Vector3(90.0, finger_yaw[index], 0.0))
		var nail: BoxMesh = BoxMesh.new()
		nail.size = Vector3(0.015, 0.004, 0.018)
		_add_mesh(nail, _nail, Vector3(finger_x[index], -0.003, -0.165),
			Vector3(0.0, finger_yaw[index], 0.0))
	var thumb: CapsuleMesh = CapsuleMesh.new()
	thumb.radius = 0.015
	thumb.height = 0.075
	_add_mesh(thumb, _skin, Vector3(0.060, -0.004, -0.055), Vector3(80.0, -38.0, 0.0))


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
