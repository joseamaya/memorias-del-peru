class_name CharacterOutfit
extends Node
## Viste un maniquí UAL1 con un [CharacterLook].
##
## El cuerpo tiene dos superficies (piel y juntas) y las piezas son primitivas
## colgadas de huesos con [BoneAttachment3D]. No hay mallas skinned de ropa ni
## texturas: el atuendo es geometría simple y color. La máscara de huesos usa los
## nombres reales del UAL1 de este proyecto: spine_02, pelvis, Head, hand_r…
##
## Las piezas de un mismo hueso se fusionan en una sola malla con colores de
## vértice: el atuendo pasa de una decena de draw calls a tres por personaje
## (torso, cadera y cabeza).

const SKELETON_TYPE: String = "Skeleton3D"
const BODY: String = "Mannequin"
const PREFIX: String = "Outfit_"
const PARTS_META: StringName = &"outfit_parts"

@export var look: CharacterLook
@export var model: Node3D


func _ready() -> void:
	if look != null and model != null:
		apply(model, look)


## Viste [param model] con [param look]; si se llama otra vez, sustituye el
## atuendo anterior.
static func apply(target_model: Node3D, target_look: CharacterLook) -> void:
	var skeleton: Skeleton3D = find_skeleton(target_model)
	if skeleton == null:
		push_warning("CharacterOutfit: no hay esqueleto en %s." % target_model.name)
		return
	var body: MeshInstance3D = skeleton.find_child(BODY, false, false) as MeshInstance3D
	if body != null:
		body.set_surface_override_material(0, _material(target_look.skin))
		if body.mesh != null and body.mesh.get_surface_count() > 1:
			body.set_surface_override_material(1, _material(target_look.joints))
	for child: Node in skeleton.get_children():
		if child.name.begins_with(PREFIX):
			skeleton.remove_child(child)
			child.queue_free()
	var groups: Dictionary[StringName, Array] = {}
	for part: LookPart in target_look.parts:
		if part == null:
			push_warning("CharacterOutfit: pieza de atuendo nula.")
			continue
		if skeleton.find_bone(part.bone) < 0:
			push_warning("CharacterOutfit: hueso desconocido %s." % part.bone)
			continue
		if not groups.has(part.bone):
			groups[part.bone] = []
		(groups[part.bone] as Array).append(part)
	var outfit_material: StandardMaterial3D = _vertex_material()
	for bone: StringName in groups:
		var socket: BoneAttachment3D = BoneAttachment3D.new()
		socket.name = PREFIX + String(bone)
		socket.bone_name = bone
		skeleton.add_child(socket)
		var piece: MeshInstance3D = _merged_piece(groups[bone] as Array, outfit_material, bone)
		if piece != null:
			socket.add_child(piece)
	target_model.set_meta(PARTS_META, target_look.parts.size())


## Esqueleto del maniquí, buscando por tipo para no depender del nombre del nodo.
static func find_skeleton(target_model: Node) -> Skeleton3D:
	if target_model == null:
		return null
	var skeletons: Array[Node] = target_model.find_children("*", SKELETON_TYPE, true, false)
	if skeletons.is_empty():
		return null
	return skeletons[0] as Skeleton3D


## Piezas de atuendo que definió el último look aplicado. Lo usan las pruebas.
static func piece_count(target_model: Node) -> int:
	if target_model != null and target_model.has_meta(PARTS_META):
		var stored: Variant = target_model.get_meta(PARTS_META)
		if stored is int:
			return stored
		return 0
	var total: int = 0
	var skeletons: Array[Node] = target_model.find_children("*", SKELETON_TYPE, true, false)
	for node: Node in skeletons:
		for child: Node in node.get_children():
			if child.name.begins_with(PREFIX):
				total += child.get_child_count()
	return total


## Funde todas las piezas del hueso en una malla con el color de cada vértice.
static func _merged_piece(parts: Array, material: StandardMaterial3D,
		bone: StringName) -> MeshInstance3D:
	var vertices: PackedVector3Array = PackedVector3Array()
	var normals: PackedVector3Array = PackedVector3Array()
	var colors: PackedColorArray = PackedColorArray()
	var indices: PackedInt32Array = PackedInt32Array()
	for part: LookPart in parts:
		var part_mesh: PrimitiveMesh = mesh_for(part) as PrimitiveMesh
		if part_mesh == null:
			continue
		var part_arrays: Array = part_mesh.get_mesh_arrays()
		if part_arrays.size() <= Mesh.ARRAY_VERTEX:
			continue
		var part_vertices: PackedVector3Array = part_arrays[Mesh.ARRAY_VERTEX]
		var part_normals: PackedVector3Array = part_arrays[Mesh.ARRAY_NORMAL]
		var part_indices: PackedInt32Array = part_arrays[Mesh.ARRAY_INDEX]
		var part_basis: Basis = Basis.from_euler(part.rotation_deg * (PI / 180.0))
		var offset: int = vertices.size()
		for index: int in range(part_vertices.size()):
			vertices.append(Transform3D(part_basis, part.offset) * part_vertices[index])
			normals.append((part_basis * part_normals[index]).normalized())
			colors.append(part.color)
		if part_indices.is_empty():
			for index: int in range(part_vertices.size()):
				indices.append(offset + index)
		else:
			for index: int in part_indices:
				indices.append(offset + index)
	if vertices.is_empty():
		return null
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_INDEX] = indices
	var merged: ArrayMesh = ArrayMesh.new()
	merged.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	merged.surface_set_material(0, material)
	var piece: MeshInstance3D = MeshInstance3D.new()
	piece.name = PREFIX + String(bone)
	piece.mesh = merged
	# La cabeza (cinta, pelo, paño) no proyecta sombra: son piezas pequeñas.
	if bone == &"Head":
		piece.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return piece


## Malla de una pieza. Es pura para poder probarla sin cargar un modelo.
static func mesh_for(part: LookPart) -> Mesh:
	match part.shape:
		LookPart.Shape.CYLINDER, LookPart.Shape.DISC:
			var cylinder: CylinderMesh = CylinderMesh.new()
			cylinder.top_radius = part.size.x
			cylinder.bottom_radius = part.size.x
			cylinder.height = part.size.y
			cylinder.radial_segments = 12 if part.shape == LookPart.Shape.DISC else 10
			cylinder.rings = 1
			return cylinder
		LookPart.Shape.RING:
			var ring: TorusMesh = TorusMesh.new()
			ring.inner_radius = part.size.x
			ring.outer_radius = part.size.y
			ring.rings = 16
			ring.ring_segments = 6
			return ring
	var box: BoxMesh = BoxMesh.new()
	box.size = part.size
	return box


static func _vertex_material() -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color.WHITE
	material.vertex_color_use_as_albedo = true
	material.vertex_color_is_srgb = true
	material.roughness = 0.88
	return material


static func _material(color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.88
	return material
