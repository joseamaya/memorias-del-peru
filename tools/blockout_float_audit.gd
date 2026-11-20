extends SceneTree
## Auditoría de geometría flotante del blockout regional.
##
## Carga los seis sectores y compara cada vértice de sus mallas con la
## superficie del terreno. Un objeto cuyo punto más bajo queda por encima del
## terreno es candidato a flotar; el informe permite clasificarlo.
##
## Uso:
##   godot --headless --path . --script res://tools/blockout_float_audit.gd

const SCENE_PATH: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const OUTPUT_PATH: String = "res://build/evidencia/blockout_float_audit.txt"
const THRESHOLD: float = 0.30
const SUPPORT_TOLERANCE: float = 0.35
const WAIT_FRAMES: int = 240
## Superficies que deben seguir el terreno: se revisan por su borde más alto.
const FLAT_KINDS: Array[String] = [
	"Plaza", "PlazaCusco", "Nieve", "Bofedal", "Poza", "Fuego", "Ribbon"
]
## Elementos elevados a propósito o apoyados en una plataforma revisada.
const INTENTIONAL_KINDS: Array[String] = [
	"Techo",
	"Toldo",
	"Canopia",
	"PuestoTecho",
	"CoricanchaMuro",
	"Parapeto",
	"Casa",
	"TelarViga",
]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	if packed == null:
		printerr("AUDIT_FAIL no scene")
		quit(1)
		return
	var world: RegionWorld = packed.instantiate() as RegionWorld
	world.first_person = false
	root.add_child(world)
	for _i: int in WAIT_FRAMES:
		await process_frame
	var region: CampaignRegion = world.get_region()
	var streamer: SectorStreamer = world.get_streamer()
	if region == null or streamer == null:
		printerr("AUDIT_FAIL no region or streamer")
		quit(1)
		return
	var terrain: Terrain3D = region.get_terrain()
	if terrain == null:
		printerr("AUDIT_FAIL no terrain")
		quit(1)
		return

	var lines: PackedStringArray = PackedStringArray()
	var total: int = 0
	var floating: int = 0
	var sectors_ok: bool = true
	for definition: SectorDefinition in streamer.sectors:
		if definition == null:
			continue
		var center: Vector3 = CampaignRegion.SECTORS.get(definition.id, Vector3.ZERO)
		world.set_target_position(center)
		if not await _wait_loaded(streamer, definition.id):
			lines.append("SECTOR_FAIL %s" % definition.id)
			sectors_ok = false
			continue
		var sector: Node3D = streamer.get_loaded_node(definition.id)
		if sector == null:
			lines.append("SECTOR_FAIL %s" % definition.id)
			sectors_ok = false
			continue
		var counts: Vector2i = _audit_node(sector, terrain, definition.id, lines)
		total += counts.x
		floating += counts.y
		lines.append("SECTOR %s meshes=%d floating=%d" % [definition.id, counts.x, counts.y])

	# Cintas de ruta: se auditan aparte porque viven fuera de los sectores.
	var routes: Node = world.get_node_or_null("Routes")
	if routes != null:
		var counts: Vector2i = _audit_node(routes, terrain, &"routes", lines)
		total += counts.x
		floating += counts.y
		lines.append("SECTOR routes meshes=%d floating=%d" % [counts.x, counts.y])

	lines.append("TOTAL meshes=%d floating=%d threshold=%.2f" % [total, floating, THRESHOLD])
	var report: String = "\n".join(lines)
	print(report)
	var file: FileAccess = FileAccess.open(OUTPUT_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(report + "\n")
		file.close()
	world.queue_free()
	await process_frame
	quit(0 if sectors_ok and floating == 0 else 1)


func _wait_loaded(streamer: SectorStreamer, id: StringName) -> bool:
	for _i: int in WAIT_FRAMES:
		if streamer.is_loaded(id):
			return true
		await process_frame
	return false


func _audit_node(
	node: Node, terrain: Terrain3D, sector_id: StringName, lines: PackedStringArray
) -> Vector2i:
	var total: int = 0
	var floating: int = 0
	var instances: Array[MeshInstance3D] = []
	var meshes: Array[Node] = node.find_children("*", "MeshInstance3D", true, false)
	if node is MeshInstance3D:
		meshes.append(node)
	for item: Node in meshes:
		var instance: MeshInstance3D = item as MeshInstance3D
		if instance != null and instance.mesh != null:
			instances.append(instance)

	for instance: MeshInstance3D in instances:
		total += 1
		var kind: String = _kind_of(instance)
		if kind in INTENTIONAL_KINDS:
			if kind != "Canopia" and not _has_support(instance, instances):
				floating += 1
				lines.append(
					(
						"UNSUPPORTED sector=%s kind=%s node=%s"
						% [sector_id, kind, str(instance.get_path())]
					)
				)
			continue
		var gaps: Vector2 = _gap_range(instance, terrain)
		if is_nan(gaps.x):
			continue
		var suspicious: bool = false
		if kind in FLAT_KINDS:
			suspicious = gaps.y > THRESHOLD
		else:
			suspicious = gaps.x > THRESHOLD
		if not suspicious:
			continue
		floating += 1
		var material: Material = instance.material_override
		var color: Color = Color.WHITE
		if material is StandardMaterial3D:
			color = (material as StandardMaterial3D).albedo_color
		(
			lines
			. append(
				(
					"FLOAT sector=%s kind=%s min=%.2f max=%.2f node=%s mesh=%s size=%s color=%s"
					% [
						sector_id,
						kind,
						gaps.x,
						gaps.y,
						str(instance.get_path()),
						instance.mesh.get_class(),
						str(instance.mesh.get_aabb().size),
						color.to_html(),
					]
				)
			)
		)
	return Vector2i(total, floating)


## Comprueba que un elemento elevado tenga algo debajo. No basta con llamarlo
## "Techo": si no hay muro, poste o plataforma que lo sostenga, se reporta.
func _has_support(instance: MeshInstance3D, instances: Array[MeshInstance3D]) -> bool:
	var local_aabb: AABB = instance.mesh.get_aabb()
	var bottom: float = local_aabb.position.y
	var xs: Array[float] = []
	var zs: Array[float] = []
	for step: int in 9:
		var t: float = float(step) / 8.0
		xs.append(lerpf(local_aabb.position.x, local_aabb.end.x, t))
		zs.append(lerpf(local_aabb.position.z, local_aabb.end.z, t))
	for x: float in xs:
		for z: float in zs:
			var point: Vector3 = instance.global_transform * Vector3(x, bottom, z)
			for other: MeshInstance3D in instances:
				if other == instance or other.mesh == null:
					continue
				var other_aabb: AABB = other.global_transform * other.mesh.get_aabb()
				if point.x < other_aabb.position.x - 0.1:
					continue
				if point.x > other_aabb.end.x + 0.1:
					continue
				if point.z < other_aabb.position.z - 0.1:
					continue
				if point.z > other_aabb.end.z + 0.1:
					continue
				if absf(other_aabb.end.y - point.y) <= SUPPORT_TOLERANCE:
					return true
	return false


func _kind_of(instance: Node) -> String:
	var node: Node = instance
	while node != null:
		if node.has_meta(&"blockout_kind"):
			return str(node.get_meta(&"blockout_kind"))
		node = node.get_parent()
	return "Unknown"


func _gap_range(instance: MeshInstance3D, terrain: Terrain3D) -> Vector2:
	var mesh: Mesh = instance.mesh
	var arrays: Array = []
	if mesh is ArrayMesh:
		var array_mesh: ArrayMesh = mesh as ArrayMesh
		if array_mesh.get_surface_count() == 0:
			return Vector2(NAN, NAN)
		arrays = array_mesh.surface_get_arrays(0)
	elif mesh is PrimitiveMesh:
		arrays = (mesh as PrimitiveMesh).surface_get_arrays(0)
	else:
		return Vector2(NAN, NAN)
	if arrays.is_empty():
		return Vector2(NAN, NAN)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var minimum: float = INF
	var maximum: float = -INF
	for vertex: Vector3 in vertices:
		var world: Vector3 = instance.global_transform * vertex
		var terrain_y: float = terrain.data.get_surface_height(world)
		if is_nan(terrain_y):
			continue
		var gap: float = world.y - terrain_y
		minimum = minf(minimum, gap)
		maximum = maxf(maximum, gap)
	if minimum == INF:
		return Vector2(NAN, NAN)
	return Vector2(minimum, maximum)
