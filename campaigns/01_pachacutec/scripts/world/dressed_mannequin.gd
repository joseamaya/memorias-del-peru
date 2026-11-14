class_name DressedMannequin
extends Node3D
## Ropa y rostro estilizados sobre el maniquí UAL1 (ADR-0042).
##
## Piezas ancladas a huesos con [BoneAttachment3D]. La ropa principal usa un
## textil procedural con franjas; la lliclla son dos paños curvos (espalda y
## cadera) que se solapan y siguen el cuerpo sin verse como una tabla; las
## sandalias siguen la posición del pie. El textil fino y la simulación de tela
## completa quedan para una pasada posterior.

const SKIN_COLOR: Color = Color(0.72, 0.52, 0.40, 1.0)
const HAIR_COLOR: Color = Color(0.12, 0.08, 0.06, 1.0)
const EYE_COLOR: Color = Color(0.05, 0.03, 0.02, 1.0)
const SCLERA_COLOR: Color = Color(0.9, 0.88, 0.82, 1.0)
const MOUTH_COLOR: Color = Color(0.35, 0.12, 0.10, 1.0)
const BELT_COLOR: Color = Color(0.25, 0.18, 0.12, 1.0)
const CHUSPA_COLOR: Color = Color(0.36, 0.26, 0.18, 1.0)
const STRIPE_COLOR: Color = Color(0.82, 0.78, 0.68, 1.0)
const SANDAL_COLOR: Color = Color(0.30, 0.20, 0.13, 1.0)

## Sandalia: huesos del pie y pivote que sigue la planta.
class Sandal:
	var foot: int
	var ball: int
	var pivot: Node3D

	func _init(foot_idx: int, ball_idx: int, pivot_node: Node3D) -> void:
		foot = foot_idx
		ball = ball_idx
		pivot = pivot_node


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
var _sandals: Array[Sandal] = []
static var _textiles: Dictionary[String, StandardMaterial3D] = {}


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
	_build_sandals()


func _process(_delta: float) -> void:
	if _skeleton == null or _sandals.is_empty():
		return
	for sandal: Sandal in _sandals:
		var foot_pose: Transform3D = _skeleton.get_bone_global_pose(sandal.foot)
		var ball_pose: Transform3D = _skeleton.get_bone_global_pose(sandal.ball)
		var foot_world: Transform3D = _skeleton.global_transform * foot_pose
		var ball_world: Transform3D = _skeleton.global_transform * ball_pose
		var heel: Vector3 = foot_world.origin
		var toe: Vector3 = ball_world.origin
		var forward: Vector3 = toe - heel
		forward.y = 0.0
		if forward.length() < 0.01:
			continue
		forward = forward.normalized()
		var center: Vector3 = (heel + toe) * 0.5
		center.y = toe.y - 0.005
		var yaw: float = atan2(forward.x, forward.z)
		sandal.pivot.global_transform = Transform3D(Basis(Vector3.UP, yaw), center)


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
	var pelvis: BoneAttachment3D = _lower(Color(0.45, 0.16, 0.12, 1.0), Color(0.28, 0.09, 0.07, 1.0), 0.24, 0.44, 0.68, -0.37)
	_chuspa(pelvis, CHUSPA_COLOR)
	_torso(Color(0.72, 0.66, 0.55, 1.0), Color(0.55, 0.18, 0.14, 1.0), 0.55)
	_lliclla(Color(0.55, 0.18, 0.14, 1.0), STRIPE_COLOR)


func _build_farmer() -> void:
	var pelvis: BoneAttachment3D = _lower(Color(0.36, 0.28, 0.20, 1.0), Color(0.24, 0.18, 0.12, 1.0), 0.22, 0.30, 0.35, -0.20)
	_chuspa(pelvis, Color(0.32, 0.24, 0.16, 1.0))
	_torso(Color(0.52, 0.42, 0.30, 1.0), Color(0.72, 0.62, 0.45, 1.0), 0.55)


func _build_messenger() -> void:
	var pelvis: BoneAttachment3D = _lower(Color(0.55, 0.40, 0.22, 1.0), Color(0.36, 0.25, 0.14, 1.0), 0.22, 0.30, 0.35, -0.20)
	_chuspa(pelvis, Color(0.40, 0.30, 0.20, 1.0))
	_torso(Color(0.70, 0.58, 0.40, 1.0), Color(0.55, 0.20, 0.14, 1.0), 0.55)
	_qipi()


func _build_authority(long_tunic: bool) -> void:
	var lower_color: Color = Color(0.72, 0.66, 0.55, 1.0)
	var cape_color: Color = Color(0.55, 0.18, 0.14, 1.0) if long_tunic else Color(0.52, 0.36, 0.18, 1.0)
	var height: float = 0.90 if long_tunic else 0.75
	var center: float = -0.45 if long_tunic else -0.38
	var pelvis: BoneAttachment3D = _lower(lower_color, Color(0.55, 0.18, 0.14, 1.0), 0.24, 0.34, height, center)
	_chuspa(pelvis, Color(0.40, 0.30, 0.20, 1.0))
	_torso(Color(0.78, 0.72, 0.60, 1.0), Color(0.55, 0.20, 0.14, 1.0), 0.55)
	_cape(cape_color, STRIPE_COLOR)


func _build_chanca() -> void:
	var pelvis: BoneAttachment3D = _lower(Color(0.30, 0.22, 0.16, 1.0), Color(0.20, 0.12, 0.09, 1.0), 0.22, 0.30, 0.35, -0.20)
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
	_lower(lowers[index], lowers[index].darkened(0.2), 0.22, 0.30, 0.35, -0.20)
	_torso(tunics[index], lowers[index], 0.55)
	_lliclla(tunics[index].darkened(0.12), lowers[index].lightened(0.25))


## Falda o faldón con cinturón; devuelve el anclaje de la cadera.
func _lower(color: Color, stripe: Color, top_radius: float, bottom_radius: float, height: float, center_y: float) -> BoneAttachment3D:
	var pelvis: BoneAttachment3D = _attach("pelvis", "OutfitPelvis")
	var skirt: CylinderMesh = CylinderMesh.new()
	skirt.top_radius = top_radius
	skirt.bottom_radius = bottom_radius
	skirt.height = height
	skirt.radial_segments = 12
	skirt.rings = 1
	_add_mesh(pelvis, skirt, _textile(color, stripe), Vector3(0.0, center_y, 0.0))
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
	_add_mesh(chest, tunic, _textile(tunic_color, stripe_color), Vector3(0.0, 0.0, 0.0), Vector3.ZERO, Vector3(1.0, 1.0, 0.8))
	var stripe: BoxMesh = BoxMesh.new()
	stripe.size = Vector3(0.05, height * 0.8, 0.012)
	_add_mesh(chest, stripe, _fabric(stripe_color), Vector3(0.0, 0.0, 0.17))


func _chuspa(pelvis: BoneAttachment3D, color: Color) -> void:
	var bag: BoxMesh = BoxMesh.new()
	bag.size = Vector3(0.13, 0.16, 0.06)
	_add_mesh(pelvis, bag, _fabric(color), Vector3(0.18, -0.06, 0.12))


## Lliclla: un solo paño largo colgado de la cadera, de los hombros a los
## muslos. Al no seguir el pecho, no se convierte en una tabla cuando la
## tejedora se inclina; la tela se abre y se separa del cuerpo en el borde.
func _lliclla(color: Color, stripe: Color) -> void:
	var pelvis: BoneAttachment3D = _attach("pelvis", "OutfitLliclla")
	_add_cloth_mesh(pelvis, _cloth_panel(0.50, 0.85, 0.20, 0.06, 0.18, 0.12), _textile_double(color, stripe), Vector3(0.0, 0.43, 0.0))


## Manto corto de autoridad: cono alrededor de los hombros, no una tabla.
func _cape(color: Color, stripe: Color) -> void:
	var shoulders: BoneAttachment3D = _attach("spine_03", "OutfitCape")
	var cape: CylinderMesh = CylinderMesh.new()
	cape.top_radius = 0.24
	cape.bottom_radius = 0.40
	cape.height = 0.28
	cape.radial_segments = 12
	cape.rings = 1
	_add_mesh(shoulders, cape, _textile(color, stripe), Vector3(0.0, -0.05, 0.0), Vector3.ZERO, Vector3(1.0, 1.0, 0.85))
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


## Sandalias: la suela sigue la posición del pie y mantiene la planta plana.
func _build_sandals() -> void:
	for side: String in ["l", "r"]:
		var foot_idx: int = _skeleton.find_bone("foot_%s" % side)
		var ball_idx: int = _skeleton.find_bone("ball_%s" % side)
		if foot_idx < 0 or ball_idx < 0:
			continue
		var pivot: Node3D = Node3D.new()
		pivot.name = "OutfitSandal%s" % side.to_upper()
		pivot.top_level = true
		add_child(pivot)
		var leather: StandardMaterial3D = _plain_material(SANDAL_COLOR, 1.0)
		var sole: BoxMesh = BoxMesh.new()
		sole.size = Vector3(0.11, 0.025, 0.28)
		_add_mesh(pivot, sole, leather, Vector3.ZERO)
		var strap: BoxMesh = BoxMesh.new()
		strap.size = Vector3(0.10, 0.018, 0.03)
		_add_mesh(pivot, strap, leather, Vector3(0.0, 0.035, 0.04))
		var thong: BoxMesh = BoxMesh.new()
		thong.size = Vector3(0.018, 0.018, 0.10)
		_add_mesh(pivot, thong, leather, Vector3(0.0, 0.035, 0.09))
		_sandals.append(Sandal.new(foot_idx, ball_idx, pivot))


## Paño curvo con UV para el textil; el borde inferior se abre y se separa del
## cuerpo. Devuelve una malla triangular.
func _cloth_panel(width: float, height: float, back_offset: float, depth: float, flare_z: float, flare_x: float) -> ArrayMesh:
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var cols: int = 8
	var rows: int = 6
	for row: int in range(rows + 1):
		for col: int in range(cols + 1):
			var u: float = float(col) / float(cols)
			var v: float = float(row) / float(rows)
			var x: float = (u - 0.5) * width * (1.0 + flare_x * v)
			var y: float = -v * height
			var z: float = -back_offset - depth * (0.5 + 0.5 * cos((u - 0.5) * PI)) - flare_z * v
			surface.set_uv(Vector2(u, v))
			surface.add_vertex(Vector3(x, y, z))
	for row: int in range(rows):
		for col: int in range(cols):
			var index: int = row * (cols + 1) + col
			surface.add_index(index)
			surface.add_index(index + 1)
			surface.add_index(index + cols + 2)
			surface.add_index(index)
			surface.add_index(index + cols + 2)
			surface.add_index(index + cols + 1)
	surface.generate_normals()
	return surface.commit()


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


## Malla de tela con el material en la superficie y con nombre de ropa: así el
## validador de materiales la distingue de los modelos generados.
func _add_cloth_mesh(parent: Node3D, mesh: Mesh, material: StandardMaterial3D, at: Vector3) -> MeshInstance3D:
	var array_mesh: ArrayMesh = mesh as ArrayMesh
	if array_mesh != null:
		material.resource_name = &"pch_cloth"
		array_mesh.surface_set_material(0, material)
	return _add_mesh(parent, mesh, material, at)


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


## Textil procedural con franjas verticales y trama fina; una textura por par
## de colores, compartida entre personajes.
func _textile(base: Color, stripe: Color) -> StandardMaterial3D:
	var key: String = "%s|%s" % [base.to_html(), stripe.to_html()]
	if _textiles.has(key):
		return _textiles[key]
	var image: Image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	for y: int in range(64):
		for x: int in range(64):
			# Franja fina cada 16 px: una línea, no una bandera.
			var band: int = x % 16
			var color: Color = base
			if band < 2:
				color = stripe
			elif band < 3:
				color = base.darkened(0.15)
			if y % 8 == 0:
				color = color.darkened(0.05)
			image.set_pixel(x, y, color)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_texture = ImageTexture.create_from_image(image)
	material.albedo_color = Color.WHITE
	material.roughness = 1.0
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_textiles[key] = material
	return material


func _textile_double(base: Color, stripe: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = _textile(base, stripe).duplicate() as StandardMaterial3D
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material


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
