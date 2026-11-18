class_name MannequinHand
extends Node3D
## Mano de maniquí en primera persona: antebrazo UAL1 y mano articulada simple.
##
## El UAL1 trae una mano con los dedos fusionados en la malla; posar sus huesos
## no los separa. Para que la mano se lea en primera persona, conservamos el
## antebrazo de Quaternius y montamos palma, cuatro dedos y pulgar con piezas
## primitivas y los dos colores del maniquí (piel y juntas). `grip` elige en la
## construcción entre mano abierta y puño; la pose se hornea al fusionar.

const FOREARM_PATH: String = "res://shared_assets/characters/mannequin/mannequin_forearm.glb"
## El antebrazo de origen mide 0.322 hacia el codo; se alarga para salir de
## cuadro en primera persona.
const FOREARM_LENGTH: float = 1.80
const FOREARM_WIDTH: float = 0.86

const FINGER_X: Array[float] = [-0.033, -0.011, 0.011, 0.033]
const FINGER_YAW: Array[float] = [-4.0, -1.0, 1.0, 4.0]
const FINGER_LENGTH: Array[float] = [0.078, 0.092, 0.086, 0.070]
const FINGER_RADIUS: Array[float] = [0.0085, 0.0090, 0.0088, 0.0080]
const SEGMENTS: int = 3
## Ángulo de cierre de cada falange en la pose de agarre.
const GRIP_ANGLE: float = -46.0

@export var grip: bool = false
@export var skin: Color = Color(0.55, 0.36, 0.24)
@export var joints: Color = Color(0.16, 0.10, 0.08)
@export var show_forearm: bool = true

var _skin: StandardMaterial3D = null
var _joints: StandardMaterial3D = null
var _forearm: Node3D = null
var _finger_joints: Array[Node3D] = []


func _ready() -> void:
	_build_materials()
	if show_forearm:
		_add_forearm()
	_add_wrist()
	_add_palm()
	for index: int in range(FINGER_X.size()):
		_add_finger(index)
	_add_thumb()
	_apply_pose()
	_merge()


func is_gripping() -> bool:
	return grip


## Número de mallas de la mano, para las pruebas.
func piece_count() -> int:
	var meshes: Array[Node] = find_children("*", "MeshInstance3D", true, false)
	return meshes.size()


## Fusiona todas las piezas en dos mallas (piel y juntas): la mano pasa de ~30
## draw calls a 2 sin cambiar de aspecto. La pose se hornea antes de fusionar.
func _merge() -> void:
	var skin_tool: SurfaceTool = SurfaceTool.new()
	skin_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var joint_tool: SurfaceTool = SurfaceTool.new()
	joint_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var inverse: Transform3D = global_transform.affine_inverse()
	var meshes: Array[Node] = find_children("*", "MeshInstance3D", true, false)
	for node: Node in meshes:
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		var relative: Transform3D = inverse * mesh_instance.global_transform
		if mesh_instance.material_override == _joints:
			joint_tool.append_from(mesh_instance.mesh, 0, relative)
		elif mesh_instance.material_override == _skin:
			skin_tool.append_from(mesh_instance.mesh, 0, relative)
		else:
			for surface: int in range(mesh_instance.mesh.get_surface_count()):
				var tool: SurfaceTool = joint_tool if surface > 0 else skin_tool
				tool.append_from(mesh_instance.mesh, surface, relative)
	for child: Node in get_children():
		remove_child(child)
		child.free()
	var skin_mesh: ArrayMesh = skin_tool.commit()
	if skin_mesh != null and skin_mesh.get_surface_count() > 0:
		skin_mesh.surface_set_material(0, _skin)
		_add_merged(skin_mesh)
	var joint_mesh: ArrayMesh = joint_tool.commit()
	if joint_mesh != null and joint_mesh.get_surface_count() > 0:
		joint_mesh.surface_set_material(0, _joints)
		_add_merged(joint_mesh)
	_forearm = null
	_finger_joints.clear()


func _add_merged(mesh: Mesh) -> void:
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	add_child(instance)


func _build_materials() -> void:
	_skin = _material(skin)
	_joints = _material(joints)


func _add_forearm() -> void:
	var packed: PackedScene = load(FOREARM_PATH) as PackedScene
	if packed == null:
		return
	_forearm = packed.instantiate() as Node3D
	if _forearm == null:
		return
	# El antebrazo del UAL1 se extiende por +X: se alinea con el +Z de la mano,
	# se alarga sobre su propio eje para salir de cuadro y se afina un poco. La
	# muñeca queda en el origen y el tramo extra cae tras el borde de la pantalla.
	var forearm_transform: Basis = Basis(Vector3(0.0, 0.0, FOREARM_LENGTH),
		Vector3(FOREARM_WIDTH, 0.0, 0.0), Vector3(0.0, FOREARM_WIDTH, 0.0))
	_forearm.transform = Transform3D(forearm_transform, Vector3.ZERO)
	add_child(_forearm)
	var meshes: Array[Node] = _forearm.find_children("*", "MeshInstance3D", true, false)
	for node: Node in meshes:
		var mesh: MeshInstance3D = node as MeshInstance3D
		if mesh.mesh == null:
			continue
		mesh.set_surface_override_material(0, _skin)
		if mesh.mesh.get_surface_count() > 1:
			mesh.set_surface_override_material(1, _joints)
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mesh.gi_mode = GeometryInstance3D.GI_MODE_DISABLED


func _add_wrist() -> void:
	var joint: MeshInstance3D = _sphere(self, _joints, Vector3.ZERO, 0.036)
	joint.name = "Wrist"


func _add_palm() -> void:
	var palm: MeshInstance3D = _box(_skin, Vector3(0.0, 0.0, -0.052),
		Vector3(0.098, 0.032, 0.090))
	palm.name = "Palm"
	var heel: MeshInstance3D = _sphere(self, _skin, Vector3(0.0, 0.0, -0.005), 0.034)
	heel.scale = Vector3(1.0, 0.65, 1.0)
	heel.name = "Heel"


func _add_finger(index: int) -> void:
	var length: float = FINGER_LENGTH[index]
	var radius: float = FINGER_RADIUS[index]
	var segment: float = length / float(SEGMENTS)
	var pivot: Node3D = Node3D.new()
	pivot.name = "Finger%d" % index
	pivot.position = Vector3(FINGER_X[index], 0.0, -0.096)
	pivot.rotation_degrees = Vector3(-3.0, FINGER_YAW[index], 0.0)
	add_child(pivot)
	_finger_joints.append(pivot)
	_sphere(pivot, _joints, Vector3.ZERO, radius * 1.12)
	for part: int in range(SEGMENTS):
		_segment(pivot, segment, radius * (1.0 - 0.10 * float(part)))
		if part < SEGMENTS - 1:
			var next: Node3D = Node3D.new()
			next.name = "Joint%d_%d" % [index, part + 1]
			next.position = Vector3(0.0, 0.0, -segment)
			next.rotation_degrees = Vector3(-8.0, 0.0, 0.0)
			pivot.add_child(next)
			pivot = next
			_finger_joints.append(pivot)
			_sphere(pivot, _joints, Vector3.ZERO, radius * (1.02 - 0.08 * float(part)))


func _add_thumb() -> void:
	var pivot: Node3D = Node3D.new()
	pivot.name = "Thumb"
	pivot.position = Vector3(-0.052, -0.006, -0.058)
	pivot.rotation_degrees = Vector3(-8.0, 42.0, 18.0)
	add_child(pivot)
	_finger_joints.append(pivot)
	_sphere(pivot, _joints, Vector3.ZERO, 0.0115)
	_segment(pivot, 0.040, 0.0105)
	var next: Node3D = Node3D.new()
	next.name = "ThumbTip"
	next.position = Vector3(0.0, 0.0, -0.040)
	next.rotation_degrees = Vector3(-12.0, 0.0, 0.0)
	pivot.add_child(next)
	_finger_joints.append(next)
	_sphere(next, _joints, Vector3.ZERO, 0.0100)
	_segment(next, 0.032, 0.0092)


## Falange alineada con −Z, con su nudillo en el pivote.
func _segment(parent: Node3D, length: float, radius: float) -> void:
	var capsule: CapsuleMesh = CapsuleMesh.new()
	capsule.radius = radius
	capsule.height = length + radius * 1.4
	capsule.radial_segments = 10
	capsule.rings = 4
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = capsule
	instance.material_override = _skin
	instance.position = Vector3(0.0, 0.0, -length * 0.5)
	instance.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	parent.add_child(instance)


func _apply_pose() -> void:
	var curl: float = GRIP_ANGLE if grip else 0.0
	for joint: Node3D in _finger_joints:
		var base: float = -8.0 if joint.name.begins_with("Joint") else -3.0
		if joint.name == "Thumb":
			base = -18.0 if grip else -8.0
			joint.rotation_degrees.x = base
			joint.rotation_degrees.y = 12.0 if grip else 42.0
			joint.rotation_degrees.z = 30.0 if grip else 18.0
		elif joint.name == "ThumbTip":
			joint.rotation_degrees.x = -38.0 if grip else -12.0
		else:
			joint.rotation_degrees.x = base + curl


func _sphere(parent: Node3D, material: Material, at: Vector3,
		radius: float) -> MeshInstance3D:
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 10
	mesh.rings = 6
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = at
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	parent.add_child(instance)
	return instance


func _box(material: Material, at: Vector3, size: Vector3) -> MeshInstance3D:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = at
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	add_child(instance)
	return instance


func _material(color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	return material
