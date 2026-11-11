extends Node3D
## Mundo base de la campaña 01.
##
## Compone el entorno atmosférico, el terreno procedural, la llacta, el jugador
## y el HUD.

const TERRAIN_SIZE: float = 150.0
const TERRAIN_RESOLUTION: int = 64
const PLATEAU_RADIUS: float = 55.0
const BOUNDARY_RADIUS: float = 70.0
const DEBUG_PROFILE_KEY: Key = KEY_F2
const AMBIENCE_PATH: String = "res://shared_assets/audio/ambience_wind_birds.ogg"
const FOOTSTEP_PATHS: Array[String] = [
	"res://shared_assets/audio/pasos_tierra_01.wav",
	"res://shared_assets/audio/pasos_tierra_02.wav",
	"res://shared_assets/audio/pasos_tierra_03.wav",
]

@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var sun: DirectionalLight3D = $Inti
@onready var terrain: Node3D = $Terrain
@onready var player_spawn: Marker3D = $PlayerSpawn
@onready var player: PlayerFPS = $PlayerFPS
@onready var hud: PlayerHud = $UILayer/HUD
@onready var environment_controller: EnvironmentQualityController = $EnvironmentQualityController


func _ready() -> void:
	_build_terrain()
	_build_llacta()
	player.global_position = player_spawn.global_position
	hud.bind(player, player.stamina)
	_setup_footsteps()
	environment_controller.bind(world_environment, sun)


func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if not (event is InputEventKey):
		return
	var key_event: InputEventKey = event as InputEventKey
	if key_event.pressed and not key_event.echo and key_event.keycode == DEBUG_PROFILE_KEY:
		GraphicsSettings.cycle_profile()
		get_viewport().set_input_as_handled()


func _build_terrain() -> void:
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var step: float = TERRAIN_SIZE / float(TERRAIN_RESOLUTION)
	var half: float = TERRAIN_SIZE * 0.5
	for zi: int in range(TERRAIN_RESOLUTION):
		for xi: int in range(TERRAIN_RESOLUTION):
			var x0: float = -half + step * float(xi)
			var z0: float = -half + step * float(zi)
			var x1: float = x0 + step
			var z1: float = z0 + step
			var p00: Vector3 = Vector3(x0, _height_at(x0, z0), z0)
			var p10: Vector3 = Vector3(x1, _height_at(x1, z0), z0)
			var p01: Vector3 = Vector3(x0, _height_at(x0, z1), z1)
			var p11: Vector3 = Vector3(x1, _height_at(x1, z1), z1)
			surface.add_vertex(p00)
			surface.add_vertex(p10)
			surface.add_vertex(p11)
			surface.add_vertex(p00)
			surface.add_vertex(p11)
			surface.add_vertex(p01)
	surface.generate_normals()
	var mesh: ArrayMesh = surface.commit()
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.35, 0.4, 0.22, 1.0)
	material.roughness = 1.0
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = "TerrainMesh"
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	terrain.add_child(mesh_instance)
	var body: StaticBody3D = StaticBody3D.new()
	body.name = "TerrainBody"
	body.collision_layer = 1
	body.collision_mask = 0
	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.name = "TerrainCollision"
	collision.shape = mesh.create_trimesh_shape()
	body.add_child(collision)
	terrain.add_child(body)


func _height_at(x: float, z: float) -> float:
	var distance: float = Vector2(x, z).length()
	var blend: float = clampf((distance - PLATEAU_RADIUS) / 15.0, 0.0, 1.0)
	var height: float = 0.7 * sin(x * 0.06) * cos(z * 0.07) + 0.3 * sin((x + z) * 0.11)
	return height * blend


func _build_llacta() -> void:
	var llacta: Node3D = $Llacta
	var boundary: Node3D = $Boundary
	var stone: StandardMaterial3D = StandardMaterial3D.new()
	stone.albedo_color = Color(0.48, 0.45, 0.4, 1.0)
	stone.roughness = 1.0
	var thatch: StandardMaterial3D = StandardMaterial3D.new()
	thatch.albedo_color = Color(0.55, 0.42, 0.2, 1.0)
	thatch.roughness = 1.0
	var dirt: StandardMaterial3D = StandardMaterial3D.new()
	dirt.albedo_color = Color(0.42, 0.34, 0.24, 1.0)
	dirt.roughness = 1.0

	_add_visual_box(llacta, "Plaza", Vector3(0.0, 0.03, 0.0), Vector3(26.0, 0.06, 26.0), dirt)
	_add_visual_box(llacta, "PathSouth", Vector3(0.0, 0.035, 30.0), Vector3(4.0, 0.07, 30.0), dirt)
	_add_visual_box(llacta, "PathNorth", Vector3(0.0, 0.035, -35.0), Vector3(4.0, 0.07, 30.0), dirt)
	_add_visual_box(llacta, "PathEast", Vector3(20.0, 0.035, 0.0), Vector3(30.0, 0.07, 4.0), dirt)
	_add_visual_box(llacta, "PathWest", Vector3(-20.0, 0.035, 0.0), Vector3(30.0, 0.07, 4.0), dirt)

	var houses: Node3D = Node3D.new()
	houses.name = "Houses"
	llacta.add_child(houses)
	# Tres grupos que dejan libres los ejes de los caminos: viviendas oeste,
	# viviendas este y las dos casas del camino norte.
	var positions: Array[Vector3] = [
		Vector3(-19.0, 0.0, 10.0),
		Vector3(-27.0, 0.0, 6.0),
		Vector3(-19.0, 0.0, -10.0),
		Vector3(19.0, 0.0, 10.0),
		Vector3(23.0, 0.0, 15.0),
		Vector3(19.0, 0.0, -10.0),
		Vector3(-9.0, 0.0, -21.0),
		Vector3(9.0, 0.0, -21.0),
	]
	for index: int in range(positions.size()):
		_add_house(houses, index, positions[index], stone, thatch)

	var terraces: Node3D = Node3D.new()
	terraces.name = "Terraces"
	llacta.add_child(terraces)
	_add_terrace(terraces, "Terrace01", 34.0, 0.0, 0.8, stone)
	_add_terrace(terraces, "Terrace02", 42.0, 0.8, 1.6, stone)
	_add_terrace(terraces, "Terrace03", 50.0, 1.6, 2.4, stone)

	_add_box_body(llacta, "PedestalQuero", Vector3(4.0, 0.4, 4.0), Vector3(0.6, 0.8, 0.6), stone, 1)
	_add_box_body(llacta, "PedestalPututu", Vector3(-4.0, 0.4, 4.0), Vector3(0.6, 0.8, 0.6), stone, 1)

	_add_box_body(boundary, "North", Vector3(0.0, 1.0, -BOUNDARY_RADIUS), Vector3(BOUNDARY_RADIUS * 2.0, 2.0, 1.0), stone, 1)
	_add_box_body(boundary, "South", Vector3(0.0, 1.0, BOUNDARY_RADIUS), Vector3(BOUNDARY_RADIUS * 2.0, 2.0, 1.0), stone, 1)
	_add_box_body(boundary, "East", Vector3(BOUNDARY_RADIUS, 1.0, 0.0), Vector3(1.0, 2.0, BOUNDARY_RADIUS * 2.0), stone, 1)
	_add_box_body(boundary, "West", Vector3(-BOUNDARY_RADIUS, 1.0, 0.0), Vector3(1.0, 2.0, BOUNDARY_RADIUS * 2.0), stone, 1)

	var npcs: Node3D = Node3D.new()
	npcs.name = "NPCs"
	llacta.add_child(npcs)
	var weaver: NpcActor = _add_npc(npcs, "Tejedora", Vector3(-11.0, 0.0, 5.0), Color(0.62, 0.38, 0.3, 1.0))
	var farmer: NpcActor = _add_npc(npcs, "Agricultor", Vector3(34.0, 0.8, -8.0), Color(0.45, 0.35, 0.25, 1.0))
	var messenger: NpcActor = _add_npc(npcs, "Mensajero", Vector3(0.0, 0.0, -60.0), Color(0.75, 0.65, 0.4, 1.0))
	messenger.walk_speed = 5.2
	var curaca: NpcActor = _add_npc(npcs, "Curaca", Vector3(-7.0, 0.0, -3.0), Color(0.72, 0.55, 0.45, 1.0))
	var principal_one: NpcActor = _add_npc(npcs, "Principal1", Vector3(-8.5, 0.0, -1.0), Color(0.55, 0.42, 0.32, 1.0))
	var principal_two: NpcActor = _add_npc(npcs, "Principal2", Vector3(-9.0, 0.0, 2.0), Color(0.5, 0.4, 0.3, 1.0))
	var neighbor_one: NpcActor = _add_npc(npcs, "Habitante1", Vector3(9.0, 0.0, 4.0), Color(0.48, 0.36, 0.28, 1.0))
	var neighbor_two: NpcActor = _add_npc(npcs, "Habitante2", Vector3(11.0, 0.0, -1.0), Color(0.42, 0.33, 0.26, 1.0))
	var neighbor_three: NpcActor = _add_npc(npcs, "Habitante3", Vector3(7.0, 0.0, 8.0), Color(0.52, 0.4, 0.3, 1.0))
	weaver.face(_plaza_center_flat())
	farmer.face(_plaza_center_flat())

	var event: MessengerEvent = $EventController as MessengerEvent
	var pututu: Pututu = $Pututu as Pututu
	var plaza_point: Marker3D = $PlazaPoint as Marker3D
	if event != null:
		var principals: Array[NpcActor] = [principal_one, principal_two]
		var neighbors: Array[NpcActor] = [neighbor_one, neighbor_two, neighbor_three]
		if not event.subtitle_requested.is_connected(_on_subtitle_requested):
			event.subtitle_requested.connect(_on_subtitle_requested)
		event.bind(player, plaza_point, messenger, curaca, principals, neighbors, pututu)
	_setup_ambience()


func _plaza_center_flat() -> Vector3:
	var plaza_point: Marker3D = $PlazaPoint as Marker3D
	if plaza_point == null:
		return Vector3.ZERO
	return plaza_point.global_position


func _on_subtitle_requested(text_key: StringName, seconds: float) -> void:
	if hud == null:
		return
	hud.show_subtitle(tr(String(text_key)), seconds)


func _setup_footsteps() -> void:
	# Con el driver «Dummy» de las pruebas sin pantalla las reproducciones no se
	# liberan; los pasos no son objeto de esas pruebas.
	if AudioServer.get_driver_name() == "Dummy":
		return
	var streams: Array[AudioStream] = []
	for path: String in FOOTSTEP_PATHS:
		if not ResourceLoader.exists(path):
			continue
		var stream: AudioStream = load(path) as AudioStream
		if stream != null:
			streams.append(stream)
	player.footstep_streams = streams


func _setup_ambience() -> void:
	if AudioServer.get_driver_name() == "Dummy":
		return
	if not ResourceLoader.exists(AMBIENCE_PATH):
		return
	var stream: AudioStream = load(AMBIENCE_PATH) as AudioStream
	if stream == null:
		return
	if stream is AudioStreamWAV:
		var wav: AudioStreamWAV = stream as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_end = roundi(wav.get_length() * float(wav.mix_rate))
	elif stream is AudioStreamOggVorbis:
		var ogg: AudioStreamOggVorbis = stream as AudioStreamOggVorbis
		ogg.loop = true
	var player_audio: AudioStreamPlayer = AudioStreamPlayer.new()
	player_audio.name = "WindAmbience"
	player_audio.stream = stream
	player_audio.volume_db = -16.0
	player_audio.autoplay = true
	$EnvironmentAudio.add_child(player_audio)



func _add_visual_box(parent: Node3D, node_name: String, at: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = node_name
	mesh_instance.position = at
	var box: BoxMesh = BoxMesh.new()
	box.size = size
	mesh_instance.mesh = box
	mesh_instance.material_override = material
	parent.add_child(mesh_instance)
	return mesh_instance


func _add_box_body(parent: Node3D, node_name: String, at: Vector3, size: Vector3, material: Material, layer: int) -> StaticBody3D:
	var body: StaticBody3D = StaticBody3D.new()
	body.name = node_name
	body.position = at
	body.collision_layer = layer
	body.collision_mask = 0
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var box_mesh: BoxMesh = BoxMesh.new()
	box_mesh.size = size
	mesh_instance.mesh = box_mesh
	mesh_instance.material_override = material
	body.add_child(mesh_instance)
	var collision: CollisionShape3D = CollisionShape3D.new()
	var box_shape: BoxShape3D = BoxShape3D.new()
	box_shape.size = size
	collision.shape = box_shape
	body.add_child(collision)
	parent.add_child(body)
	return body


func _add_terrace(parent: Node3D, node_name: String, center_x: float, bottom_y: float, top_y: float, material: Material) -> void:
	var height: float = top_y - bottom_y
	var center_y: float = bottom_y + height * 0.5
	_add_box_body(parent, node_name + "North", Vector3(center_x, center_y, -8.5), Vector3(8.0, height, 13.0), material, 1)
	_add_box_body(parent, node_name + "South", Vector3(center_x, center_y, 8.5), Vector3(8.0, height, 13.0), material, 1)
	_add_ramp(parent, node_name + "Ramp", Vector3(center_x - 4.0, bottom_y, 0.0), 8.0, height, 4.0, material)


## Rampa transitable entre dos niveles de terraza. El cuerpo gira sobre Z y la
## cara superior pasa por el punto de arranque.
func _add_ramp(parent: Node3D, node_name: String, start: Vector3, run: float, rise: float, width: float, material: Material) -> void:
	var angle: float = atan2(rise, run)
	var length: float = sqrt(run * run + rise * rise)
	var body: StaticBody3D = StaticBody3D.new()
	body.name = node_name
	body.position = start + Vector3(run * 0.5, rise * 0.5, 0.0)
	body.rotation = Vector3(0.0, 0.0, angle)
	body.collision_layer = 1
	body.collision_mask = 0
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var box_mesh: BoxMesh = BoxMesh.new()
	box_mesh.size = Vector3(length, 0.3, width)
	mesh_instance.mesh = box_mesh
	mesh_instance.material_override = material
	mesh_instance.position = Vector3(0.0, -0.15, 0.0)
	body.add_child(mesh_instance)
	var collision: CollisionShape3D = CollisionShape3D.new()
	var box_shape: BoxShape3D = BoxShape3D.new()
	box_shape.size = Vector3(length, 0.3, width)
	collision.shape = box_shape
	collision.position = Vector3(0.0, -0.15, 0.0)
	body.add_child(collision)
	parent.add_child(body)


func _add_house(parent: Node3D, index: int, at: Vector3, stone: Material, thatch: Material) -> void:
	var root: Node3D = Node3D.new()
	root.name = "House%02d" % (index + 1)
	root.position = at
	parent.add_child(root)
	root.look_at(Vector3(0.0, at.y, 0.0), Vector3.UP)
	_add_box_body(root, "Base", Vector3(0.0, 1.25, 0.0), Vector3(6.0, 2.5, 5.0), stone, 1)
	var roof: MeshInstance3D = MeshInstance3D.new()
	roof.name = "Roof"
	roof.position = Vector3(0.0, 3.25, 0.0)
	var prism: PrismMesh = PrismMesh.new()
	prism.size = Vector3(6.6, 1.5, 5.6)
	roof.mesh = prism
	roof.material_override = thatch
	root.add_child(roof)
	root.add_to_group("houses")


func _add_npc(parent: Node3D, node_name: String, at: Vector3, color: Color) -> NpcActor:
	var packed: PackedScene = load("res://campaigns/01_pachacutec/scenes/npcs/npc_actor.tscn") as PackedScene
	if packed == null:
		return null
	var actor: NpcActor = packed.instantiate() as NpcActor
	if actor == null:
		return null
	actor.name = node_name
	actor.position = at
	actor.body_color = color
	parent.add_child(actor)
	actor.add_to_group("npcs")
	return actor
