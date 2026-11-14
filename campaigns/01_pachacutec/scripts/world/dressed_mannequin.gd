class_name DressedMannequin
extends Node3D
## Ropa y rostro estilizados sobre el maniquí UAL1 (ADR-0042).
##
## Primera pasada: piezas rígidas ancladas a huesos con [BoneAttachment3D], sin
## skinning. Cada rol del acto I tiene su conjunto: túnica, falda o faldón,
## cinturón, chuspa, manto, pelo y vincha. La cara es una cáscara estilizada con
## ojos, cejas, nariz y boca. El textil fino y la caída de la tela llegan en una
## pasada posterior.

const SKIN_COLOR: Color = Color(0.72, 0.52, 0.40, 1.0)
const HAIR_COLOR: Color = Color(0.12, 0.08, 0.06, 1.0)
const EYE_COLOR: Color = Color(0.05, 0.03, 0.02, 1.0)
const SCLERA_COLOR: Color = Color(0.9, 0.88, 0.82, 1.0)
const MOUTH_COLOR: Color = Color(0.35, 0.12, 0.10, 1.0)
const BELT_COLOR: Color = Color(0.25, 0.18, 0.12, 1.0)
const CHUSPA_COLOR: Color = Color(0.36, 0.26, 0.18, 1.0)
const STRIPE_COLOR: Color = Color(0.82, 0.78, 0.68, 1.0)

## Rol del vestuario; se fija antes de añadir el nodo al árbol.
var role: StringName = &"villager"
## Variante de color de los vecinos (0–2).
var variant: int = 0

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
	_sclera = _plain_material(SCLERA_COLOR, 0.4)
	_mouth = _plain_material(MOUTH_COLOR, 0.8)
	_build_face()
	match role:
		&"weaver":
			_build_weaver()
		&"farmer":
			_build_farmer()
		&"messenger":
			_build_messenger()
		&"curaca":
			_build_authority(true)
		&"principal":
			_build_authority(false)
		&"chanca":
			_build_chanca()
		_:
			_build_villager()


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


## Cabeza estilizada común: cáscara, ojos, cejas, nariz, boca, pelo y vincha.
func _build_face() -> void:
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
	var hair: SphereMesh = SphereMesh.new()
	hair.radius = 0.135
	hair.height = 0.27
	hair.radial_segments = 16
	hair.rings = 8
	_add_mesh(head, hair, _hair, Vector3(0.0, 0.15, -0.035), Vector3.ZERO, Vector3(1.0, 1.0, 0.95))
	if role == &"weaver":
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
		_add_mesh(head, tie, _fabric(_band_color()), Vector3(0.0, -0.28, -0.155), Vector3(10.0, 0.0, 0.0))
	var wide: bool = role == &"curaca" or role == &"principal"
	var band: TorusMesh = TorusMesh.new()
	band.inner_radius = 0.13
	band.outer_radius = 0.165 if wide else 0.155
	band.rings = 16
	band.ring_segments = 6
	_add_mesh(head, band, _fabric(_band_color()), Vector3(0.0, 0.19, 0.0))


func _build_weaver() -> void:
	var pelvis: BoneAttachment3D = _lower(Color(0.45, 0.16, 0.12, 1.0), 0.24, 0.44, 0.68, -0.37)
	_chuspa(pelvis, CHUSPA_COLOR)
	_torso(Color(0.72, 0.66, 0.55, 1.0), Color(0.55, 0.18, 0.14, 1.0), 0.55)


func _build_farmer() -> void:
	var pelvis: BoneAttachment3D = _lower(Color(0.36, 0.28, 0.20, 1.0), 0.22, 0.30, 0.35, -0.20)
	_chuspa(pelvis, Color(0.32, 0.24, 0.16, 1.0))
	_torso(Color(0.52, 0.42, 0.30, 1.0), Color(0.72, 0.62, 0.45, 1.0), 0.55)


func _build_messenger() -> void:
	var pelvis: BoneAttachment3D = _lower(Color(0.55, 0.40, 0.22, 1.0), 0.22, 0.30, 0.35, -0.20)
	_chuspa(pelvis, Color(0.40, 0.30, 0.20, 1.0))
	_torso(Color(0.70, 0.58, 0.40, 1.0), Color(0.55, 0.20, 0.14, 1.0), 0.55)
	_qipi()


func _build_authority(long_tunic: bool) -> void:
	var lower_color: Color = Color(0.72, 0.66, 0.55, 1.0)
	var cape_color: Color = Color(0.55, 0.18, 0.14, 1.0) if long_tunic else Color(0.52, 0.36, 0.18, 1.0)
	var height: float = 0.90 if long_tunic else 0.75
	var center: float = -0.45 if long_tunic else -0.38
	var pelvis: BoneAttachment3D = _lower(lower_color, 0.24, 0.34, height, center)
	_chuspa(pelvis, Color(0.40, 0.30, 0.20, 1.0))
	_torso(Color(0.78, 0.72, 0.60, 1.0), Color(0.55, 0.20, 0.14, 1.0), 0.55)
	_cape(cape_color)


func _build_chanca() -> void:
	var pelvis: BoneAttachment3D = _lower(Color(0.30, 0.22, 0.16, 1.0), 0.22, 0.30, 0.35, -0.20)
	_chuspa(pelvis, Color(0.28, 0.20, 0.14, 1.0))
	_torso(Color(0.34, 0.26, 0.18, 1.0), Color(0.48, 0.16, 0.12, 1.0), 0.55)
	_porra()


func _build_villager() -> void:
	var tunics: Array[Color] = [
		Color(0.58, 0.48, 0.34, 1.0),
		Color(0.48, 0.38, 0.28, 1.0),
		Color(0.64, 0.54, 0.38, 1.0),
	]
	var lowers: Array[Color] = [
		Color(0.34, 0.26, 0.18, 1.0),
		Color(0.40, 0.30, 0.20, 1.0),
		Color(0.30, 0.24, 0.18, 1.0),
	]
	var index: int = clampi(variant, 0, 2)
	_lower(lowers[index], 0.22, 0.30, 0.35, -0.20)
	_torso(tunics[index], lowers[index], 0.55)


## Falda o faldón con cinturón; devuelve el anclaje de la cadera.
func _lower(color: Color, top_radius: float, bottom_radius: float, height: float, center_y: float) -> BoneAttachment3D:
	var pelvis: BoneAttachment3D = _attach("pelvis", "OutfitPelvis")
	var skirt: CylinderMesh = CylinderMesh.new()
	skirt.top_radius = top_radius
	skirt.bottom_radius = bottom_radius
	skirt.height = height
	skirt.radial_segments = 12
	skirt.rings = 1
	_add_mesh(pelvis, skirt, _fabric(color), Vector3(0.0, center_y, 0.0))
	var belt: TorusMesh = TorusMesh.new()
	belt.inner_radius = top_radius - 0.015
	belt.outer_radius = top_radius + 0.025
	belt.rings = 16
	belt.ring_segments = 6
	_add_mesh(pelvis, belt, _fabric(BELT_COLOR), Vector3(0.0, center_y + height * 0.5 - 0.01, 0.0))
	return pelvis


## Túnica sobre el torso, con franja al frente.
func _torso(tunic_color: Color, stripe_color: Color, height: float) -> void:
	var chest: BoneAttachment3D = _attach("spine_02", "OutfitChest")
	var tunic: CylinderMesh = CylinderMesh.new()
	tunic.top_radius = 0.21
	tunic.bottom_radius = 0.24
	tunic.height = height
	tunic.radial_segments = 12
	tunic.rings = 1
	_add_mesh(chest, tunic, _fabric(tunic_color), Vector3(0.0, 0.0, 0.0), Vector3.ZERO, Vector3(1.0, 1.0, 0.8))
	var stripe: BoxMesh = BoxMesh.new()
	stripe.size = Vector3(0.05, height * 0.8, 0.012)
	_add_mesh(chest, stripe, _fabric(stripe_color), Vector3(0.0, 0.0, 0.17))


func _chuspa(pelvis: BoneAttachment3D, color: Color) -> void:
	var bag: BoxMesh = BoxMesh.new()
	bag.size = Vector3(0.13, 0.16, 0.06)
	_add_mesh(pelvis, bag, _fabric(color), Vector3(0.18, -0.06, 0.12))


## Manto corto de autoridad: cono alrededor de los hombros, no una tabla.
func _cape(color: Color) -> void:
	var shoulders: BoneAttachment3D = _attach("spine_03", "OutfitCape")
	var cape: CylinderMesh = CylinderMesh.new()
	cape.top_radius = 0.24
	cape.bottom_radius = 0.40
	cape.height = 0.28
	cape.radial_segments = 12
	cape.rings = 1
	_add_mesh(shoulders, cape, _fabric(color), Vector3(0.0, -0.05, 0.0), Vector3.ZERO, Vector3(1.0, 1.0, 0.85))
	var trim: CylinderMesh = CylinderMesh.new()
	trim.top_radius = 0.405
	trim.bottom_radius = 0.405
	trim.height = 0.035
	trim.radial_segments = 12
	trim.rings = 1
	_add_mesh(shoulders, trim, _fabric(STRIPE_COLOR), Vector3(0.0, -0.19, 0.0), Vector3.ZERO, Vector3(1.0, 1.0, 0.85))


## Q'ipi del mensajero: bulto pequeño a la espalda.
func _qipi() -> void:
	var back: BoneAttachment3D = _attach("spine_03", "OutfitQipi")
	var bundle: BoxMesh = BoxMesh.new()
	bundle.size = Vector3(0.26, 0.30, 0.16)
	_add_mesh(back, bundle, _fabric(Color(0.45, 0.34, 0.22, 1.0)), Vector3(0.0, -0.02, -0.18))
	var strap: BoxMesh = BoxMesh.new()
	strap.size = Vector3(0.04, 0.34, 0.012)
	_add_mesh(back, strap, _fabric(Color(0.32, 0.24, 0.16, 1.0)), Vector3(0.0, 0.02, 0.14))


## Porra de guerra chanca: mango de madera y cabeza de piedra en la mano derecha.
func _porra() -> void:
	var hand: BoneAttachment3D = _attach("hand_r", "OutfitPorra")
	var wood: StandardMaterial3D = _plain_material(Color(0.32, 0.23, 0.15, 1.0), 1.0)
	var stone: StandardMaterial3D = _plain_material(Color(0.42, 0.40, 0.37, 1.0), 1.0)
	var handle: CylinderMesh = CylinderMesh.new()
	handle.top_radius = 0.025
	handle.bottom_radius = 0.032
	handle.height = 0.62
	handle.radial_segments = 8
	_add_mesh(hand, handle, wood, Vector3(0.0, 0.0, 0.24), Vector3(90.0, 0.0, 0.0))
	var head: SphereMesh = SphereMesh.new()
	head.radius = 0.1
	head.height = 0.2
	head.radial_segments = 8
	head.rings = 4
	_add_mesh(hand, head, stone, Vector3(0.0, 0.0, 0.56), Vector3.ZERO, Vector3(1.0, 1.0, 0.8))


func _band_color() -> Color:
	match role:
		&"weaver":
			return Color(0.55, 0.18, 0.14, 1.0)
		&"farmer":
			return Color(0.30, 0.20, 0.12, 1.0)
		&"messenger":
			return Color(0.55, 0.20, 0.14, 1.0)
		&"curaca":
			return Color(0.62, 0.20, 0.14, 1.0)
		&"principal":
			return Color(0.50, 0.30, 0.12, 1.0)
		&"chanca":
			return Color(0.45, 0.18, 0.12, 1.0)
	var bands: Array[Color] = [
		Color(0.36, 0.26, 0.18, 1.0),
		Color(0.48, 0.34, 0.20, 1.0),
		Color(0.30, 0.24, 0.18, 1.0),
	]
	return bands[clampi(variant, 0, 2)]


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
