class_name GreySector
extends Node3D
## Sector gris de integración F1: Terrain3D, pirca de Cyclops, navmesh
## horneado sobre el terreno, 20 NPC en ruta y reloj de mundo.
##
## No es contenido de campaña: es una escena de prueba para comprobar que los
## sistemas conviven antes del blockout de F2.

const NPC_SPEED: float = 1.6
const BODY_OFFSET: float = 0.9
## Radio del corro en el que se reparten los NPC alrededor de un ancla.
const ANCHOR_RADIUS: float = 1.6
const ANCHOR_RING_STEP: float = 0.65

@export var npc_count: int = 20
@export var terrain_size: int = 256
@export var navmesh_bounds: AABB = AABB(Vector3(-60.0, -2.0, -60.0), Vector3(120.0, 10.0, 120.0))

var _terrain: Terrain3D = null
var _navigation: NavigationService = null
var _navigation_region: NavigationRegion3D = null
var _navmesh: NavigationMesh = null
var _cyclops_block: CyclopsBlock = null
var _npc_nodes: Array[Node3D] = []
var _movers: Array[NpcMover] = []
var _targets: Array[StringName] = []
var _definitions: Array[NpcDefinition] = []
var _anchors: Dictionary[StringName, Vector3] = {}
var _camera: Camera3D = null
var _minute: int = 360


func _ready() -> void:
	_build_environment()
	_build_camera()
	_build_terrain()
	_build_pirca()
	_build_navigation()
	_build_npcs()
	set_process(true)


func _process(delta: float) -> void:
	if _camera != null:
		var angle: float = Time.get_ticks_msec() / 1000.0 * 0.08
		_camera.position = Vector3(cos(angle) * 48.0, 16.0, sin(angle) * 48.0)
		_camera.look_at(Vector3(0.0, 1.0, 0.0), Vector3.UP)
	var clock: WorldClockService = WorldClockService.instance()
	if clock != null:
		_update_npcs(clock.get_minute_of_day(), delta)


## Actualiza los NPC a la hora indicada. Con `immediate`, los coloca en el ancla.
func update_npcs(minute: int, immediate: bool = false) -> void:
	_update_npcs(minute, 0.0, immediate)


## Avanza la simulación de caminata sin depender del reloj real.
func advance_npcs(seconds: float, step: float = 0.2) -> void:
	var safe_step: float = maxf(step, 0.02)
	var elapsed: float = 0.0
	while elapsed < seconds:
		var slice: float = minf(safe_step, seconds - elapsed)
		_update_npcs(_minute, slice, false)
		elapsed += slice


func get_npc_count() -> int:
	return _npc_nodes.size()


func get_npc_position(index: int) -> Vector3:
	if index < 0 or index >= _npc_nodes.size():
		return Vector3.ZERO
	return _npc_nodes[index].position


func get_npc_anchor(index: int, minute: int) -> StringName:
	if index < 0 or index >= _definitions.size():
		return &""
	return _definitions[index].get_anchor(minute)


func get_npc_target(index: int) -> StringName:
	if index < 0 or index >= _targets.size():
		return &""
	return _targets[index]


## Indica si el NPC ya está en el ancla de su horario.
func is_npc_at_target(index: int, tolerance: float = 0.6) -> bool:
	if index < 0 or index >= _npc_nodes.size() or index >= _targets.size():
		return false
	if not _anchors.has(_targets[index]):
		return false
	return _npc_nodes[index].position.distance_to(_goal_for(index, _targets[index])) <= tolerance


## Punto concreto del corro de un NPC en su ancla actual.
func get_npc_goal_position(index: int) -> Vector3:
	if index < 0 or index >= _targets.size() or not _anchors.has(_targets[index]):
		return Vector3.ZERO
	return _goal_for(index, _targets[index])


func get_anchor_position(anchor_id: StringName) -> Vector3:
	if _anchors.has(anchor_id):
		return _anchors[anchor_id]
	return Vector3.ZERO


func get_navmesh_path(from: Vector3, to: Vector3) -> PackedVector3Array:
	if _navigation == null:
		return PackedVector3Array()
	return _navigation.find_path(from, to)


func get_navmesh() -> NavigationMesh:
	return _navmesh


func get_navigation_region() -> NavigationRegion3D:
	return _navigation_region


func get_terrain() -> Terrain3D:
	return _terrain


func get_cyclops_block() -> CyclopsBlock:
	return _cyclops_block


func height_at(x: float, z: float) -> float:
	var distance: float = sqrt(x * x + z * z)
	if distance < 36.0:
		return 0.0
	return (distance - 36.0) * 0.06 + sin(x * 0.05) * 0.8 + cos(z * 0.045) * 0.7


func _build_environment() -> void:
	var environment: Environment = Environment.new()
	environment.background_mode = Environment.BG_SKY
	var sky: Sky = Sky.new()
	sky.sky_material = ProceduralSkyMaterial.new()
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_energy = 1.0
	var world_environment: WorldEnvironment = WorldEnvironment.new()
	world_environment.environment = environment
	add_child(world_environment)
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45.0, -35.0, 0.0)
	sun.light_energy = 1.2
	sun.shadow_enabled = true
	add_child(sun)


func _build_camera() -> void:
	_camera = Camera3D.new()
	_camera.name = "GreySectorCamera"
	_camera.current = true
	_camera.fov = 70.0
	_camera.position = Vector3(0.0, 16.0, 48.0)
	add_child(_camera)


func _build_terrain() -> void:
	_terrain = Terrain3D.new()
	_terrain.name = "Terrain3D"
	_terrain.region_size = Terrain3D.SIZE_256
	_terrain.vertex_spacing = 1.0
	_terrain.free_editor_textures = false
	_terrain.clipmap_target = _camera
	_terrain.set("collision_mode", 3)
	_terrain.set("collision_target", _camera)
	add_child(_terrain)
	var image: Image = Image.create(terrain_size, terrain_size, false, Image.FORMAT_RF)
	for y: int in terrain_size:
		for x: int in terrain_size:
			var wx: float = float(x) - float(terrain_size) * 0.5
			var wz: float = float(y) - float(terrain_size) * 0.5
			image.set_pixel(x, y, Color(height_at(wx, wz), 0.0, 0.0, 1.0))
	var images: Array[Image] = [image, null, null]
	_terrain.data.import_images(
		images, Vector3(-float(terrain_size) * 0.5, 0.0, -float(terrain_size) * 0.5), 0.0, 1.0
	)
	_terrain.data.calc_height_range(true)


func _build_navigation() -> void:
	var obstacles: Array[PackedVector3Array] = [_pirca_footprint()]
	var profile: NavmeshProfile = NavmeshProfile.new()
	profile.step = 2.0
	_navmesh = TerrainNavmesh.bake(_terrain, navmesh_bounds, profile, obstacles)
	if _navmesh == null:
		push_error("GreySector: no se pudo hornear el navmesh.")
		return
	_navigation_region = NavigationRegion3D.new()
	_navigation_region.name = "TerrainNavigation"
	_navigation_region.navigation_mesh = _navmesh
	add_child(_navigation_region)
	_navigation = NavigationService.new()
	_navigation.name = "NavigationService"
	add_child(_navigation)


func _build_pirca() -> void:
	var data: ConvexBlockData = _cube_data(8.0, 1.0, 0.6)
	_cyclops_block = CyclopsBlock.new()
	_cyclops_block.name = "PircaCyclops"
	_cyclops_block.block_data = data
	_cyclops_block.position = Vector3(0.0, 0.5, -18.0)
	add_child(_cyclops_block)


## Huella en XZ de la pirca: recorta el navmesh para que nadie la atraviese.
func _pirca_footprint() -> PackedVector3Array:
	return PackedVector3Array(
		[
			Vector3(-4.0, 0.0, -18.3),
			Vector3(4.0, 0.0, -18.3),
			Vector3(4.0, 0.0, -17.7),
			Vector3(-4.0, 0.0, -17.7),
		]
	)


func _build_anchors() -> void:
	_anchors = {
		&"casa": _anchor(-12.0, 10.0),
		&"trabajo": _anchor(26.0, -18.0),
		&"plaza": _anchor(0.0, 0.0),
		&"campo": _anchor(44.0, 32.0),
	}


func _anchor(x: float, z: float) -> Vector3:
	return Vector3(x, height_at(x, z) + BODY_OFFSET, z)


func _build_npcs() -> void:
	_build_anchors()
	for index: int in npc_count:
		var definition: NpcDefinition = NpcDefinition.new()
		definition.id = StringName("npc_gris_%d" % index)
		definition.name_key = &"NPC_GRIS"
		definition.home_anchor = &"casa"
		definition.work_anchor = &"trabajo"
		definition.schedule.append(_entry(0, 360, &"casa", &"dormir"))
		definition.schedule.append(_entry(360, 1080, &"trabajo", &"trabajar"))
		definition.schedule.append(_entry(1080, 1440, &"casa", &"casa"))
		if index % 4 == 0:
			definition.schedule[1].anchor_id = &"campo"
		_definitions.append(definition)
		var npc: Node3D = Node3D.new()
		npc.name = StringName("GreyNpc%d" % index)
		var mesh: MeshInstance3D = MeshInstance3D.new()
		var capsule: CapsuleMesh = CapsuleMesh.new()
		capsule.radius = 0.35
		capsule.height = 1.7
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = Color(0.55, 0.40 + float(index % 5) * 0.03, 0.30)
		capsule.material = material
		mesh.mesh = capsule
		npc.add_child(mesh)
		add_child(npc)
		_npc_nodes.append(npc)
		var mover: NpcMover = NpcMover.new()
		mover.speed = NPC_SPEED
		mover.body_offset = BODY_OFFSET
		_movers.append(mover)
		_targets.append(&"")
	var clock: WorldClockService = WorldClockService.instance()
	var minute: int = clock.get_minute_of_day() if clock != null else 360
	_update_npcs(minute, 0.0, true)


func _update_npcs(minute: int, delta: float, immediate: bool = false) -> void:
	_minute = minute
	for index: int in _npc_nodes.size():
		var anchor_id: StringName = _definitions[index].get_anchor(minute)
		if not _anchors.has(anchor_id):
			anchor_id = &"plaza"
		var npc: Node3D = _npc_nodes[index]
		var goal: Vector3 = _goal_for(index, anchor_id)
		if immediate:
			npc.position = goal
			_targets[index] = anchor_id
			_movers[index].set_path(PackedVector3Array())
			continue
		if _targets[index] != anchor_id:
			_targets[index] = anchor_id
			_begin_path(index, goal)
		if delta > 0.0:
			_movers[index].advance(npc, delta)


## Reparte el grupo en un corro alrededor del ancla para que no se apilen.
func _goal_for(index: int, anchor_id: StringName) -> Vector3:
	var base: Vector3 = _anchors[&"plaza"]
	if _anchors.has(anchor_id):
		base = _anchors[anchor_id]
	var radius: float = ANCHOR_RADIUS + float(index % 4) * ANCHOR_RING_STEP
	var angle: float = float(index) * 2.399963
	return base + Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)


func _begin_path(index: int, target: Vector3) -> void:
	var npc: Node3D = _npc_nodes[index]
	var origin: Vector3 = Vector3(npc.position.x, target.y, npc.position.z)
	var path: PackedVector3Array = PackedVector3Array()
	if _navigation != null:
		path = _navigation.find_path(origin, target)
	if path.is_empty():
		path = PackedVector3Array([target])
	_movers[index].set_path(path)


func _entry(start: int, end: int, anchor: StringName, activity: StringName) -> ScheduleEntry:
	var entry: ScheduleEntry = ScheduleEntry.new()
	entry.start_minute = start
	entry.end_minute = end
	entry.anchor_id = anchor
	entry.activity = activity
	return entry


func _cube_data(width: float, height: float, depth: float) -> ConvexBlockData:
	var data: ConvexBlockData = ConvexBlockData.new()
	var half_x: float = width * 0.5
	var half_y: float = height * 0.5
	var half_z: float = depth * 0.5
	data.vertex_points = PackedVector3Array(
		[
			Vector3(-half_x, -half_y, -half_z),
			Vector3(half_x, -half_y, -half_z),
			Vector3(half_x, half_y, -half_z),
			Vector3(-half_x, half_y, -half_z),
			Vector3(-half_x, -half_y, half_z),
			Vector3(half_x, -half_y, half_z),
			Vector3(half_x, half_y, half_z),
			Vector3(-half_x, half_y, half_z),
		]
	)
	data.vertex_selected = PackedByteArray([0, 0, 0, 0, 0, 0, 0, 0])
	data.edge_selected = PackedByteArray()
	data.face_material_indices = PackedInt32Array([0, 0, 0, 0, 0, 0])
	data.face_uv_transform = []
	for _i: int in 6:
		data.face_uv_transform.append(Transform2D.IDENTITY)
	data.face_visible = PackedByteArray([1, 1, 1, 1, 1, 1])
	data.face_color = PackedColorArray(
		[Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE]
	)
	data.face_selected = PackedByteArray([0, 0, 0, 0, 0, 0])
	data.edge_vertex_indices = PackedInt32Array()
	data.edge_face_indices = PackedInt32Array()
	data.face_vertex_count = PackedInt32Array([4, 4, 4, 4, 4, 4])
	data.face_vertex_indices = PackedInt32Array(
		[0, 3, 2, 1, 4, 5, 6, 7, 0, 4, 7, 3, 1, 2, 6, 5, 0, 1, 5, 4, 3, 7, 6, 2]
	)
	var normals: PackedVector3Array = PackedVector3Array()
	for _i: int in 4:
		normals.append(Vector3(0, 0, -1))
	for _i: int in 4:
		normals.append(Vector3(0, 0, 1))
	for _i: int in 4:
		normals.append(Vector3(-1, 0, 0))
	for _i: int in 4:
		normals.append(Vector3(1, 0, 0))
	for _i: int in 4:
		normals.append(Vector3(0, -1, 0))
	for _i: int in 4:
		normals.append(Vector3(0, 1, 0))
	data.face_vertex_normal = normals
	return data
