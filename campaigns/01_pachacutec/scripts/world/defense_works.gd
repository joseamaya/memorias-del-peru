class_name DefenseWorks
extends Node
## Obras de defensa del arrabal: fosos con piedra, ramas y púas de palma.
##
## Cuatro puntos en los accesos del oeste y del sur. Antes de construir se ve el
## foso abierto; al construirlo se cubre con ramas y púas y el cambio queda en
## `WorldState.changes`, así que sobrevive al guardado. La batalla de Carmenca
## (3.9) leerá esos cambios para desgastar la oleada de su acceso.
##
## PCH-039, clasificación H (tradición narrada) / R (puesta en escena).

const WORKS: Array[Dictionary] = [
	{"id": &"defensa_1", "position": Vector2(-130.0, -106.0)},
	{"id": &"defensa_2", "position": Vector2(-128.0, -96.0)},
	{"id": &"defensa_3", "position": Vector2(-128.0, -116.0)},
	{"id": &"defensa_4", "position": Vector2(-100.0, -126.0)},
]

const REQUIRED_FLAG: StringName = &"m01_queda"
const TEXT_KEY: StringName = &"PCH_S01_FOSO"
const PIT_SIZE: float = 3.2
## La cinta de ruta y la plaza van elevadas: el hueco tiene que quedar por
## encima o se ve el suelo en vez del foso.
const HOLE_LIFT: float = 0.06
## Tierra removida del foso abierto (R): un hueco real no cabe en el blockout.
const DUG: Color = Color(0.30, 0.24, 0.18)
const COVER_HEIGHT: float = 0.18
const SPIKE_HEIGHT: float = 0.75
const SPIKE_RADIUS: float = 0.09
const SPIKE_ROWS: int = 3
const HOLE_COLOR: Color = Color(0.008, 0.008, 0.008)
## Las cintas de ruta y la plaza van elevadas: la obra tiene que quedar por
## encima o el foso desaparece bajo ellas.
const STONE: Color = Color(0.50, 0.48, 0.43)
const BRANCH: Color = Color(0.30, 0.20, 0.11)
const SPIKE: Color = Color(0.52, 0.40, 0.22)


## Piezas de un punto construible.
class Site:
	var root: Node3D = null
	var open: Node3D = null
	var built: Node3D = null
	var spot: ChangeInteractable = null


var _world: RegionWorld = null
var _sites: Dictionary[StringName, Site] = {}


## Prepara las obras. Debe llamarse con el mundo creado.
func setup(world: RegionWorld) -> void:
	_world = world
	var world_state: WorldStateService = WorldStateService.instance()
	if world_state == null:
		return
	world_state.world_change_changed.connect(_on_change_changed)
	var streamer: SectorStreamer = world.get_streamer()
	if streamer != null:
		streamer.sector_loaded.connect(_on_sector_loaded)
	_place()


func get_work_count() -> int:
	return _sites.size()


func get_built_count() -> int:
	var state: WorldStateService = WorldStateService.instance()
	if state == null:
		return 0
	var count: int = 0
	for work: Dictionary in WORKS:
		var id: StringName = work["id"]
		if state.has_change(id):
			count += 1
	return count


func get_spot(id: StringName) -> ChangeInteractable:
	var site: Site = _sites.get(id)
	return site.spot if site != null else null


func is_built(id: StringName) -> bool:
	var site: Site = _sites.get(id)
	return site != null and site.built != null and site.built.visible


func _on_sector_loaded(id: StringName, _node: Node3D) -> void:
	if id == &"s1_cusco":
		_place()


func _on_change_changed(id: StringName, value: int) -> void:
	if value == 0 or not _sites.has(id):
		return
	_show_built(id)


## Construye los cuatro puntos cuando el sector de la ciudad está cargado.
func _place() -> void:
	if _world == null or not _sites.is_empty():
		return
	var blockout: CuscoBlockout = (
		_world.get_streamer().get_loaded_node(&"s1_cusco") as CuscoBlockout
	)
	if blockout == null:
		return
	var region: CampaignRegion = _world.get_region()
	for work: Dictionary in WORKS:
		_add_site(work, blockout, region)


func _add_site(work: Dictionary, blockout: CuscoBlockout, region: CampaignRegion) -> void:
	var local: Vector2 = work["position"]
	var id: StringName = work["id"]
	var center: Vector3 = blockout.to_global(Vector3(local.x, 0.0, local.y))
	var heights: Vector2 = _ground_range(center, region)
	var root: Node3D = Node3D.new()
	root.name = "Work_%s" % String(id)
	root.position = Vector3(center.x, heights.y, center.z)
	root.set_meta(&"ground_drop", heights.y - heights.x)
	add_child(root)
	var drop: float = heights.y - heights.x
	var open: Node3D = _build_open(root, drop)
	var built: Node3D = _build_cover(root, drop)
	built.visible = false
	var spot: ChangeInteractable = ChangeInteractable.new()
	spot.name = "Interact"
	spot.change_id = id
	spot.requires_flag = REQUIRED_FLAG
	spot.text_key = TEXT_KEY
	spot.interact_size = Vector3(PIT_SIZE, 0.9, PIT_SIZE)
	spot.highlight_target = open
	root.add_child(spot)
	var site: Site = Site.new()
	site.root = root
	site.open = open
	site.built = built
	site.spot = spot
	_sites[id] = site
	var state: WorldStateService = WorldStateService.instance()
	if state != null and state.has_change(id):
		_show_built(id)


## Foso abierto: un hueco oscuro con borde de piedra.
func _build_open(root: Node3D, drop: float) -> Node3D:
	var open: Node3D = Node3D.new()
	open.name = "Open"
	root.add_child(open)
	_add_box(open, "Dug", Vector3(PIT_SIZE, 0.06, PIT_SIZE), Vector3(0.0, HOLE_LIFT, 0.0), DUG)
	var half: float = PIT_SIZE * 0.5
	for side: float in [-1.0, 1.0]:
		_add_box(
			open,
			"RimX",
			Vector3(PIT_SIZE + 0.4, 0.34 + drop, 0.42),
			Vector3(0.0, (0.34 - drop) * 0.5, side * half),
			STONE
		)
		_add_box(
			open,
			"RimZ",
			Vector3(0.42, 0.34 + drop, PIT_SIZE + 0.4),
			Vector3(side * half, (0.34 - drop) * 0.5, 0.0),
			STONE
		)
	return open


## Foso cubierto: ramas cruzadas sobre el hueco y púas de palma.
func _build_cover(root: Node3D, _drop: float) -> Node3D:
	var built: Node3D = Node3D.new()
	built.name = "Built"
	root.add_child(built)
	# Sombra del hueco: sin ella la tapa parece una tabla apoyada en el suelo.
	_add_hole(built, Vector3(PIT_SIZE, 0.04, PIT_SIZE), Vector3(0.0, HOLE_LIFT, 0.0))
	for index: int in 5:
		var z: float = (float(index) - 2.0) * PIT_SIZE * 0.19
		_add_box(
			built,
			"Branch",
			Vector3(PIT_SIZE + 0.35, 0.13, 0.26),
			Vector3(0.0, HOLE_LIFT + 0.08, z),
			BRANCH
		)
	for row: int in SPIKE_ROWS:
		for column: int in SPIKE_ROWS:
			var x: float = (float(column) - 1.0) * PIT_SIZE * 0.3
			var z: float = (float(row) - 1.0) * PIT_SIZE * 0.3
			var height: float = SPIKE_HEIGHT * (0.78 + 0.11 * float((row + column) % 3))
			_add_spike(built, Vector3(x, HOLE_LIFT + 0.14 + height * 0.5, z), height)
	return built


func _show_built(id: StringName) -> void:
	var site: Site = _sites.get(id)
	if site == null:
		return
	site.open.visible = false
	site.built.visible = true
	site.spot.highlight_target = site.built


## Rango de altura de las esquinas: la tapa va arriba y el borde baja hasta el
## suelo para que nada quede al aire en la ladera.
func _ground_range(center: Vector3, region: CampaignRegion) -> Vector2:
	var half: float = PIT_SIZE * 0.5
	var lowest: float = region.height_at(center.x, center.z)
	var highest: float = lowest
	for dx: float in [-half, half]:
		for dz: float in [-half, half]:
			var height: float = region.height_at(center.x + dx, center.z + dz)
			lowest = minf(lowest, height)
			highest = maxf(highest, height)
	return Vector2(lowest, highest)


## Hueco sin luz: un material sin sombreado se lee como agujero incluso de día.
func _add_hole(parent: Node3D, size: Vector3, at: Vector3) -> void:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	mesh.name = "Hole"
	var box: BoxMesh = BoxMesh.new()
	box.size = size
	mesh.mesh = box
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = HOLE_COLOR
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material_override = material
	mesh.position = at
	parent.add_child(mesh)


func _add_box(parent: Node3D, name_hint: String, size: Vector3, at: Vector3, color: Color) -> void:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	mesh.name = name_hint
	var box: BoxMesh = BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.material_override = BlockoutKit.material(color)
	mesh.position = at
	parent.add_child(mesh)


func _add_spike(parent: Node3D, at: Vector3, height: float) -> void:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	mesh.name = "Spike"
	var cone: CylinderMesh = CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = SPIKE_RADIUS
	cone.height = height
	cone.radial_segments = 5
	mesh.mesh = cone
	mesh.material_override = BlockoutKit.material(SPIKE)
	mesh.position = at
	parent.add_child(mesh)
