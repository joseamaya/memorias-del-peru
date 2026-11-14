class_name DressedMannequin
extends Node3D
## Ropa y rostro estilizados sobre el maniquí UAL1 (ADR-0042).
##
## Primera pasada: piezas rígidas ancladas a huesos con [BoneAttachment3D], sin
## skinning. La ropa cubre el cuerpo del maniquí y la cabeza estilizada sustituye
## la cara lisa. Los colores y las piezas siguen las fichas del acto I; el
## textil fino llega en una pasada posterior.

const SKIRT_COLOR: Color = Color(0.45, 0.16, 0.12, 1.0)
const TUNIC_COLOR: Color = Color(0.72, 0.66, 0.55, 1.0)
const LLICLLA_COLOR: Color = Color(0.55, 0.18, 0.14, 1.0)
const STRIPE_COLOR: Color = Color(0.82, 0.78, 0.68, 1.0)
const CHUSPA_COLOR: Color = Color(0.36, 0.26, 0.18, 1.0)
const BELT_COLOR: Color = Color(0.25, 0.18, 0.12, 1.0)
const SKIN_COLOR: Color = Color(0.72, 0.52, 0.40, 1.0)
const HAIR_COLOR: Color = Color(0.12, 0.08, 0.06, 1.0)
const EYE_COLOR: Color = Color(0.05, 0.03, 0.02, 1.0)
const MOUTH_COLOR: Color = Color(0.35, 0.12, 0.10, 1.0)

var _skeleton: Skeleton3D = null
var _skin: StandardMaterial3D = null
var _hair: StandardMaterial3D = null
var _eye: StandardMaterial3D = null
var _sclera: StandardMaterial3D = null
var _mouth: StandardMaterial3D = null


func _ready() -> void:
	_skeleton = _find_skeleton()
	if _skeleton == null:
		return
	_skin = _plain_material(SKIN_COLOR, 0.9)
	_hair = _plain_material(HAIR_COLOR, 1.0)
	_eye = _plain_material(EYE_COLOR, 0.3)
	_sclera = _plain_material(Color(0.9, 0.88, 0.82, 1.0), 0.4)
	_mouth = _plain_material(MOUTH_COLOR, 0.8)
	_build_weaver()


## Indica si la capa encontró el esqueleto del maniquí.
func is_built() -> bool:
	return _skeleton != null


## Huesos usados por la ropa, para las pruebas.
func attached_bones() -> Array[StringName]:
	var bones: Array[StringName] = []
	if _skeleton == null:
		return bones
	for child: Node in _skeleton.get_children():
		if child is BoneAttachment3D:
			bones.append((child as BoneAttachment3D).bone_name)
	return bones


func _find_skeleton() -> Skeleton3D:
	var parent: Node = get_parent()
	if parent == null:
		return null
	var found: Array[Node] = parent.find_children("*", "Skeleton3D", true, false)
	if found.is_empty():
		return null
	return found[0] as Skeleton3D


func _build_weaver() -> void:
	# Falda y cinturón sobre la cadera.
	var pelvis: BoneAttachment3D = _attach("pelvis", "OutfitPelvis")
	var skirt: CylinderMesh = CylinderMesh.new()
	skirt.top_radius = 0.24
	skirt.bottom_radius = 0.44
	skirt.height = 0.68
	skirt.radial_segments = 12
	skirt.rings = 1
	_add_mesh(pelvis, skirt, _fabric(SKIRT_COLOR), Vector3(0.0, -0.37, 0.0))
	var belt: TorusMesh = TorusMesh.new()
	belt.inner_radius = 0.205
	belt.outer_radius = 0.245
	belt.rings = 16
	belt.ring_segments = 6
	_add_mesh(pelvis, belt, _fabric(BELT_COLOR), Vector3(0.0, -0.03, 0.0))
	# Chuspa en la cadera derecha.
	var chuspa: BoxMesh = BoxMesh.new()
	chuspa.size = Vector3(0.13, 0.16, 0.06)
	_add_mesh(pelvis, chuspa, _fabric(CHUSPA_COLOR), Vector3(0.18, -0.06, 0.12))

	# Túnica sobre el torso, con una franja al frente.
	var chest: BoneAttachment3D = _attach("spine_02", "OutfitChest")
	var tunic: CylinderMesh = CylinderMesh.new()
	tunic.top_radius = 0.21
	tunic.bottom_radius = 0.24
	tunic.height = 0.55
	tunic.radial_segments = 12
	tunic.rings = 1
	_add_mesh(chest, tunic, _fabric(TUNIC_COLOR), Vector3(0.0, 0.0, 0.0), Vector3.ZERO, Vector3(1.0, 1.0, 0.8))
	var stripe: BoxMesh = BoxMesh.new()
	stripe.size = Vector3(0.06, 0.45, 0.012)
	_add_mesh(chest, stripe, _fabric(LLICLLA_COLOR), Vector3(0.0, 0.0, 0.17))

	# Cabeza estilizada sobre la cabeza lisa del maniquí.
	var head: BoneAttachment3D = _attach("Head", "OutfitHead")
	var skull: SphereMesh = SphereMesh.new()
	skull.radius = 0.145
	skull.height = 0.29
	skull.radial_segments = 16
	skull.rings = 8
	_add_mesh(head, skull, _skin, Vector3(0.0, 0.12, 0.0), Vector3.ZERO, Vector3(0.9, 1.0, 0.9))
	var neck: CylinderMesh = CylinderMesh.new()
	neck.top_radius = 0.055
	neck.bottom_radius = 0.07
	neck.height = 0.14
	neck.radial_segments = 10
	_add_mesh(head, neck, _skin, Vector3(0.0, -0.02, 0.0))
	# Ojos, cejas, nariz y boca.
	for side: float in [-1.0, 1.0]:
		var sclera: SphereMesh = SphereMesh.new()
		sclera.radius = 0.02
		sclera.height = 0.04
		sclera.radial_segments = 8
		sclera.rings = 4
		_add_mesh(head, sclera, _sclera, Vector3(0.04 * side, 0.12, 0.117), Vector3.ZERO, Vector3(1.25, 0.75, 0.55))
		var eye: SphereMesh = SphereMesh.new()
		eye.radius = 0.011
		eye.height = 0.022
		eye.radial_segments = 8
		eye.rings = 4
		_add_mesh(head, eye, _eye, Vector3(0.04 * side, 0.12, 0.127), Vector3.ZERO, Vector3(1.0, 1.0, 0.5))
		var brow: BoxMesh = BoxMesh.new()
		brow.size = Vector3(0.045, 0.008, 0.008)
		_add_mesh(head, brow, _hair, Vector3(0.04 * side, 0.155, 0.116))
	var nose: SphereMesh = SphereMesh.new()
	nose.radius = 0.018
	nose.height = 0.036
	nose.radial_segments = 8
	nose.rings = 4
	_add_mesh(head, nose, _skin, Vector3(0.0, 0.095, 0.12))
	var mouth: BoxMesh = BoxMesh.new()
	mouth.size = Vector3(0.05, 0.008, 0.01)
	_add_mesh(head, mouth, _mouth, Vector3(0.0, 0.065, 0.118))
	# Pelo, vincha y trenza.
	var hair: SphereMesh = SphereMesh.new()
	hair.radius = 0.135
	hair.height = 0.27
	hair.radial_segments = 16
	hair.rings = 8
	_add_mesh(head, hair, _hair, Vector3(0.0, 0.15, -0.035), Vector3.ZERO, Vector3(1.0, 1.0, 0.95))
	var band: TorusMesh = TorusMesh.new()
	band.inner_radius = 0.13
	band.outer_radius = 0.155
	band.rings = 16
	band.ring_segments = 6
	_add_mesh(head, band, _fabric(LLICLLA_COLOR), Vector3(0.0, 0.19, 0.0))
	var braid: CylinderMesh = CylinderMesh.new()
	braid.top_radius = 0.022
	braid.bottom_radius = 0.03
	braid.height = 0.4
	braid.radial_segments = 8
	_add_mesh(head, braid, _hair, Vector3(0.0, -0.08, -0.12), Vector3(10.0, 0.0, 0.0))
	var tie: CylinderMesh = CylinderMesh.new()
	tie.top_radius = 0.032
	tie.bottom_radius = 0.032
	tie.height = 0.03
	tie.radial_segments = 8
	_add_mesh(head, tie, _fabric(LLICLLA_COLOR), Vector3(0.0, -0.28, -0.155), Vector3(10.0, 0.0, 0.0))


func _attach(bone_name: String, node_name: String) -> BoneAttachment3D:
	var attachment: BoneAttachment3D = BoneAttachment3D.new()
	attachment.name = node_name
	_skeleton.add_child(attachment)
	attachment.bone_name = bone_name
	return attachment


func _add_mesh(
	parent: Node3D,
	mesh: Mesh,
	material: Material,
	at: Vector3,
	rotation_degrees_value: Vector3 = Vector3.ZERO,
	scale_value: Vector3 = Vector3.ONE
) -> MeshInstance3D:
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = at
	instance.rotation_degrees = rotation_degrees_value
	instance.scale = scale_value
	parent.add_child(instance)
	return instance


func _fabric(color: Color) -> ShaderMaterial:
	var material: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.FABRIC, color)
	# La ropa se mueve con el hueso: la proyección va en espacio del objeto para
	# que el tejido no resbale al girar.
	material.set_shader_parameter("world_projection", false)
	return material


func _plain_material(color: Color, roughness: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material
