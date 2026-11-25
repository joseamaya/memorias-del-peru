class_name CarmencaOverlook
extends Node3D
## Mirador sobre Carmenca y campamento chanca a la vista.
##
## Vive en el sector S2 (afueras). Construye una terraza de piedra con parapeto
## desde la que se ven las tiendas del campamento, al oeste. Es un lugar de
## ficción necesaria (N): el mirador no está documentado; la vista y el
## campamento se apoyan en la geografía y en las crónicas de la guerra chanca
## (PCH-039).
##
## No conoce la misión ni el descubrimiento: solo es geometría. El POI y la
## memoria del diario viven en la campaña.

const PARAPET_HEIGHT: float = 0.85
const POST_RADIUS: float = 0.12
const POST_HEIGHT: float = 2.0
const STONE: Color = Color(0.60, 0.57, 0.50)
const STONE_DARK: Color = Color(0.52, 0.49, 0.43)
const WOOD: Color = Color(0.36, 0.25, 0.15)

## Desplazamiento del campamento respecto al mirador: al oeste y algo al norte.
const CAMP_OFFSET: Vector3 = Vector3(-38.0, 0.0, -18.0)
const CLOTH_LIGHT: Color = Color(0.66, 0.52, 0.34)
const CLOTH_DARK: Color = Color(0.50, 0.38, 0.26)

var _region: CampaignRegion = null
var _tents: Array[Node3D] = []


func _ready() -> void:
	_region = get_tree().get_first_node_in_group(&"campaign_region") as CampaignRegion
	if _region == null:
		_build_when_ready.call_deferred()
		return
	_build()


## Cuando el sector se carga antes que la región, espera unos fotogramas.
func _build_when_ready() -> void:
	for _i: int in 60:
		await get_tree().process_frame
		_region = get_tree().get_first_node_in_group(&"campaign_region") as CampaignRegion
		if _region != null:
			_build()
			return


func get_tent_count() -> int:
	return _tents.size()


## Centro del campamento en coordenadas de mundo y sin altura. Lo usan la
## geometría de las tiendas y [CarmencaBattle]: el estandarte y el radio de
## activación tienen que caer en el mismo sitio que las tiendas.
func camp_center() -> Vector3:
	return global_position + CAMP_OFFSET


func _build() -> void:
	_build_terrace()
	_build_camp()


func _build_terrace() -> void:
	# Un montón de piedras marca el lugar: es la solución andina al "aquí se
	# mira" y no inventa una plataforma que el blockout no puede sostener en
	# una ladera. Se apoya piedra sobre piedra, sin flotar.
	var base: Vector3 = global_position
	var heights: Array[float] = [0.14, 0.30, 0.45, 0.58, 0.70, 0.80]
	var radii: Array[float] = [0.60, 0.50, 0.42, 0.34, 0.26, 0.18]
	for index: int in heights.size():
		var stone: MeshInstance3D = MeshInstance3D.new()
		stone.name = "Stone_%02d" % index
		var mesh: CylinderMesh = CylinderMesh.new()
		mesh.top_radius = radii[index] * 0.86
		mesh.bottom_radius = radii[index]
		mesh.height = heights[index] - (heights[index - 1] if index > 0 else 0.0)
		mesh.radial_segments = 7
		stone.mesh = mesh
		if index > 0:
			# Las piedras altas se apoyan en las de abajo, no en el terreno: la
			# auditoría las trata como elemento apilado a propósito.
			stone.set_meta(&"blockout_kind", "Apacheta")
		stone.material_override = BlockoutKit.material(STONE if index % 2 == 0 else STONE_DARK)
		stone.position = to_local(
			Vector3(
				base.x,
				(
					_ground(base.x, base.z)
					+ (heights[index] + (heights[index - 1] if index > 0 else 0.0)) * 0.5
				),
				base.z
			)
		)
		add_child(stone)


func _build_camp() -> void:
	var camp: Vector3 = camp_center()
	for tent: CampLayout.Tent in CampLayout.tents(camp):
		_add_tent(tent)


func _add_tent(tent: CampLayout.Tent) -> void:
	var node: Node3D = Node3D.new()
	node.name = "Tent_%02d" % _tents.size()
	_tents.append(node)
	var cone: MeshInstance3D = MeshInstance3D.new()
	cone.name = "Cloth"
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = 0.0
	mesh.bottom_radius = tent.radius
	mesh.height = tent.height
	mesh.radial_segments = 8
	cone.mesh = mesh
	cone.material_override = BlockoutKit.material(
		CLOTH_DARK if _tents.size() % 2 == 0 else CLOTH_LIGHT
	)
	# Medio metro enterrado: en ladera, la base de la tienda quedaría al aire en
	# el lado cuesta abajo.
	node.position = to_local(
		Vector3(
			tent.center.x,
			_ground(tent.center.x, tent.center.z) + tent.height * 0.5 - 0.5,
			tent.center.z
		)
	)
	node.add_child(cone)
	node.add_child(_tent_collision(mesh))
	add_child(node)


## Colisión de la tienda con la forma del cono, sin caja invisible alrededor.
##
## Antes la tienda era solo malla y se podía atravesar. El navmesh se hornea
## del terreno, así que los NPC pueden seguir cruzando el campamento; el
## jugador y los cuerpos con física no.
func _tent_collision(mesh: CylinderMesh) -> StaticBody3D:
	var body: StaticBody3D = StaticBody3D.new()
	body.name = "Collision"
	var shape: CollisionShape3D = CollisionShape3D.new()
	shape.name = "Shape"
	shape.shape = mesh.create_convex_shape()
	body.add_child(shape)
	return body


func _add_box(name_hint: String, size: Vector3, at: Vector3, color: Color, collision: bool) -> void:
	var root: Node3D = Node3D.new()
	root.name = name_hint
	root.position = to_local(at)
	add_child(root)
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.material_override = BlockoutKit.material(color)
	root.add_child(mesh)
	if not collision:
		return
	var body: StaticBody3D = StaticBody3D.new()
	var shape: CollisionShape3D = CollisionShape3D.new()
	var box_shape: BoxShape3D = BoxShape3D.new()
	box_shape.size = size
	shape.shape = box_shape
	body.add_child(shape)
	root.add_child(body)


func _add_cylinder(
	name_hint: String, radius: float, height: float, at: Vector3, color: Color
) -> void:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	mesh.name = name_hint
	var cylinder: CylinderMesh = CylinderMesh.new()
	cylinder.top_radius = radius
	cylinder.bottom_radius = radius
	cylinder.height = height
	cylinder.radial_segments = 8
	mesh.mesh = cylinder
	mesh.material_override = BlockoutKit.material(color)
	mesh.position = to_local(at)
	add_child(mesh)


func _ground(x: float, z: float) -> float:
	if _region == null:
		return global_position.y
	return _region.height_at(x, z)
