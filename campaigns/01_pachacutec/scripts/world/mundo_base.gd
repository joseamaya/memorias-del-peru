extends Node3D
## Mundo base de la campaña 01.
##
## Compone el entorno atmosférico, el terreno procedural, la llacta, el jugador
## y el HUD.

const TERRAIN_SIZE: float = 150.0
const TERRAIN_RESOLUTION: int = 64
const PLATEAU_RADIUS: float = 55.0
const BOUNDARY_RADIUS: float = 70.0
## Cresta del borde: el terreno sube entre RIDGE_START y RIDGE_FULL (distancia
## de Chebyshev al centro) hasta RIDGE_HEIGHT metros, con una pendiente que el
## jugador no puede subir. Los muros de BOUNDARY_RADIUS quedan como respaldo.
const RIDGE_START: float = 61.0
const RIDGE_FULL: float = 73.0
const RIDGE_HEIGHT: float = 11.0
## Paso abierto en la cresta norte, por donde llega el mensajero.
const PASS_HALF_WIDTH: float = 5.0
const PASS_EDGE: float = 12.0
const GRASS_COLOR: Color = Color(0.35, 0.4, 0.22, 1.0)
const ROCK_COLOR: Color = Color(0.46, 0.43, 0.38, 1.0)
const ROCK_FROM_HEIGHT: float = 1.0
const ROCK_FULL_HEIGHT: float = 4.0
const DEBUG_PROFILE_KEY: Key = KEY_F2
const AMBIENCE_PATH: String = "res://shared_assets/audio/ambience_wind_birds.ogg"
const FOOTSTEP_PATHS: Array[String] = [
	"res://shared_assets/audio/pasos_tierra_01.wav",
	"res://shared_assets/audio/pasos_tierra_02.wav",
	"res://shared_assets/audio/pasos_tierra_03.wav",
]
const STONE_FOOTSTEP_PATHS: Array[String] = [
	"res://shared_assets/audio/pasos_piedra_01.wav",
	"res://shared_assets/audio/pasos_piedra_02.wav",
	"res://shared_assets/audio/pasos_piedra_03.wav",
]
const MURMUR_PATH: String = "res://shared_assets/audio/murmullo_plaza.wav"
const MURMUR_VOLUME_DB: float = -8.0
const MURMUR_SILENT_DB: float = -40.0
const MURMUR_FADE_IN: float = 2.0
const MURMUR_FADE_OUT: float = 5.0
## Modelos definitivos (alcance §6.1 y §7). Cada bloqueo tiene un hueco que
## carga el primer archivo existente de su lista; sin archivo, sigue el bloqueo.
const MODEL_DIR: String = "res://campaigns/01_pachacutec/assets/models/"
const MODEL_HOUSES: Array[String] = ["pch_house_a.glb", "pch_house_b.glb"]
const MODEL_QUERO: String = "pch_quero.glb"
const MODEL_PUTUTU: String = "pch_pututu.glb"
const MODEL_OFFERING: String = "pch_offering_shrine.glb"
const MODEL_LOOM: String = "pch_loom.glb"
const MODEL_COMMONER: String = "pch_npc_commoner.glb"
const MODEL_AUTHORITY: String = "pch_npc_authority.glb"
## Base de cada malla de bloqueo de los objetos (su origen está en el centro).
const QUERO_BASE: Vector3 = Vector3(0.0, -0.11, 0.0)
const PUTUTU_BASE: Vector3 = Vector3(0.0, -0.2, 0.0)
const OFFERING_BASE: Vector3 = Vector3(0.0, -0.15, 0.0)
const LOOM_POSITION: Vector3 = Vector3(-10.0, 0.0, 6.2)
## Tapa del extremo alto de cada rampa: grosor y margen bajo la superficie.
const TERRACE_CAP_THICKNESS: float = 0.3
const TERRACE_CAP_INSET: float = 0.05
## Superficie de los muros y rampas de las terrazas.
const SURFACE_STONE: StringName = &"stone"

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
			for vertex: Vector3 in [p00, p10, p11, p00, p11, p01]:
				surface.set_color(_terrain_color(vertex.y))
				surface.add_vertex(vertex)
	surface.generate_normals()
	var mesh: ArrayMesh = surface.commit()
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color.WHITE
	material.vertex_color_use_as_albedo = true
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
	return height * blend + ridge_height_at(x, z)


## Altura añadida por la cresta del borde en (x, z); cero en el interior y en
## el paso norte.
static func ridge_height_at(x: float, z: float) -> float:
	var edge_distance: float = maxf(absf(x), absf(z))
	var rise: float = smoothstep(RIDGE_START, RIDGE_FULL, edge_distance)
	if rise <= 0.0:
		return 0.0
	var roughness: float = 1.0 + 0.18 * sin(x * 0.21) * cos(z * 0.17)
	var opening: float = 1.0
	if z < 0.0:
		opening = smoothstep(PASS_HALF_WIDTH, PASS_EDGE, absf(x))
	return RIDGE_HEIGHT * rise * roughness * opening


func _terrain_color(height: float) -> Color:
	var rock: float = smoothstep(ROCK_FROM_HEIGHT, ROCK_FULL_HEIGHT, height)
	return GRASS_COLOR.lerp(ROCK_COLOR, rock)


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

	# Ichu y queñua (PCH-013) fuera de la plaza, los caminos y las casas.
	var vegetation: LlactaVegetation = LlactaVegetation.new()
	vegetation.name = "Vegetation"
	llacta.add_child(vegetation)
	vegetation.build(_height_at, positions)

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
	_attach_object_models(llacta)

	var event: MessengerEvent = $EventController as MessengerEvent
	var pututu: Pututu = $Pututu as Pututu
	var plaza_point: Marker3D = $PlazaPoint as Marker3D
	if event != null:
		var principals: Array[NpcActor] = [principal_one, principal_two]
		var neighbors: Array[NpcActor] = [neighbor_one, neighbor_two, neighbor_three]
		if not event.subtitle_requested.is_connected(_on_subtitle_requested):
			event.subtitle_requested.connect(_on_subtitle_requested)
		if not event.phase_changed.is_connected(_on_event_phase_changed):
			event.phase_changed.connect(_on_event_phase_changed)
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


## Indica si el murmullo de la plaza debe sonar en una fase del evento: desde
## la noticia hasta que suena el pututu.
static func murmur_plays_in(phase: int) -> bool:
	return phase == MessengerEvent.Phase.MESSAGE or phase == MessengerEvent.Phase.CALL


func _on_event_phase_changed(phase: int) -> void:
	if murmur_plays_in(phase):
		_start_murmur()
	else:
		_stop_murmur()


func _start_murmur() -> void:
	var murmur: AudioStreamPlayer3D = $EnvironmentAudio.get_node_or_null("PlazaMurmur") as AudioStreamPlayer3D
	if murmur == null:
		murmur = _create_murmur()
	if murmur == null or murmur.playing:
		return
	murmur.volume_db = MURMUR_SILENT_DB
	murmur.play()
	var tween: Tween = murmur.create_tween()
	tween.tween_property(murmur, "volume_db", MURMUR_VOLUME_DB, MURMUR_FADE_IN)


func _stop_murmur() -> void:
	var murmur: AudioStreamPlayer3D = $EnvironmentAudio.get_node_or_null("PlazaMurmur") as AudioStreamPlayer3D
	if murmur == null or not murmur.playing:
		return
	var tween: Tween = murmur.create_tween()
	tween.tween_property(murmur, "volume_db", MURMUR_SILENT_DB, MURMUR_FADE_OUT)
	tween.tween_callback(murmur.stop)


func _create_murmur() -> AudioStreamPlayer3D:
	# Mismo motivo que el ambiente: el driver «Dummy» no libera reproducciones.
	if AudioServer.get_driver_name() == "Dummy":
		return null
	if not ResourceLoader.exists(MURMUR_PATH):
		return null
	var stream: AudioStreamWAV = load(MURMUR_PATH) as AudioStreamWAV
	if stream == null:
		return null
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = roundi(stream.get_length() * float(stream.mix_rate))
	var murmur: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	murmur.name = "PlazaMurmur"
	murmur.stream = stream
	murmur.unit_size = 12.0
	murmur.max_distance = 70.0
	$EnvironmentAudio.add_child(murmur)
	murmur.global_position = _plaza_center_flat() + Vector3(0.0, 1.5, -3.0)
	return murmur


func _setup_footsteps() -> void:
	# Con el driver «Dummy» de las pruebas sin pantalla las reproducciones no se
	# liberan; los pasos no son objeto de esas pruebas.
	if AudioServer.get_driver_name() == "Dummy":
		return
	player.footstep_streams = _load_streams(FOOTSTEP_PATHS)
	var stone: FootstepSet = FootstepSet.new()
	stone.surface = SURFACE_STONE
	stone.streams = _load_streams(STONE_FOOTSTEP_PATHS)
	var sets: Array[FootstepSet] = [stone]
	player.footstep_sets = sets


func _load_streams(paths: Array[String]) -> Array[AudioStream]:
	var streams: Array[AudioStream] = []
	for path: String in paths:
		if not ResourceLoader.exists(path):
			continue
		var stream: AudioStream = load(path) as AudioStream
		if stream != null:
			streams.append(stream)
	return streams


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


## Nivel de terraza: dos bloques macizos desde el suelo hasta [param top_y] a
## ambos lados de una rampa central que sube desde [param bottom_y]. Bajo la
## rampa, un relleno llega hasta [param bottom_y] y una tapa cierra su extremo
## alto, para que no quede hueco por el que meterse bajo la rampa.
func _add_terrace(parent: Node3D, node_name: String, center_x: float, bottom_y: float, top_y: float, material: Material) -> void:
	var bodies: Array[StaticBody3D] = []
	bodies.append(_add_box_body(parent, node_name + "North", Vector3(center_x, top_y * 0.5, -8.5), Vector3(8.0, top_y, 13.0), material, 1))
	bodies.append(_add_box_body(parent, node_name + "South", Vector3(center_x, top_y * 0.5, 8.5), Vector3(8.0, top_y, 13.0), material, 1))
	bodies.append(_add_ramp(parent, node_name + "Ramp", Vector3(center_x - 4.0, bottom_y, 0.0), 8.0, top_y - bottom_y, 4.0, material))
	if bottom_y > 0.0:
		bodies.append(_add_box_body(parent, node_name + "Fill", Vector3(center_x, bottom_y * 0.5, 0.0), Vector3(8.0, bottom_y, 4.0), material, 1))
	var cap_height: float = top_y - TERRACE_CAP_INSET
	bodies.append(_add_box_body(parent, node_name + "Cap", Vector3(center_x + 4.0 - TERRACE_CAP_THICKNESS * 0.5, cap_height * 0.5, 0.0), Vector3(TERRACE_CAP_THICKNESS, cap_height, 4.0), material, 1))
	for body: StaticBody3D in bodies:
		body.set_meta(PlayerFPS.FOOTSTEP_SURFACE_META, SURFACE_STONE)


## Rampa transitable entre dos niveles de terraza. El cuerpo gira sobre Z y la
## cara superior pasa por el punto de arranque.
func _add_ramp(parent: Node3D, node_name: String, start: Vector3, run: float, rise: float, width: float, material: Material) -> StaticBody3D:
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
	return body


func _add_house(parent: Node3D, index: int, at: Vector3, stone: Material, thatch: Material) -> void:
	var root: Node3D = Node3D.new()
	root.name = "House%02d" % (index + 1)
	root.position = at
	parent.add_child(root)
	root.look_at(Vector3(0.0, at.y, 0.0), Vector3.UP)
	var base: StaticBody3D = _add_box_body(root, "Base", Vector3(0.0, 1.25, 0.0), Vector3(6.0, 2.5, 5.0), stone, 1)
	var roof: MeshInstance3D = MeshInstance3D.new()
	roof.name = "Roof"
	roof.position = Vector3(0.0, 3.25, 0.0)
	var prism: PrismMesh = PrismMesh.new()
	prism.size = Vector3(6.6, 1.5, 5.6)
	roof.mesh = prism
	roof.material_override = thatch
	root.add_child(roof)
	root.add_to_group("houses")
	var blockout: Array[Node3D] = [roof]
	var collisions: Array[Node] = []
	for child: Node in base.get_children():
		if child is MeshInstance3D:
			blockout.append(child as MeshInstance3D)
		elif child is CollisionShape3D:
			collisions.append(child)
	var files: Array[String] = [MODEL_HOUSES[index % MODEL_HOUSES.size()]]
	_attach_model(root, "ModelSlot", Vector3.ZERO, files, blockout, collisions)


## Archivos candidatos para un personaje: primero el de su papel
## (`pch_npc_<papel>.glb`), luego la variante común o de autoridad.
static func npc_model_files(node_name: String) -> Array[String]:
	var role: String = "villager"
	var generic: String = MODEL_COMMONER
	match node_name:
		"Tejedora":
			role = "weaver"
		"Agricultor":
			role = "farmer"
		"Mensajero":
			role = "messenger"
		"Curaca":
			role = "curaca"
			generic = MODEL_AUTHORITY
		"Principal1", "Principal2":
			role = "principal"
			generic = MODEL_AUTHORITY
	var files: Array[String] = ["pch_npc_%s.glb" % role, generic]
	return files


## Crea un hueco de modelo bajo [param parent]. Las listas se fijan antes de
## añadirlo al árbol para que cargue en su _ready().
func _attach_model(parent: Node3D, slot_name: String, at: Vector3, files: Array[String], blockout: Array[Node3D], collisions: Array[Node]) -> ModelSlot:
	var slot: ModelSlot = ModelSlot.new()
	slot.name = slot_name
	slot.position = at
	var paths: Array[String] = []
	for file: String in files:
		paths.append(MODEL_DIR + file)
	slot.model_paths = paths
	slot.blockout_nodes = blockout
	slot.blockout_collisions = collisions
	parent.add_child(slot)
	return slot


func _attach_object_models(llacta: Node3D) -> void:
	var targets: Array[Array] = [
		[$QueroChicha, MODEL_QUERO, QUERO_BASE],
		[$Pututu, MODEL_PUTUTU, PUTUTU_BASE],
		[$OfrendaPachamama, MODEL_OFFERING, OFFERING_BASE],
	]
	for target: Array in targets:
		var object_root: Node = target[0]
		var mesh: MeshInstance3D = object_root.get_node_or_null("MeshInstance3D") as MeshInstance3D
		if mesh == null:
			continue
		var file: String = target[1]
		var base: Vector3 = target[2]
		# El hueco cuelga de la malla para heredar las animaciones de respuesta.
		var files: Array[String] = [file]
		var blockout: Array[Node3D] = [mesh]
		var no_collisions: Array[Node] = []
		_attach_model(mesh, "ModelSlot", base, files, blockout, no_collisions)
	var loom_files: Array[String] = [MODEL_LOOM]
	var nothing: Array[Node3D] = []
	var no_loom_collisions: Array[Node] = []
	_attach_model(llacta, "LoomSlot", LOOM_POSITION, loom_files, nothing, no_loom_collisions)


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
	var body_mesh: MeshInstance3D = actor.get_node_or_null("Body") as MeshInstance3D
	var blockout: Array[Node3D] = []
	if body_mesh != null:
		blockout.append(body_mesh)
	# La cápsula de colisión del bloqueo se conserva (alcance §7).
	var no_collisions: Array[Node] = []
	var slot: ModelSlot = _attach_model(actor, "ModelSlot", Vector3.ZERO, npc_model_files(node_name), blockout, no_collisions)
	slot.use_model_collision = false
	return actor
