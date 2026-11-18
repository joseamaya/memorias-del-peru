class_name CharacterOutfit
extends Node
## Viste un maniquí UAL1 con un [CharacterLook].
##
## El cuerpo tiene dos superficies (piel y juntas) y las piezas son primitivas
## colgadas de huesos con [BoneAttachment3D]. No hay mallas skinned de ropa ni
## texturas: el atuendo es geometría simple y color. La máscara de huesos usa los
## nombres reales del UAL1 de este proyecto: spine_02, pelvis, Head, hand_r…

const SKELETON_TYPE: String = "Skeleton3D"
const BODY: String = "Mannequin"
const PREFIX: String = "Outfit_"

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
	var sockets: Dictionary[StringName, BoneAttachment3D] = {}
	for part: LookPart in target_look.parts:
		if part == null or skeleton.find_bone(part.bone) < 0:
			push_warning("CharacterOutfit: hueso desconocido %s." % part.bone)
			continue
		if not sockets.has(part.bone):
			var socket: BoneAttachment3D = BoneAttachment3D.new()
			socket.name = PREFIX + String(part.bone)
			socket.bone_name = part.bone
			skeleton.add_child(socket)
			sockets[part.bone] = socket
		var piece: MeshInstance3D = MeshInstance3D.new()
		piece.name = part.name if not part.name.is_empty() else "Piece"
		piece.mesh = mesh_for(part)
		piece.material_override = _material(part.color)
		piece.position = part.offset
		piece.rotation_degrees = part.rotation_deg
		(sockets[part.bone] as BoneAttachment3D).add_child(piece)


## Esqueleto del maniquí, buscando por tipo para no depender del nombre del nodo.
static func find_skeleton(target_model: Node) -> Skeleton3D:
	if target_model == null:
		return null
	var skeletons: Array[Node] = target_model.find_children("*", SKELETON_TYPE, true, false)
	if skeletons.is_empty():
		return null
	return skeletons[0] as Skeleton3D


## Piezas de atuendo colgadas del maniquí. Lo usan las pruebas.
static func piece_count(target_model: Node) -> int:
	var total: int = 0
	var skeletons: Array[Node] = target_model.find_children("*", SKELETON_TYPE, true, false)
	for node: Node in skeletons:
		for child: Node in node.get_children():
			if child.name.begins_with(PREFIX):
				total += child.get_child_count()
	return total


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


static func _material(color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.88
	return material
