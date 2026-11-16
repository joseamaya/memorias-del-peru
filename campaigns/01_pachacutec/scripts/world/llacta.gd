class_name Llacta
extends Node3D
## Mundo del acto I: la llacta del valle.
##
## Compone el terreno, el cielo, las viviendas, las terrazas, los corrales, el
## jugador y el HUD. El contenido narrativo (familia, encargos, mensajero y
## asamblea) se añade en las misiones del acto.

const TERRAIN_SIZE: float = 150.0
const TERRAIN_RESOLUTION: int = 96
const PLATEAU_RADIUS: float = 55.0
const BOUNDARY_RADIUS: float = 70.0
const RIDGE_START: float = 61.0
const RIDGE_FULL: float = 73.0
const RIDGE_HEIGHT: float = 11.0
const PASS_HALF_WIDTH: float = 5.0
const PASS_EDGE: float = 12.0
const RELIEF_AMPLITUDE: float = 1.3
const RELIEF_START: float = 30.0
const RELIEF_FULL: float = 42.0
const TERRACE_ZONE: Rect2 = Rect2(26.0, -19.0, 32.0, 38.0)
const RELIEF_EDGE: float = 8.0
const PATH_CLEAR: float = 4.0
const PATH_BLEND: float = 9.0
const GRASS_COLOR: Color = Color(0.50, 0.49, 0.34, 1.0)
const ROCK_COLOR: Color = Color(0.46, 0.44, 0.42, 1.0)
const DIRT_COLOR: Color = Color(0.49, 0.43, 0.36, 1.0)
const ROCK_FROM_HEIGHT: float = 1.0
const ROCK_FULL_HEIGHT: float = 4.0
const CLOUD_SHADER_PATH: String = "res://shared_assets/materials/nubes.gdshader"
const CLOUD_DOME_RADIUS: float = 420.0
const CLOUD_DOME_SEGMENTS: int = 64
const CLOUD_DOME_RINGS: int = 32
const DISTANT_NEAR_INNER: float = 100.0
const DISTANT_NEAR_OUTER: float = 250.0
const DISTANT_NEAR_AMPLITUDE: float = 72.0
const DISTANT_NEAR_COLOR: Color = Color(0.35, 0.38, 0.43, 1.0)
const DISTANT_MID_INNER: float = 190.0
const DISTANT_MID_OUTER: float = 340.0
const DISTANT_MID_AMPLITUDE: float = 110.0
const DISTANT_MID_COLOR: Color = Color(0.39, 0.43, 0.49, 1.0)
const DISTANT_FAR_INNER: float = 280.0
const DISTANT_FAR_OUTER: float = 470.0
const DISTANT_FAR_AMPLITUDE: float = 130.0
const DISTANT_FAR_COLOR: Color = Color(0.42, 0.46, 0.52, 1.0)

const AMBIENCE_PATH: String = "res://shared_assets/audio/ambiente_viento_andes.ogg"
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
const SURFACE_STONE: StringName = &"stone"

const MODEL_DIR: String = "res://campaigns/01_pachacutec/assets/models/"
const MODEL_HOUSES: Array[String] = [
	"pch_house_a.glb", "pch_house_b.glb", "pch_house_c.glb", "pch_house_d.glb", "pch_house_e.glb",
]
## Elenco del acto I: modelos con esqueleto, animaciones y ropa propios.
const CHARACTER_MODELS: Dictionary[String, String] = {
	"Tejedora": "pch_npc_weaver.glb",
	"Agricultor": "pch_npc_farmer.glb",
	"Curaca": "pch_npc_curaca.glb",
	"Principal2": "pch_npc_principal.glb",
	"Habitante1": "pch_npc_villager.glb",
	"Habitante2": "pch_npc_villager_b.glb",
	"Habitante3": "pch_npc_villager_c.glb",
	"Anca": "pch_npc_villager_b.glb",
	"Mensajero": "pch_npc_messenger.glb",
	"HijoPuma": "pch_npc_villager_c.glb",
	"CuracaVecino": "pch_npc_curaca.glb",
	"Herido1": "pch_npc_villager.glb",
	"Herido2": "pch_npc_villager_b.glb",
	"Comitiva1": "pch_npc_villager.glb",
	"Comitiva2": "pch_npc_villager_b.glb",
	"Comitiva3": "pch_npc_villager_c.glb",
}
## Altura visible de cada papel, en metros.
const CHARACTER_HEIGHTS: Dictionary[String, float] = {
	"Curaca": 1.65,
	"Principal2": 1.63,
	"Tejedora": 0.0,
	"Agricultor": 1.57,
	"Habitante1": 1.53,
	"Habitante2": 1.56,
	"Habitante3": 1.50,
	"Anca": 1.58,
	"Mensajero": 1.60,
	"HijoPuma": 1.55,
	"CuracaVecino": 1.64,
	"Herido1": 1.52,
	"Herido2": 1.55,
	"Comitiva1": 1.56,
	"Comitiva2": 1.58,
	"Comitiva3": 1.54,
}
const NPC_SCENE: String = "res://campaigns/01_pachacutec/scenes/npcs/npc_actor.tscn"
## Rótulo del personaje cuando habla por un [TalkPoint]. Los nombres de los
## personajes ficticios viven en la tabla de localización.
const NPC_NAME_KEYS: Dictionary[String, StringName] = {
	"Habitante1": &"PCH_NAME_MADRE",
	"Habitante2": &"PCH_NAME_HERMANO",
	"Habitante3": &"PCH_NPC_SISA",
	"Curaca": &"PCH_NPC_CURACA",
	"Principal2": &"PCH_NPC_PUMA",
	"HijoPuma": &"PCH_NAME_HIJO_PUMA",
	"Tejedora": &"PCH_NPC_WEAVER",
	"Agricultor": &"PCH_NPC_FARMER",
	"Anca": &"PCH_NPC_ANCA",
	"CuracaVecino": &"PCH_NPC_CURACA_VECINO",
	"Herido1": &"PCH_NAME_WOUNDED",
	"Herido2": &"PCH_NAME_WOUNDED",
}
const MODEL_LOOM: String = "pch_loom.glb"
const FIRE_PIT_POSITION: Vector3 = Vector3(-6.0, 0.0, 7.0)
const LOOM_POSITION: Vector3 = Vector3(-10.0, 0.0, 6.2)
const TASK_SCENE: String = "res://campaigns/01_pachacutec/scenes/objects/task_point.tscn"
const CAMP_SCENE: String = "res://campaigns/01_pachacutec/scenes/objects/camp_point.tscn"
const TASK_IDS: Array[StringName] = [&"agua", &"maiz", &"telar", &"pirca"]
const TASK_PROMPTS: Array[StringName] = [
	&"PCH_TASK_AGUA", &"PCH_TASK_MAIZ", &"PCH_TASK_TELAR", &"PCH_TASK_PIRCA",
]
const TASK_DONE_KEYS: Array[StringName] = [
	&"PCH_TASK_AGUA_DONE", &"PCH_TASK_MAIZ_DONE", &"PCH_TASK_TELAR_DONE", &"PCH_TASK_PIRCA_DONE",
]
const TASK_ITEM_IDS: Array[StringName] = [&"agua", &"maiz", &"manta", &"cuerda"]
const TASK_ITEM_KEYS: Array[StringName] = [
	&"PCH_ITEM_AGUA", &"PCH_ITEM_MAIZ", &"PCH_ITEM_MANTA", &"PCH_ITEM_CUERDA",
]
## Casas que se visitan en IV.2: este, oeste y sur de la plaza. La casa del
## este es la quinta vivienda: la cuarta es el hogar de Rumi.
const ACCOUNT_HOUSES: Array[int] = [4, 0, 7]
## Posición de respaldo delante de cada casa; se recalcula desde el nodo real
## para respetar giro y escala.
const ACCOUNT_POSITIONS: Array[Vector3] = [
	Vector3(21.5, 0.9, 10.5),
	Vector3(-15.0, 0.9, 9.8),
	Vector3(8.6, 0.9, -17.0),
]
const ACCOUNT_PROMPTS: Array[StringName] = [
	&"PCH_ACCOUNT_1", &"PCH_ACCOUNT_2", &"PCH_ACCOUNT_3",
]
const ACCOUNT_TEXTS: Array[StringName] = [
	&"PCH_ACCOUNT_1_TEXT", &"PCH_ACCOUNT_2_TEXT", &"PCH_ACCOUNT_3_TEXT",
]
const TASK_POSITIONS: Array[Vector3] = [
	Vector3(14.0, 0.0, 8.0),
	Vector3(-16.0, 0.0, 8.0),
	Vector3(-8.6, 0.0, 6.2),
	Vector3(-27.5, 0.0, -12.0),
]
const TASK_MODELS: Array[String] = ["pch_prop_jar.glb", "pch_prop_jar.glb", "", ""]
const TASKS_REQUIRED: int = 3
const TALK_SCENE: String = "res://campaigns/01_pachacutec/scenes/npcs/talk_point.tscn"
const TALK_HOLD_SECONDS: float = 7.0
const MODEL_PROP_JAR: String = "pch_prop_jar.glb"
const MODEL_PROP_FIREWOOD: String = "pch_prop_firewood.glb"
const HOUSE_DEPTHS: Array[float] = [5.0, 4.6, 4.0, 5.4, 3.8]
const HOUSE_LEFT_PROP_X: Array[float] = [-2.1, -2.4, -1.7, -2.5, -1.5]
const HOUSE_YAW_JITTER: Array[float] = [7.0, -11.0, 4.0, -6.0, 10.0, -8.0, 5.0, -4.0]
const PROP_WALL_GAP: float = 0.45
## Casa de Rumi: la cuarta vivienda, al este de la plaza (biblia §2.1). Su
## fachada mira a la plaza y la cámara de cierre tiene el camino despejado.
const HOME_HOUSE_INDEX: int = 3
const HOME_DOOR_OFFSET: float = 3.5

const CORRALS: Array[Array] = [
	[Vector3(-31.0, 0.0, -12.0), Vector2(7.0, 5.5), Vector3.RIGHT],
	[Vector3(-24.0, 0.0, -27.0), Vector2(6.0, 5.0), Vector3.BACK],
]
const CORRAL_WALL_HEIGHT: float = 1.0
const CORRAL_WALL_THICKNESS: float = 0.5
const CORRAL_ENTRANCE: float = 1.4
const CORRAL_SINK: float = 0.35

const TERRACE_CAP_THICKNESS: float = 0.3
const TERRACE_CAP_INSET: float = 0.05
const TERRACE_MORTAR_COLOR: Color = Color(0.24, 0.22, 0.2, 1.0)
const RAMP_COLOR: Color = Color(0.62, 0.56, 0.47, 1.0)
const FIELD_SOIL_COLOR: Color = Color(0.42, 0.32, 0.23, 1.0)
const FIELD_RIDGE_COLOR: Color = Color(0.52, 0.4, 0.28, 1.0)
const FIELD_FURROW_SPACING: float = 0.55
const FIELD_RIDGE_HEIGHT: float = 0.09
const FIELD_LIFT: float = 0.02
const FIELD_MARGIN: float = 0.25

@onready var player: PlayerFPS = $PlayerFPS as PlayerFPS
@onready var hud: PlayerHud = $UILayer/HUD as PlayerHud
@onready var terrain: Node3D = $Terrain as Node3D
@onready var world_environment: WorldEnvironment = $WorldEnvironment as WorldEnvironment
@onready var sun: DirectionalLight3D = $Inti as DirectionalLight3D
@onready var environment_controller: EnvironmentQualityController = $EnvironmentQualityController as EnvironmentQualityController

var character: CharacterState = null
var inventory: Inventory = null
var journal: Journal = null
var dialogue: DialogueRunner = null
var _tasks_done: Dictionary[StringName, bool] = {}
var _oficio: StringName = &""
var _curaca: NpcActor = null
var _puma: NpcActor = null
var _messenger_actor: NpcActor = null
var _assembly_started: bool = false
var _assembly_done: bool = false
var _assembly_choice: StringName = &""
var _assembly_speaker_key: StringName = &""
var _messenger_seen: bool = false
var _messenger_spawned: bool = false
var _duda_started: bool = false
var _accounts_done: Dictionary[StringName, bool] = {}
var _act_four_done: bool = false
var _act_five_done: bool = false
var _rebuild_done: Dictionary[StringName, bool] = {}
var _five_done_keys: Array[StringName] = []
var _home_absence_nodes: Array[Node3D] = []
var _dialogue_speaker: StringName = &""
var _dialogue_text: StringName = &""
var _dialogue_choices: Array[StringName] = []

## Acto que representa la escena: 1, 4 o 5.
@export var act: int = 1


func _ready() -> void:
	if SessionLog.is_active():
		var session_profile: GraphicsProfile = GraphicsSettings.get_active_profile()
		if session_profile != null:
			SessionLog.mark(&"profile", session_profile.profile_name)
	_build_terrain()
	_build_ground_clutter()
	_build_llacta()
	_build_cast()
	_build_distant_ranges()
	_build_clouds()
	_build_dust()
	player.global_position = _spawn_position()
	hud.bind(player, player.stamina)
	_setup_rpg()
	_setup_dialogue_ui()
	match act:
		1:
			_setup_act_one()
			hud.show_objective(tr("PCH_OBJ_LLACTA"))
		4:
			_setup_act_four()
		5:
			_setup_act_five()
			hud.show_objective(tr("PCH_OBJ_REBUILD"))
	if act == 1 and not CampaignState.has_flag(&"intro_vista"):
		_show_intro()
	_setup_footsteps()
	_setup_ambience()
	environment_controller.bind(world_environment, sun)
	_apply_act_mood()
	CampaignProgress.save_checkpoint(self, player.global_position)
	SessionLog.mark(&"act", _act_slug())
	SessionLog.mark(&"control_taken")


## Identificador del acto en el registro de sesión, para medir su duración.
func _act_slug() -> String:
	match act:
		4:
			return "posguerra"
		5:
			return "obra"
		_:
			return "llacta"


## Punto de aparición: el de la escena, salvo que `--spawn=<punto>` pida otro.
func _spawn_position() -> Vector3:
	for arg: String in OS.get_cmdline_user_args():
		if not arg.begins_with("--spawn="):
			continue
		var mode: String = arg.substr("--spawn=".length())
		if mode == "plaza":
			return Vector3(0.0, 1.0, 4.0)
		if mode == "mirador":
			return Vector3(52.0, 2.45, 0.0)
	var spawn: Marker3D = get_node_or_null("PlayerSpawn") as Marker3D
	if spawn != null:
		return spawn.global_position
	return Vector3(0.0, 0.05, 12.0)


func _setup_rpg() -> void:
	character = CharacterState.new()
	character.name = "CharacterState"
	player.add_child(character)
	inventory = Inventory.new()
	inventory.name = "Inventory"
	player.add_child(inventory)
	journal = Journal.new()
	journal.name = "Journal"
	player.add_child(journal)
	dialogue = DialogueRunner.new()
	dialogue.name = "DialogueRunner"
	dialogue.character = character
	dialogue.inventory = inventory
	player.add_child(dialogue)
	CampaignProgress.apply(self)
	if CampaignProgress.is_respawn_pending():
		CampaignProgress.restore_checkpoint(self)


## Oficio elegido con el primer encargo.
func get_oficio() -> StringName:
	return _oficio


## Restaura el oficio desde el estado de campaña.
func set_oficio(oficio: StringName) -> void:
	_oficio = oficio


## Terreno del valle: meseta plana en la llacta, lomas fuera y cresta en el
## borde. La colisión es una malla trimesh.
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
				surface.add_vertex(vertex)
	surface.generate_normals()
	var mesh: ArrayMesh = surface.commit()
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = "TerrainMesh"
	mesh_instance.mesh = mesh
	var material: ShaderMaterial = SurfaceMaterials.terrain_material(GRASS_COLOR, ROCK_COLOR, DIRT_COLOR)
	material.set_shader_parameter("steep_height_range", Vector2(ROCK_FROM_HEIGHT, ROCK_FULL_HEIGHT))
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
	return height * blend + relief_height_at(x, z) + ridge_height_at(x, z)


func _build_ground_clutter() -> void:
	var clutter: GroundClutter = GroundClutter.new()
	clutter.name = "GroundClutter"
	add_child(clutter)
	clutter.build(_height_at, Vector3.ZERO, 78.0, 8.0)


func _build_clouds() -> void:
	if not ResourceLoader.exists(CLOUD_SHADER_PATH):
		return
	var shader: Shader = load(CLOUD_SHADER_PATH) as Shader
	if shader == null:
		return
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = shader
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = CLOUD_DOME_RADIUS
	sphere.height = CLOUD_DOME_RADIUS * 2.0
	sphere.radial_segments = CLOUD_DOME_SEGMENTS
	sphere.rings = CLOUD_DOME_RINGS
	var dome: MeshInstance3D = MeshInstance3D.new()
	dome.name = "CloudDome"
	dome.mesh = sphere
	dome.material_override = material
	dome.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	dome.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	add_child(dome)


func _build_dust() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.name = "Dust"
	particles.amount = 160
	particles.lifetime = 10.0
	particles.preprocess = 5.0
	particles.local_coords = false
	particles.visibility_aabb = AABB(Vector3(-34.0, -2.0, -34.0), Vector3(68.0, 18.0, 68.0))
	var process: ParticleProcessMaterial = ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process.emission_box_extents = Vector3(24.0, 3.0, 24.0)
	process.direction = Vector3(0.25, 0.05, -0.1)
	process.spread = 40.0
	process.initial_velocity_min = 0.03
	process.initial_velocity_max = 0.14
	process.gravity = Vector3(0.0, -0.01, 0.0)
	process.scale_min = 0.5
	process.scale_max = 1.2
	process.color = Color(1.0, 0.94, 0.82, 1.0)
	var gradient: Gradient = Gradient.new()
	gradient.set_color(0, Color(1.0, 1.0, 1.0, 1.0))
	gradient.set_color(1, Color(1.0, 1.0, 1.0, 0.0))
	var texture: GradientTexture2D = GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = 32
	texture.height = 32
	var mesh: QuadMesh = QuadMesh.new()
	mesh.size = Vector2(0.06, 0.06)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.albedo_texture = texture
	material.albedo_color = Color(1.0, 0.96, 0.88, 0.16)
	material.disable_receive_shadows = true
	mesh.material = material
	particles.draw_pass_1 = mesh
	particles.process_material = process
	particles.position = Vector3(0.0, 4.0, 0.0)
	particles.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(particles)


func _build_distant_ranges() -> void:
	_build_range("DistantRangeNear", DISTANT_NEAR_INNER, DISTANT_NEAR_OUTER,
		DISTANT_NEAR_AMPLITUDE, 1.0, DISTANT_NEAR_COLOR)
	_build_range("DistantRangeMid", DISTANT_MID_INNER, DISTANT_MID_OUTER,
		DISTANT_MID_AMPLITUDE, 2.0, DISTANT_MID_COLOR)
	_build_range("DistantRangeFar", DISTANT_FAR_INNER, DISTANT_FAR_OUTER,
		DISTANT_FAR_AMPLITUDE, 3.0, DISTANT_FAR_COLOR)


## Construye una banda de montaña con volumen (ver [DistantRange]).
func _build_range(node_name: String, inner: float, outer: float, amplitude: float,
		seed_value: float, color: Color) -> void:
	DistantRange.build(self, node_name, inner, outer, amplitude, seed_value, color,
		_sun_direction())


func _sun_direction() -> Vector3:
	var direction: Vector3 = Vector3(0.3, 0.8, 0.5).normalized()
	if sun != null:
		direction = sun.global_transform.basis.z.normalized()
	return direction


static func relief_height_at(x: float, z: float) -> float:
	var mask: float = smoothstep(RELIEF_START, RELIEF_FULL, Vector2(x, z).length())
	if mask <= 0.0:
		return 0.0
	var outside_x: float = maxf(maxf(TERRACE_ZONE.position.x - x, x - TERRACE_ZONE.end.x), 0.0)
	var outside_z: float = maxf(maxf(TERRACE_ZONE.position.y - z, z - TERRACE_ZONE.end.y), 0.0)
	mask *= smoothstep(0.0, RELIEF_EDGE, maxf(outside_x, outside_z))
	mask *= smoothstep(PATH_CLEAR, PATH_BLEND, absf(x))
	mask *= maxf(smoothstep(PATH_CLEAR, PATH_BLEND, absf(z)), smoothstep(36.0, 42.0, absf(x)))
	if mask <= 0.0:
		return 0.0
	var wave: float = 0.6 * sin(x * 0.09 + 1.3) * cos(z * 0.08 - 0.4) + 0.4 * sin((x - z) * 0.15 + 0.7)
	return RELIEF_AMPLITUDE * mask * (wave + 0.35)


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


func _build_llacta() -> void:
	var llacta: Node3D = $Llacta as Node3D
	var boundary: Node3D = $Boundary as Node3D
	var stone: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.STONE, Color(0.56, 0.54, 0.50, 1.0))
	var thatch: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.THATCH, Color(0.50, 0.40, 0.22, 1.0))
	var dirt: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.DIRT, DIRT_COLOR)

	var ground_areas: Array[MeshInstance3D] = [
		_add_visual_box(llacta, "Plaza", Vector3(0.0, 0.03, 0.0), Vector3(26.0, 0.06, 26.0), dirt),
		_add_visual_box(llacta, "PathSouth", Vector3(0.0, 0.035, 30.0), Vector3(4.0, 0.07, 30.0), dirt),
		_add_visual_box(llacta, "PathNorth", Vector3(0.0, 0.035, -35.0), Vector3(4.0, 0.07, 30.0), dirt),
		_add_visual_box(llacta, "PathEast", Vector3(24.0, 0.035, 0.0), Vector3(22.0, 0.07, 4.0), dirt),
		_add_visual_box(llacta, "PathWest", Vector3(-24.0, 0.035, 0.0), Vector3(22.0, 0.07, 4.0), dirt),
	]
	for area: MeshInstance3D in ground_areas:
		area.visible = false
	var terrain_mesh: MeshInstance3D = terrain.get_node_or_null("TerrainMesh") as MeshInstance3D
	if terrain_mesh != null and terrain_mesh.material_override is ShaderMaterial:
		SurfaceMaterials.set_overlay_areas(terrain_mesh.material_override as ShaderMaterial, ground_areas)

	var houses: Node3D = Node3D.new()
	houses.name = "Houses"
	llacta.add_child(houses)
	var positions: Array[Vector3] = [
		Vector3(-18.0, 0.0, 11.0),
		Vector3(-27.0, 0.0, 6.0),
		Vector3(-20.0, 0.0, -9.0),
		Vector3(20.0, 0.0, 9.0),
		Vector3(24.0, 0.0, 14.0),
		Vector3(18.0, 0.0, -11.0),
		Vector3(-8.0, 0.0, -22.0),
		Vector3(10.0, 0.0, -20.0),
	]
	for index: int in range(positions.size()):
		_add_house(houses, index, positions[index], stone, thatch)

	# Ichu y queñua (PCH-013) fuera de la plaza, los caminos y las casas.
	var vegetation: LlactaVegetation = LlactaVegetation.new()
	vegetation.name = "Vegetation"
	llacta.add_child(vegetation)
	vegetation.build(_height_at, positions)
	var wind: LlactaWind = LlactaWind.new()
	wind.name = "Wind"
	wind.materials = vegetation.wind_materials
	add_child(wind)

	_add_community_fire(llacta)
	var corrals: Node3D = Node3D.new()
	corrals.name = "Corrals"
	llacta.add_child(corrals)
	for index: int in range(CORRALS.size()):
		var corral: Array = CORRALS[index]
		var corral_center: Vector3 = corral[0]
		var corral_size: Vector2 = corral[1]
		var corral_entrance: Vector3 = corral[2]
		_add_corral(corrals, "Corral%02d" % (index + 1), corral_center, corral_size, corral_entrance)

	var terraces: Node3D = Node3D.new()
	terraces.name = "Terraces"
	llacta.add_child(terraces)
	_add_terrace(terraces, "Terrace01", 34.0, 0.0, 0.8, stone)
	_add_terrace(terraces, "Terrace02", 42.0, 0.8, 1.6, stone)
	_add_terrace(terraces, "Terrace03", 50.0, 1.6, 2.4, stone, true)

	for pedestal: StaticBody3D in [
		_add_box_body(llacta, "PedestalQuero", Vector3(4.0, 0.4, 4.0), Vector3(0.6, 0.8, 0.6), stone, 1),
	]:
		_attach_pedestal(pedestal)

	_add_box_body(boundary, "North", Vector3(0.0, 1.0, -BOUNDARY_RADIUS), Vector3(BOUNDARY_RADIUS * 2.0, 2.0, 1.0), stone, 1)
	_add_box_body(boundary, "South", Vector3(0.0, 1.0, BOUNDARY_RADIUS), Vector3(BOUNDARY_RADIUS * 2.0, 2.0, 1.0), stone, 1)
	_add_box_body(boundary, "East", Vector3(BOUNDARY_RADIUS, 1.0, 0.0), Vector3(1.0, 2.0, BOUNDARY_RADIUS * 2.0), stone, 1)
	_add_box_body(boundary, "West", Vector3(-BOUNDARY_RADIUS, 1.0, 0.0), Vector3(1.0, 2.0, BOUNDARY_RADIUS * 2.0), stone, 1)


## Elenco del acto I: familia, autoridad y la voz que duda.
func _build_cast() -> void:
	var npcs: Node3D = Node3D.new()
	npcs.name = "NPCs"
	($Llacta as Node3D).add_child(npcs)
	var mother: NpcActor = _add_npc(npcs, "Habitante1",
		_home_family_position(1.0), Color(0.48, 0.36, 0.28, 1.0))
	var sibling: NpcActor = _add_npc(npcs, "Habitante2",
		_home_family_position(-1.0), Color(0.42, 0.33, 0.26, 1.0))
	var sisa: NpcActor = _add_npc(npcs, "Habitante3", Vector3(7.0, 0.0, 8.0), Color(0.52, 0.4, 0.3, 1.0))
	var curaca: NpcActor = _add_npc(npcs, "Curaca", Vector3(-7.0, 0.0, -3.0), Color(0.72, 0.55, 0.45, 1.0))
	_curaca = curaca
	var puma: NpcActor = _add_npc(npcs, "Principal2", Vector3(-8.6, 0.0, 0.7), Color(0.5, 0.4, 0.3, 1.0))
	_puma = puma
	var puma_son: NpcActor = _add_npc(npcs, "HijoPuma", Vector3(-6.2, 0.0, 1.8), Color(0.46, 0.36, 0.28, 1.0))
	if act == 4:
		var vecino: NpcActor = _add_npc(npcs, "CuracaVecino", Vector3(5.2, 0.0, -2.2), Color(0.66, 0.5, 0.4, 1.0))
		if vecino != null:
			vecino.watch_target = player
			_add_talk(vecino, &"PCH_TALK_VECINO_4")
	var weaver: NpcActor = _add_npc(npcs, "Tejedora", Vector3(-10.0, 0.0, 6.2), Color(0.62, 0.38, 0.3, 1.0))
	var farmer: NpcActor = _add_npc(npcs, "Agricultor", Vector3(36.5, 0.8, -3.0), Color(0.45, 0.35, 0.25, 1.0))
	for actor: Node in npcs.get_children():
		(actor as NpcActor).watch_target = player
	if weaver != null:
		weaver.turn_body_to_talk = false
		var weaver_player: AnimationPlayer = weaver.animation_player()
		weaver.set_idle_animation(&"weave" if weaver_player != null and weaver_player.has_animation(&"weave") else &"idle")
		weaver.face(_plaza_center_flat(), true)
	if farmer != null:
		farmer.face(_plaza_center_flat(), true)
		farmer.set_idle_animation(&"work")
	var nothing: Array[Node3D] = []
	var no_collisions: Array[Node] = []
	var loom_files: Array[String] = [MODEL_LOOM]
	var loom_slot: ModelSlot = _attach_model($Llacta as Node3D, "LoomSlot", LOOM_POSITION, loom_files, nothing, no_collisions)
	loom_slot.transform = loom_transform()
	var lines: Dictionary[String, StringName] = {
		"mother": &"PCH_TALK_MADRE",
		"sibling": &"PCH_TALK_HERMANO",
		"sisa": &"PCH_TALK_SISA",
		"curaca": &"PCH_TALK_CURACA",
		"puma": &"PCH_TALK_PUMA",
		"hijo": &"PCH_TALK_HIJO_PUMA",
	}
	if act == 4:
		lines = {
			"mother": &"PCH_TALK_MADRE_4",
			"sibling": &"PCH_TALK_HERMANO_4",
			"sisa": &"PCH_TALK_SISA_4",
			"curaca": &"PCH_TALK_CURACA_4",
			"puma": &"PCH_TALK_PUMA_4" if CampaignState.has_flag(&"costo_joven") else &"PCH_TALK_PUMA_4_NO_COST",
			"hijo": &"PCH_TALK_HIJO_PUMA_4",
		}
		if CampaignState.has_flag(&"puma_reconciliado"):
			if CampaignState.has_flag(&"costo_joven"):
				lines["puma"] = &"PCH_TALK_PUMA_4_RECONCILED_COST"
			else:
				lines["puma"] = &"PCH_TALK_PUMA_4_RECONCILED"
	elif act == 5:
		lines = {
			"mother": &"PCH_TALK_MADRE_5",
			"sibling": &"PCH_TALK_HERMANO_5",
			"sisa": &"PCH_TALK_SISA_5",
			"curaca": &"PCH_TALK_CURACA_5",
			"puma": &"PCH_TALK_PUMA_5" if CampaignState.has_flag(&"costo_joven") else &"PCH_TALK_PUMA_5_LIVE",
			"hijo": &"PCH_TALK_HIJO_PUMA_5",
		}
		if CampaignState.has_flag(&"puma_reconciliado") \
				and not CampaignState.has_flag(&"costo_joven"):
			lines["puma"] = &"PCH_TALK_PUMA_5_RECONCILED"
		if CampaignState.get_flag(&"confianza_sisa") >= 2:
			lines["sisa"] = &"PCH_TALK_SISA_5_ALTA"
		elif CampaignState.get_flag(&"confianza_sisa") == 0:
			lines["sisa"] = &"PCH_TALK_SISA_5_BAJA"
	_add_talk(mother, lines["mother"])
	_add_talk(sibling, lines["sibling"])
	_add_talk(sisa, lines["sisa"])
	_add_talk(curaca, lines["curaca"])
	_add_talk(puma, lines["puma"])
	if act >= 4 and CampaignState.has_flag(&"costo_joven"):
		# El hijo de Puma cayó en la defensa: no puede estar en la llacta.
		puma_son.queue_free()
	else:
		_add_talk(puma_son, lines["hijo"])
	_add_talk(weaver, &"PCH_TALK_WEAVER")
	_add_talk(farmer, &"PCH_TALK_FARMER")
	if act == 4 and CampaignState.has_flag(&"herido_dejado") \
			and not CampaignState.has_flag(&"costo_anca"):
		var anca: NpcActor = _add_npc(npcs, "Anca", Vector3(-5.5, 0.0, 9.0), Color(0.45, 0.35, 0.3, 1.0))
		if anca != null:
			anca.watch_target = player
			_add_talk(anca, &"PCH_TALK_ANCA_4")
	if act == 4:
		# Heridos junto a los muros caídos: la posguerra no es solo un texto.
		var wounded_one: NpcActor = _add_npc(
			npcs, "Herido1", Vector3(-18.5, 0.0, 10.5), Color(0.44, 0.34, 0.27, 1.0))
		var wounded_two: NpcActor = _add_npc(
			npcs, "Herido2", Vector3(18.5, 0.0, 12.5), Color(0.4, 0.32, 0.26, 1.0))
		for wounded: NpcActor in [wounded_one, wounded_two]:
			if wounded != null:
				wounded.watch_target = player
				wounded.set_idle_animation(&"tired")
				wounded.face(_plaza_center_flat(), true)
				_add_talk(wounded, &"PCH_TALK_WOUNDED")
	if act == 5 and CampaignState.has_flag(&"herido_dejado") \
			and not CampaignState.has_flag(&"costo_anca"):
		var home: Vector3 = _home_door_position()
		var anca_five: NpcActor = _add_npc(npcs, "Anca",
			Vector3(home.x - 1.8, 0.0, home.z + 1.2), Color(0.45, 0.35, 0.3, 1.0))
		if anca_five != null:
			anca_five.watch_target = player
			_add_talk(anca_five, &"PCH_TALK_ANCA_5")


## Crea un personaje con su modelo y su bloqueo de respaldo.
func _add_npc(parent: Node3D, node_name: String, at: Vector3, color: Color) -> NpcActor:
	var packed: PackedScene = load(NPC_SCENE) as PackedScene
	if packed == null:
		return null
	var actor: NpcActor = packed.instantiate() as NpcActor
	if actor == null:
		return null
	actor.name = node_name
	actor.position = at
	actor.body_color = color
	if CHARACTER_HEIGHTS.has(node_name):
		actor.target_height = CHARACTER_HEIGHTS[node_name]
	parent.add_child(actor)
	actor.add_to_group("npcs")
	var body_mesh: MeshInstance3D = actor.get_node_or_null("Body") as MeshInstance3D
	var blockout: Array[Node3D] = []
	var slot_parent: Node3D = actor
	var slot_offset: Vector3 = Vector3.ZERO
	if body_mesh != null:
		blockout.append(body_mesh)
		slot_parent = body_mesh
		slot_offset = -body_mesh.position
	var no_collisions: Array[Node] = []
	var files: Array[String] = [CHARACTER_MODELS[node_name]]
	var slot: ModelSlot = _attach_model(slot_parent, "ModelSlot", slot_offset, files, blockout, no_collisions)
	slot.use_model_collision = false
	actor.preserve_materials = true
	actor.body_color = DressedMannequin.SKIN_COLOR
	if slot.model != null:
		actor.set_model(slot.model)
	return actor


## Añade «Hablar» a un personaje con su frase.
func _add_talk(actor: NpcActor, line_key: StringName) -> TalkPoint:
	if actor == null:
		return null
	var packed: PackedScene = load(TALK_SCENE) as PackedScene
	if packed == null:
		return null
	var talk: TalkPoint = packed.instantiate() as TalkPoint
	if talk == null:
		return null
	talk.line_key = line_key
	actor.add_child(talk)
	talk.spoke.connect(_on_npc_spoke)
	return talk


func _on_npc_spoke(actor: Node3D, line_key: StringName) -> void:
	var prefix: String = ""
	var raw: Variant = NPC_NAME_KEYS.get(String(actor.name), &"")
	var key: StringName = &""
	if raw is StringName:
		key = raw
	if key != &"":
		prefix = tr(String(key)) + ": "
	if hud != null:
		hud.show_subtitle(prefix + tr(String(line_key)), 0.0)
	var npc: NpcActor = actor as NpcActor
	if npc == null:
		return
	if npc.turn_body_to_talk:
		npc.face(player.global_position)
	npc.perform(&"talk" if npc.idle_animation == &"idle" else &"idle", TALK_HOLD_SECONDS)


## Crea los cuatro encargos del acto I y los apunta al diario del jugador.
func _process(_delta: float) -> void:
	if _assembly_started or player == null:
		return
	var required: bool = act == 1 and _tasks_done.size() >= TASKS_REQUIRED and _messenger_seen
	var accounts: bool = act == 4 and _accounts_done.size() >= 3
	var can_assemble: bool = required or accounts
	if not can_assemble:
		return
	var center: Vector3 = _plaza_center_flat()
	if Vector2(player.global_position.x - center.x, player.global_position.z - center.z).length() <= 10.0:
		_start_assembly()


func _setup_dialogue_ui() -> void:
	if hud == null or dialogue == null:
		return
	dialogue.line_shown.connect(_on_dialogue_line)
	dialogue.choices_shown.connect(_on_dialogue_choices)
	dialogue.finished.connect(_on_dialogue_finished)
	dialogue.flag_changed.connect(_on_dialogue_flag)
	hud.dialogue_advanced.connect(_on_dialogue_advanced)
	hud.dialogue_choice.connect(_on_dialogue_choice)
	hud.journal_closed.connect(_on_journal_closed)


## IV.1 y IV.2: volver a la llacta y contar casa por casa.
func _setup_act_four() -> void:
	if hud != null:
		hud.show_subtitle(tr("PCH_ACT4_RETURN"), 0.0)
		hud.show_objective(tr("PCH_OBJ_ACCOUNTS"))
	if journal != null:
		journal.add_quest(&"cuentas", &"PCH_Q_CUENTAS_TITLE", &"PCH_Q_CUENTAS_BODY")
	for index: int in range(ACCOUNT_POSITIONS.size()):
		var at: Vector3 = ACCOUNT_POSITIONS[index]
		var house: Node3D = get_node_or_null(
			"Llacta/Houses/House%02d" % (ACCOUNT_HOUSES[index] + 1)) as Node3D
		if house != null:
			at = house.to_global(Vector3(0.0, 0.9, -3.5))
			_add_absentee_cloth(house)
		_add_request_point("Account%d" % index, at, ACCOUNT_PROMPTS[index],
			_on_account_requested.bind(index), house)


## Paño oscuro en la puerta de la casa que ya no responde. Da un ancla visible
## a la cuenta y evita que el jugador llame a una caja invisible en la plaza.
func _add_absentee_cloth(house: Node3D) -> void:
	var fabric: ShaderMaterial = SurfaceMaterials.layer_material(
		SurfaceMaterials.Layer.FABRIC, Color(0.32, 0.28, 0.23, 1.0))
	var cloth: MeshInstance3D = MeshInstance3D.new()
	cloth.name = "AbsenteeCloth"
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3(1.0, 1.7, 0.06)
	cloth.mesh = box
	cloth.material_override = fabric
	cloth.position = Vector3(0.0, 0.95, -3.08)
	cloth.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	house.add_child(cloth)


func _on_account_requested(index: int) -> void:
	if index < 0 or index >= ACCOUNT_TEXTS.size():
		return
	if _accounts_done.has(StringName("account_%d" % index)):
		return
	_accounts_done[StringName("account_%d" % index)] = true
	if hud != null:
		hud.show_subtitle(tr(String(_account_text(index))), 0.0)
		hud.show_hint(tr("PCH_ACCOUNT_DONE") % _accounts_done.size(), 3.0)
	SessionLog.mark(&"account", str(index))
	if _accounts_done.size() >= 3 and hud != null:
		hud.show_objective(tr("PCH_OBJ_ASSEMBLY"))
		if journal != null:
			journal.complete_quest(&"cuentas")
		CampaignProgress.save_checkpoint(self, player.global_position)


## Texto de la cuenta según las banderas del acto III. La casa del sur no puede
## decir siempre que perdió un hijo: con `sin_costo` no cayó nadie con nombre.
func _account_text(index: int) -> StringName:
	if index == 1 and CampaignState.has_flag(&"scout_spared"):
		return &"PCH_ACCOUNT_2_TEXT_SPARED"
	if index != 2:
		return ACCOUNT_TEXTS[index]
	if CampaignState.has_flag(&"costo_anca"):
		return &"PCH_ACCOUNT_3_TEXT_ANCA"
	if CampaignState.has_flag(&"costo_joven"):
		return &"PCH_ACCOUNT_3_TEXT"
	return &"PCH_ACCOUNT_3_TEXT_NO_COST"


## La asamblea del acto: en I decide quién va; en IV, qué se dice de los que no volvieron.
func _start_assembly() -> void:
	if _assembly_started or dialogue == null:
		return
	_assembly_started = true
	if act == 1 or act == 4:
		_stage_assembly_cast()
	var entry_anca: bool = act == 4 and CampaignState.has_flag(&"herido_dejado") \
		and not CampaignState.has_flag(&"costo_anca")
	if entry_anca:
		_assembly_speaker_key = &"PCH_NPC_ANCA"
	elif act == 4:
		_assembly_speaker_key = &"PCH_NPC_PUMA"
	else:
		_assembly_speaker_key = &"PCH_NPC_CURACA"
	var graph: DialogueGraph = _build_act_four_assembly() if act == 4 else _build_act_one_assembly()
	# Las condiciones FLAG del diálogo (maíz guardado, apoyo al curaca) viven en
	# CampaignState, no en el runner: se copian sin disparar efectos.
	dialogue.seed_flags(CampaignState.get_flags())
	if not dialogue.start(graph):
		return
	# En IV abre Puma o Anca; en I, el curaca. La cámara debe mirar a quien habla.
	var speaker: NpcActor = _speaker_npc(_assembly_speaker_key)
	if speaker != null and speaker.turn_body_to_talk:
		speaker.face(player.global_position)
		speaker.perform(&"talk", TALK_HOLD_SECONDS)
	player.begin_dialogue(speaker)


## Personaje que corresponde a una clave de hablante de la asamblea.
func _speaker_npc(key: StringName) -> NpcActor:
	match key:
		&"PCH_NPC_ANCA":
			return get_node_or_null("Llacta/NPCs/Anca") as NpcActor
		&"PCH_NPC_PUMA":
			return _puma
		&"PCH_NPC_CURACA", &"PCH_NPC_AYLLUS":
			return _curaca
		&"PCH_NPC_CURACA_VECINO":
			return get_node_or_null("Llacta/NPCs/CuracaVecino") as NpcActor
	return null


func _build_act_one_assembly() -> DialogueGraph:
	var graph: DialogueGraph = DialogueGraph.new()
	graph.entry_id = &"start"
	var start: DialogueNode = DialogueNode.new()
	start.id = &"start"
	start.speaker_key = &"PCH_NPC_CURACA"
	start.text_key = &"PCH_ASM_ASK"
	start.next_id = &"end"
	var go: DialogueChoice = DialogueChoice.new()
	go.text_key = &"PCH_ASM_GO"
	go.next_id = &"go"
	var together: DialogueChoice = DialogueChoice.new()
	together.text_key = &"PCH_ASM_TOGETHER"
	together.next_id = &"together"
	var doubt: DialogueChoice = DialogueChoice.new()
	doubt.text_key = &"PCH_ASM_DOUBT"
	doubt.next_id = &"doubt"
	var choices: Array[DialogueChoice] = [go, together, doubt]
	start.choices = choices
	var nodes: Array[DialogueNode] = [start]
	for entry: Array in [[&"go", &"PCH_ASM_GO_ANSWER", &"asm_go"],
			[&"together", &"PCH_ASM_TOGETHER_ANSWER", &"asm_together"],
			[&"doubt", &"PCH_ASM_DOUBT_ANSWER", &"asm_doubt"]]:
		var node: DialogueNode = DialogueNode.new()
		node.id = entry[0]
		node.speaker_key = &"PCH_NPC_CURACA"
		node.text_key = entry[1]
		node.next_id = &"end"
		var effect: DialogueEffect = DialogueEffect.new()
		effect.kind = DialogueEffect.Kind.SET_FLAG
		effect.key = entry[2]
		effect.amount = 1
		var effects: Array[DialogueEffect] = [effect]
		node.effects = effects
		nodes.append(node)
	graph.nodes = nodes
	return graph


func _build_act_four_assembly() -> DialogueGraph:
	var graph: DialogueGraph = DialogueGraph.new()
	var anca_alive: bool = CampaignState.has_flag(&"herido_dejado") \
		and not CampaignState.has_flag(&"costo_anca")
	graph.entry_id = &"anca" if anca_alive else &"start"
	var start: DialogueNode = DialogueNode.new()
	start.id = &"start"
	start.speaker_key = &"PCH_NPC_PUMA"
	start.text_key = _assembly_ask_key()
	start.next_id = &"end"
	var speak: DialogueChoice = DialogueChoice.new()
	speak.text_key = &"PCH_ASM4_SPEAK"
	speak.next_id = &"speak"
	var silence: DialogueChoice = DialogueChoice.new()
	silence.text_key = &"PCH_ASM4_SILENCE"
	silence.next_id = &"silence"
	var more: DialogueChoice = DialogueChoice.new()
	more.text_key = &"PCH_ASM4_MORE"
	more.next_id = &"more"
	var choices: Array[DialogueChoice] = [speak]
	if CampaignState.has_flag(&"apoyo_puma") or CampaignState.has_flag(&"costo_joven"):
		var reconcile: DialogueChoice = DialogueChoice.new()
		reconcile.text_key = &"PCH_ASM4_RECONCILE"
		reconcile.next_id = &"reconcile"
		choices.append(reconcile)
	if character != null and character.get_skill(&"palabra") >= 2:
		var word: DialogueChoice = DialogueChoice.new()
		word.text_key = &"PCH_ASM4_PALABRA"
		word.next_id = &"palabra"
		choices.append(word)
	choices.append(more)
	start.choices = choices
	var nodes: Array[DialogueNode] = [start]
	if anca_alive:
		var testimony: DialogueNode = DialogueNode.new()
		testimony.id = &"anca"
		testimony.speaker_key = &"PCH_NPC_ANCA"
		testimony.text_key = &"PCH_ASM4_ANCA_TESTIMONY"
		testimony.next_id = &"start"
		nodes.append(testimony)
	var speak_key: StringName = &"PCH_ASM4_SPEAK_ANSWER"
	if CampaignState.has_flag(&"costo_anca"):
		speak_key = &"PCH_ASM4_SPEAK_ANCA"
	elif CampaignState.has_flag(&"costo_joven"):
		speak_key = &"PCH_ASM4_SPEAK_JOVEN"
	var speak_node: DialogueNode = _answer_node(&"speak", &"PCH_NPC_AYLLUS", speak_key)
	speak_node.effects = _effects([_flag_effect(&"hablo_en_asamblea"),
		_reputation_effect(&"llacta", 1)])
	nodes.append(speak_node)
	var reconcile_node: DialogueNode = _answer_node(&"reconcile", &"PCH_NPC_PUMA", &"PCH_ASM4_RECONCILE_ANSWER")
	reconcile_node.effects = _effects([_flag_effect(&"puma_reconciliado"),
		_flag_effect(&"hablo_en_asamblea")])
	nodes.append(reconcile_node)
	var word_node: DialogueNode = _answer_node(&"palabra", &"PCH_NPC_CURACA", &"PCH_ASM4_PALABRA_ANSWER")
	word_node.effects = _effects([_flag_effect(&"hablo_en_asamblea"),
		_reputation_effect(&"llacta", 1), _reputation_effect(&"cusco", 1)])
	nodes.append(word_node)
	var silence_key: StringName = &"PCH_ASM4_SILENCE_ANSWER"
	if CampaignState.has_flag(&"apoyo_silencio"):
		silence_key = &"PCH_ASM4_SILENCE_ANSWER_SILENCIO"
	var silence_node: DialogueNode = _answer_node(&"silence", &"PCH_NPC_CURACA", silence_key)
	silence_node.effects = _effects([_flag_effect(&"asamblea_silencio")])
	nodes.append(silence_node)

	var maize: DialogueChoice = DialogueChoice.new()
	maize.text_key = &"PCH_ASM4_MAIZE"
	maize.next_id = &"maize"
	var maize_condition: DialogueCondition = DialogueCondition.new()
	maize_condition.kind = DialogueCondition.Kind.FLAG
	maize_condition.key = &"maiz_guardado"
	maize_condition.minimum = 1
	maize.conditions = _conditions([maize_condition])
	var curaca_choice: DialogueChoice = DialogueChoice.new()
	curaca_choice.text_key = &"PCH_ASM4_CURACA"
	curaca_choice.next_id = &"curaca"
	var curaca_condition: DialogueCondition = DialogueCondition.new()
	curaca_condition.kind = DialogueCondition.Kind.FLAG
	curaca_condition.key = &"apoyo_curaca"
	curaca_condition.minimum = 1
	curaca_choice.conditions = _conditions([curaca_condition])
	var more_node: DialogueNode = DialogueNode.new()
	more_node.id = &"more"
	more_node.speaker_key = &"PCH_NPC_CURACA"
	more_node.text_key = &"PCH_ASM4_MORE_TEXT"
	var vecino_choice: DialogueChoice = DialogueChoice.new()
	vecino_choice.text_key = &"PCH_ASM4_VECINO"
	vecino_choice.next_id = &"vecino"
	vecino_choice.once = true
	var more_choices: Array[DialogueChoice] = [maize, curaca_choice, vecino_choice, silence]
	more_node.choices = more_choices
	nodes.append(more_node)
	var vecino_node: DialogueNode = _answer_node(&"vecino", &"PCH_NPC_CURACA_VECINO", &"PCH_ASM4_VECINO_ANSWER")
	vecino_node.next_id = &"more"
	nodes.append(vecino_node)
	var maize_node: DialogueNode = _answer_node(&"maize", &"PCH_NPC_AYLLUS", &"PCH_ASM4_MAIZE_ANSWER")
	maize_node.effects = _effects([_flag_effect(&"hablo_en_asamblea"),
		_flag_effect(&"maiz_repartido"), _reputation_effect(&"llacta", 1)])
	nodes.append(maize_node)
	var curaca_node: DialogueNode = _answer_node(&"curaca", &"PCH_NPC_CURACA", &"PCH_ASM4_CURACA_ANSWER")
	curaca_node.effects = _effects([_flag_effect(&"hablo_en_asamblea"),
		_flag_effect(&"puma_reconciliado"), _reputation_effect(&"llacta", 1)])
	nodes.append(curaca_node)
	graph.nodes = nodes
	return graph


func _has_cost() -> bool:
	return CampaignState.has_flag(&"costo_anca") or CampaignState.has_flag(&"costo_joven")


## Alianzas que llegaron al Cusco; la asamblea las reconoce si son tres.
func _ally_count() -> int:
	var count: int = 0
	for index: int in range(3):
		if CampaignState.has_flag(StringName("aliado_%d" % index)):
			count += 1
	return count


## Apertura de la asamblea: cambia con el coste y con los aliados traídos.
func _assembly_ask_key() -> StringName:
	if CampaignState.has_flag(&"costo_anca"):
		return &"PCH_ASM4_ASK_ANCA"
	if CampaignState.has_flag(&"costo_joven"):
		return &"PCH_ASM4_ASK_JOVEN"
	if _ally_count() >= 3:
		return &"PCH_ASM4_ASK_MANY"
	return &"PCH_ASM4_ASK"


func _answer_node(node_id: StringName, speaker_key: StringName, text_key: StringName) -> DialogueNode:
	var node: DialogueNode = DialogueNode.new()
	node.id = node_id
	node.speaker_key = speaker_key
	node.text_key = text_key
	node.next_id = &"end"
	return node

func _on_dialogue_line(speaker_key: StringName, text_key: StringName) -> void:
	_dialogue_speaker = speaker_key
	_dialogue_text = text_key
	_dialogue_choices.clear()
	if _assembly_started and speaker_key != _assembly_speaker_key:
		_assembly_speaker_key = speaker_key
		var target: NpcActor = _speaker_npc(speaker_key)
		if target != null:
			player.begin_dialogue(target)
	if hud != null:
		var empty: Array[String] = []
		hud.show_dialogue(tr(String(speaker_key)), tr(String(text_key)), empty)


func _on_dialogue_choices(text_keys: Array[StringName]) -> void:
	_dialogue_choices = text_keys
	if hud == null:
		return
	var texts: Array[String] = []
	for key: StringName in text_keys:
		texts.append(tr(String(key)))
	hud.update_dialogue(tr(String(_dialogue_speaker)), tr(String(_dialogue_text)), texts)


func _on_dialogue_advanced() -> void:
	if dialogue != null:
		dialogue.advance()


func _on_dialogue_choice(index: int) -> void:
	if dialogue != null:
		dialogue.choose(index)


func _on_journal_closed() -> void:
	player.set_controls_locked(false)


func _on_dialogue_finished() -> void:
	if hud != null:
		hud.hide_dialogue()
	player.end_dialogue()
	if act == 1 and _assembly_started and not _assembly_done:
		_end_act_one()
	elif act == 4 and _assembly_started and not _assembly_done:
		_end_act_four()


func _on_dialogue_flag(key: StringName, value: int) -> void:
	if value == 0:
		return
	CampaignState.set_flag(key, value)
	SessionLog.mark(&"flag", "%s=%d" % [String(key), value])
	if key == &"noticia_chanca":
		_messenger_seen = true
		if hud != null:
			hud.show_objective(tr("PCH_OBJ_ASAMBLEA"))
	if key == &"apoyo_curaca" and character != null:
		character.register_skill_use(&"palabra", 4)
	if key == &"hablo_en_asamblea" and character != null:
		character.register_skill_use(&"palabra", 2)
	if key == &"asm_go" or key == &"asm_together" or key == &"asm_doubt" \
			or key == &"hablo_en_asamblea" or key == &"asamblea_silencio":
		_assembly_choice = key


## Cierra el acto: fija las consecuencias y ofrece el paso.
func _end_act_one() -> void:
	_assembly_done = true
	CampaignState.set_flag(&"ofrecio", 1)
	if _assembly_choice == &"asm_together":
		CampaignState.set_flag(&"confianza_sisa", 2)
	elif _assembly_choice == &"asm_go":
		CampaignState.set_flag(&"confianza_sisa", 1)
	else:
		CampaignState.set_flag(&"confianza_sisa", 0)
	SessionLog.mark(&"act_one_end", String(_assembly_choice))
	CampaignProgress.save(self)
	_spawn_departure_column()
	if hud != null:
		var body: String = tr("PCH_NARR_CLOSING_1") + " " + tr("PCH_NARR_CLOSING_2")
		hud.show_end_card(tr("PCH_END_TITLE"), tr("PCH_END_HINT"), body)


## La columna sale al amanecer: tres figuras en el camino del norte. La tarjeta
## de fin cuenta lo que la escena muestra.
func _spawn_departure_column() -> void:
	var npcs: Node3D = get_node_or_null("Llacta/NPCs") as Node3D
	if npcs == null:
		return
	var north: Vector3 = Vector3(0.0, 0.0, -40.0)
	var first: NpcActor = _add_npc(npcs, "Comitiva1", Vector3(0.0, 0.0, -18.0), Color(0.48, 0.38, 0.28, 1.0))
	var second: NpcActor = _add_npc(npcs, "Comitiva2", Vector3(1.6, 0.0, -20.0), Color(0.48, 0.38, 0.28, 1.0))
	var third: NpcActor = _add_npc(npcs, "Comitiva3", Vector3(-1.6, 0.0, -20.0), Color(0.48, 0.38, 0.28, 1.0))
	for actor: NpcActor in [first, second, third]:
		if actor != null:
			actor.face(north, true)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("journal"):
		if hud == null or journal == null or dialogue == null:
			return
		if dialogue.is_active() or _assembly_started:
			return
		if hud.is_journal_open():
			hud.hide_journal()
			player.set_controls_locked(false)
		else:
			hud.show_journal(journal)
			player.set_controls_locked(true)
		get_viewport().set_input_as_handled()
		return
	if not _advance_requested(event):
		return
	if act == 1 and _assembly_done:
		get_viewport().set_input_as_handled()
		CampaignProgress.save(self)
		get_tree().change_scene_to_file("res://campaigns/01_pachacutec/scenes/world/paso.tscn")
	elif act == 4 and _act_four_done:
		get_viewport().set_input_as_handled()
		CampaignProgress.save(self)
		get_tree().change_scene_to_file("res://campaigns/01_pachacutec/scenes/world/llacta_act5.tscn")
	elif act == 5 and _act_five_done:
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_file("res://core/ui/title_screen.tscn")


## Acepta E, Intro o R para cerrar la tarjeta de fin. E es la tecla que el
## jugador ya usa para avanzar; R queda como atajo documentado.
static func _advance_requested(event: InputEvent) -> bool:
	if event.is_action_pressed("interact"):
		return true
	if not (event is InputEventKey):
		return false
	var key: InputEventKey = event as InputEventKey
	if not key.pressed or key.echo:
		return false
	return key.keycode == KEY_R or key.keycode == KEY_ENTER or key.keycode == KEY_KP_ENTER


## Cierra el acto IV: la asamblea, la muerte de Viracocha y el regreso a la casa.
func _end_act_four() -> void:
	if _act_four_done:
		return
	_act_four_done = true
	CampaignState.set_flag(&"viracocha_muerto", 1)
	if _assembly_choice == &"hablo_en_asamblea":
		CampaignState.set_flag(&"hablo_en_asamblea", 1)
	else:
		CampaignState.set_flag(&"asamblea_silencio", 1)
	# El mensajero del Cusco llega a la plaza; la tarjeta cierra con la noticia.
	_spawn_cusco_messenger(Vector3(3.5, 0.0, 3.5))
	SessionLog.mark(&"act_four_end")
	CampaignProgress.save(self)
	if hud != null:
		hud.show_subtitle(tr("PCH_ASM4_NEWS"), 0.0)
		hud.show_end_card(tr("PCH_END4_TITLE"), tr("PCH_END4_HINT"), tr("PCH_ASM4_NEWS"))


## Acto V: tres obras de reconstrucción y la noticia del nombre nuevo.
func _setup_act_five() -> void:
	var packed: PackedScene = load(TASK_SCENE) as PackedScene
	if packed == null:
		return
	var home: Vector3 = _home_door_position()
	var ids: Array[StringName] = [&"pirca", &"terraza", &"acequia", &"telar", &"casa"]
	var prompts: Array[StringName] = [
		&"PCH_REBUILD_PIRCA", &"PCH_REBUILD_TERRAZA", &"PCH_REBUILD_ACEQUIA",
		&"PCH_REBUILD_TELAR", &"PCH_REBUILD_CASA",
	]
	var points: Array[Vector3] = [
		Vector3(-27.5, 0.0, -12.0), Vector3(34.0, 0.8, -3.0),
		Vector3(14.0, 0.0, 8.0), Vector3(-10.0, 0.0, 6.2),
		Vector3(home.x, 0.0, home.z),
	]
	var done_keys: Array[StringName] = [
		&"PCH_REBUILD_PIRCA_DONE", &"PCH_REBUILD_TERRAZA_DONE",
		&"PCH_REBUILD_ACEQUIA_DONE", &"PCH_REBUILD_TELAR_DONE",
		&"PCH_REBUILD_CASA_DONE",
	]
	_five_done_keys = done_keys
	for index: int in range(ids.size()):
		var instance: Node = packed.instantiate()
		var task: TaskPoint = instance as TaskPoint
		var body: Node3D = instance as Node3D
		if task == null or body == null:
			instance.free()
			continue
		task.name = "Rebuild" + String(ids[index]).capitalize()
		task.task_id = ids[index]
		task.prompt_key = prompts[index]
		var point: Vector3 = points[index]
		body.position = Vector3(point.x, _height_at(point.x, point.z) + 0.9, point.z)
		if task.task_id != &"casa":
			_add_task_marker(task)
		add_child(task)
		task.completed.connect(_on_rebuild_completed)


## Poste de obra: hace visible el punto de encargo sin convertirlo en un cartel.
func _add_task_marker(task: TaskPoint) -> void:
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3(0.28, 1.0, 0.28)
	mesh_instance.mesh = box
	mesh_instance.position = Vector3(0.0, -0.4, 0.0)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.55, 0.38, 0.20, 1.0)
	material.roughness = 0.95
	mesh_instance.material_override = material
	task.add_child(mesh_instance)


func _on_rebuild_completed(task_id: StringName) -> void:
	if _rebuild_done.has(task_id):
		return
	_rebuild_done[task_id] = true
	var index: int = [&"pirca", &"terraza", &"acequia", &"telar", &"casa"].find(task_id)
	if hud != null and index >= 0:
		hud.show_hint(tr("PCH_REBUILD_DONE") % _rebuild_done.size(), 3.0)
		var subtitle: String = tr(String(_five_done_keys[index]))
		var own: bool = _is_oficio_work(task_id)
		if character != null:
			character.register_skill_use(_rebuild_skill(task_id), 2)
		if own:
			subtitle += " " + tr("PCH_REBUILD_OWN")
			CampaignState.set_flag(&"obra_oficio", 1)
			if character != null:
				character.register_skill_use(&"oficio", 3)
				character.change_morale(5.0)
		else:
			subtitle += " " + tr("PCH_REBUILD_ALLIES")
		hud.show_subtitle(subtitle, 0.0)
	SessionLog.mark(&"rebuild", String(task_id))
	_show_rebuild(task_id)
	if _rebuild_done.size() >= 5:
		_finish_act_five()


## Habilidad que ejercita cada obra, con los mismos verbos del acto I.
static func _rebuild_skill(task_id: StringName) -> StringName:
	match task_id:
		&"pirca", &"acequia":
			return &"monte"
		&"terraza", &"casa":
			return &"oficio"
		&"telar":
			return &"palabra"
	return &"oficio"


## ¿La obra corresponde al oficio que Rumi fijó en el acto I? El oficio no
## bloquea las demás obras (las cubren los aliados), pero deja su marca.
static func _is_oficio_work(task_id: StringName) -> bool:
	var oficio: StringName = CampaignProgress.get_oficio()
	if oficio == &"":
		return false
	match task_id:
		&"pirca", &"casa":
			return oficio == &"pirca"
		&"terraza":
			return oficio == &"maiz"
		&"acequia":
			return oficio == &"agua"
		&"telar":
			return oficio == &"telar"
	return false


## Deja una pieza visible de la obra: el jugador ve lo que reconstruyó.
func _show_rebuild(task_id: StringName) -> void:
	var parent: Node3D = $Llacta as Node3D
	var stone: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.ROCK, Color(0.55, 0.52, 0.47, 1.0))
	match task_id:
		&"pirca":
			_add_box_body(parent, "RebuiltPirca", Vector3(-27.5, 0.55, -12.0), Vector3(3.4, 1.1, 0.6), stone, 1)
		&"terraza":
			var soil: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.DIRT, Color(0.44, 0.33, 0.22, 1.0))
			_add_box_body(parent, "RebuiltTerraza", Vector3(34.0, 1.0, -3.0), Vector3(5.0, 0.45, 3.2), soil, 1)
		&"acequia":
			var water: StandardMaterial3D = StandardMaterial3D.new()
			water.albedo_color = Color(0.28, 0.45, 0.52, 0.75)
			water.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			water.roughness = 0.1
			_add_box_body(parent, "RebuiltAcequia", Vector3(14.0, 0.12, 8.0), Vector3(4.0, 0.12, 0.8), water, 0)
		&"telar":
			var wood: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.WOOD, Color(0.38, 0.27, 0.18, 1.0))
			_add_box_body(parent, "RebuiltTelar", LOOM_POSITION + Vector3(0.0, 0.25, 0.0), Vector3(1.2, 0.5, 0.5), wood, 0)
		&"casa":
			_repair_home()


## Quita el paño y las piedras de la casa y enciende la lumbre del umbral.
func _repair_home() -> void:
	for node: Node3D in _home_absence_nodes:
		if is_instance_valid(node):
			node.queue_free()
	_home_absence_nodes.clear()
	_add_home_repaired()


func _finish_act_five() -> void:
	if _act_five_done:
		return
	_act_five_done = true
	CampaignState.set_flag(&"casa_reconstruida", 1)
	var final_key: StringName = &"PCH_FINAL_EN_PIE"
	if CampaignState.has_flag(&"herido_dejado") and CampaignState.has_flag(&"puma_reconciliado"):
		final_key = &"PCH_FINAL_LLENA"
	elif CampaignState.has_flag(&"asamblea_silencio") \
			and (CampaignState.has_flag(&"costo_anca") or CampaignState.has_flag(&"costo_joven")):
		final_key = &"PCH_FINAL_VACIA"
	var parts: Array[String] = []
	if CampaignState.has_flag(&"viracocha_muerto"):
		parts.append(tr("PCH_END5_NAME"))
	else:
		parts.append(tr("PCH_END5_NO_NEWS"))
	var closing: String = tr(String(final_key))
	if CampaignState.has_flag(&"casa_reconstruida"):
		closing += " " + tr("PCH_FINAL_CASA")
	if CampaignState.has_flag(&"obra_oficio"):
		closing += " " + tr("PCH_REBUILD_OWN")
	if CampaignState.has_flag(&"santuario_protegido"):
		closing += " " + tr("PCH_FINAL_SANTUARIO")
	elif CampaignState.has_flag(&"orden_llevada"):
		closing += " " + tr("PCH_FINAL_ORDEN")
	if CampaignState.has_flag(&"maiz_repartido"):
		closing += " " + tr("PCH_FINAL_MAIZ")
	parts.append(closing)
	parts.append(tr("PCH_END5_FAMILY"))
	var body: String = "\n\n".join(parts)
	SessionLog.mark(&"act_five_end", String(final_key))
	# El cierre se ve sobre la casa, no sobre una plaza cualquiera.
	var door: Vector3 = _home_door_position()
	var house: Node3D = _home_house()
	var outward: Vector3 = Vector3.FORWARD
	if house != null:
		outward = door - house.global_position
	outward.y = 0.0
	outward = outward.normalized()
	var tangent: Vector3 = Vector3(-outward.z, 0.0, outward.x)
	var camera_position: Vector3 = door + outward * 4.2
	camera_position.y = 0.05
	player.global_position = camera_position
	player.rotation.y = atan2(-(door.x - camera_position.x), -(door.z - camera_position.z))
	player.head.rotation.x = 0.0
	_stage_home_cast()
	_spawn_cusco_messenger(door + outward * 2.0 + tangent * 2.2)
	if hud != null:
		hud.show_subtitle(tr("PCH_END5_MESSENGER"), 0.0)
		hud.show_end_card(tr("PCH_END5_TITLE"), tr("PCH_END5_HINT"), body)


## Tarjetas de apertura: mundo, época, nota histórica y controles. Se muestran
## una sola vez por campaña; el jugador las pasa con E.
func _show_intro() -> void:
	var cards: IntroCards = IntroCards.new()
	cards.name = "IntroCards"
	$UILayer.add_child(cards)
	var texts: Array[String] = [
		tr("PCH_CAMPAIGN_SUBTITLE"),
		tr("PCH_INTRO_1"),
		tr("PCH_INTRO_2"),
		tr("PCH_INTRO_3"),
		tr("PCH_INTRO_NOTE"),
	]
	cards.play(texts, tr("PCH_INTRO_HINT"))
	cards.finished.connect(_on_intro_finished)
	player.set_controls_locked(true)
	CampaignState.set_flag(&"intro_vista", 1)


func _on_intro_finished() -> void:
	player.set_controls_locked(false)
	if hud != null:
		hud.show_subtitle(tr("PCH_NARR_OPENING"), 0.0)


func _setup_act_one() -> void:
	var packed: PackedScene = load(TASK_SCENE) as PackedScene
	if packed == null:
		return
	for index: int in range(TASK_IDS.size()):
		var instance: Node = packed.instantiate()
		var task: TaskPoint = instance as TaskPoint
		var body: Node3D = instance as Node3D
		if task == null or body == null:
			instance.free()
			continue
		task.name = "Task" + String(TASK_IDS[index]).capitalize()
		task.task_id = TASK_IDS[index]
		task.prompt_key = TASK_PROMPTS[index]
		var point: Vector3 = TASK_POSITIONS[index]
		body.position = Vector3(point.x, _height_at(point.x, point.z) + 0.9, point.z)
		if not TASK_MODELS[index].is_empty():
			var model_scene: PackedScene = load(MODEL_DIR + TASK_MODELS[index]) as PackedScene
			if model_scene != null:
				var model: Node3D = model_scene.instantiate() as Node3D
				if model != null:
					model.position = Vector3(0.0, -0.9, 0.0)
					SurfaceMaterials.apply_to_model(model)
					task.add_child(model)
		else:
			_add_task_marker(task)
		add_child(task)
		task.completed.connect(_on_task_completed)
	if journal != null:
		journal.add_quest(&"encargos", &"PCH_Q_ENCARGOS_TITLE", &"PCH_Q_ENCARGOS_BODY")
		journal.add_memory(&"mem_plaza", &"PCH_ST_PLAZA_TITLE", &"PCH_ST_PLAZA_BODY", &"A", &"PCH_ST_PLAZA_SOURCE")
	if hud != null:
		hud.show_subtitle(tr("PCH_NARR_OPENING"), 0.0)
	_add_request_point("DudaPoint", Vector3(-6.5, 0.9, 4.2), &"PCH_TALK_DUDA", _on_duda_requested)


## Punto de interacción sin modelo: abre una conversación de la escena.
func _add_request_point(
	node_name: String,
	at: Vector3,
	prompt_key: StringName,
	handler: Callable,
	highlight_target: Node3D = null
) -> CampPoint:
	var packed: PackedScene = load(CAMP_SCENE) as PackedScene
	if packed == null:
		return null
	var instance: Node = packed.instantiate()
	var point: CampPoint = instance as CampPoint
	var body: Node3D = instance as Node3D
	if point == null or body == null:
		instance.free()
		return null
	point.name = node_name
	point.prompt_key = prompt_key
	point.highlight_target = highlight_target
	body.position = at
	add_child(point)
	point.requested.connect(handler)
	return point


## La duda del acto I: Puma y el curaca discuten delante del jugador.
func _on_duda_requested() -> void:
	if _duda_started or dialogue == null or _assembly_started:
		return
	if dialogue.is_active():
		return
	_duda_started = true
	if dialogue.start(_build_duda_dialogue()):
		player.begin_dialogue(_puma if _puma != null else _curaca)


func _build_duda_dialogue() -> DialogueGraph:
	var graph: DialogueGraph = DialogueGraph.new()
	graph.entry_id = &"start"
	var start: DialogueNode = DialogueNode.new()
	start.id = &"start"
	start.speaker_key = &"PCH_NPC_PUMA"
	start.text_key = &"PCH_DUDA_INTRO"
	start.next_id = &"end"
	var puma: DialogueChoice = DialogueChoice.new()
	puma.text_key = &"PCH_DUDA_PUMA"
	puma.next_id = &"puma"
	var curaca: DialogueChoice = DialogueChoice.new()
	curaca.text_key = &"PCH_DUDA_CURACA"
	curaca.next_id = &"curaca"
	var silence: DialogueChoice = DialogueChoice.new()
	silence.text_key = &"PCH_DUDA_SILENCE"
	silence.next_id = &"silence"
	var choices: Array[DialogueChoice] = [puma, curaca, silence]
	start.choices = choices
	var nodes: Array[DialogueNode] = [start]
	var puma_node: DialogueNode = _answer_node(&"puma", &"PCH_NPC_PUMA", &"PCH_DUDA_PUMA_ANSWER")
	puma_node.effects = _effects([_flag_effect(&"apoyo_puma"),
		_reputation_effect(&"llacta", 1), _reputation_effect(&"cusco", -1)])
	nodes.append(puma_node)
	var curaca_node: DialogueNode = _answer_node(&"curaca", &"PCH_NPC_CURACA", &"PCH_DUDA_CURACA_ANSWER")
	curaca_node.effects = _effects([_flag_effect(&"apoyo_curaca"),
		_reputation_effect(&"cusco", 1)])
	nodes.append(curaca_node)
	var silence_node: DialogueNode = _answer_node(&"silence", &"PCH_NPC_CURACA", &"PCH_DUDA_SILENCE_ANSWER")
	silence_node.effects = _effects([_flag_effect(&"apoyo_silencio")])
	nodes.append(silence_node)
	graph.nodes = nodes
	return graph


## El mensajero llega cuando la llacta ya respondió a tres encargos.
func _spawn_messenger() -> void:
	if _messenger_spawned:
		return
	_messenger_spawned = true
	var npcs: Node3D = get_node_or_null("Llacta/NPCs") as Node3D
	var actor: NpcActor = _add_npc(npcs, "Mensajero", Vector3(-3.0, 0.0, 3.0), Color(0.55, 0.42, 0.32, 1.0))
	if actor != null:
		_messenger_actor = actor
		actor.watch_target = player
		actor.face(_plaza_center_flat(), true)
	var point: CampPoint = _add_request_point("MessengerPoint", Vector3(-3.0, 0.9, 3.0), &"PCH_TALK_MESSENGER", _on_messenger_requested)
	if point != null:
		point.name = "MessengerPoint"


func _on_messenger_requested() -> void:
	if dialogue == null or _assembly_started:
		return
	if dialogue.is_active():
		return
	if CampaignState.has_flag(&"noticia_chanca"):
		if hud != null:
			hud.show_subtitle(tr("PCH_MSG_AGAIN"), 0.0)
		return
	if dialogue.start(_build_messenger_dialogue()):
		player.begin_dialogue(_messenger_actor)


func _build_messenger_dialogue() -> DialogueGraph:
	var graph: DialogueGraph = DialogueGraph.new()
	graph.entry_id = &"start"
	var start: DialogueNode = DialogueNode.new()
	start.id = &"start"
	start.speaker_key = &"PCH_NPC_MENSAJERO"
	start.text_key = &"PCH_MSG_INTRO"
	start.next_id = &"end"
	var water: DialogueChoice = DialogueChoice.new()
	water.text_key = &"PCH_MSG_WATER"
	water.next_id = &"water"
	water.conditions = _conditions([_item_condition(&"agua")])
	var maize: DialogueChoice = DialogueChoice.new()
	maize.text_key = &"PCH_MSG_MAIZE"
	maize.next_id = &"maize"
	maize.conditions = _conditions([_item_condition(&"maiz")])
	var listen: DialogueChoice = DialogueChoice.new()
	listen.text_key = &"PCH_MSG_LISTEN"
	listen.next_id = &"listen"
	var choices: Array[DialogueChoice] = [water, maize, listen]
	start.choices = choices
	var nodes: Array[DialogueNode] = [start]
	var water_node: DialogueNode = _answer_node(&"water", &"PCH_NPC_MENSAJERO", &"PCH_MSG_WATER_ANSWER")
	water_node.effects = _effects([_item_remove_effect(&"agua"), _flag_effect(&"mensajero_ayudado"),
		_flag_effect(&"noticia_chanca"), _reputation_effect(&"llacta", 1)])
	nodes.append(water_node)
	var maize_node: DialogueNode = _answer_node(&"maize", &"PCH_NPC_MENSAJERO", &"PCH_MSG_MAIZE_ANSWER")
	maize_node.effects = _effects([_item_remove_effect(&"maiz"), _flag_effect(&"mensajero_ayudado"),
		_flag_effect(&"noticia_chanca"), _reputation_effect(&"llacta", 1)])
	nodes.append(maize_node)
	var listen_node: DialogueNode = _answer_node(&"listen", &"PCH_NPC_MENSAJERO", &"PCH_MSG_LISTEN_ANSWER")
	listen_node.effects = _effects([_flag_effect(&"noticia_chanca")])
	nodes.append(listen_node)
	graph.nodes = nodes
	return graph


func _flag_effect(key: StringName) -> DialogueEffect:
	var effect: DialogueEffect = DialogueEffect.new()
	effect.kind = DialogueEffect.Kind.SET_FLAG
	effect.key = key
	effect.amount = 1
	return effect


func _reputation_effect(group: StringName, amount: int) -> DialogueEffect:
	var effect: DialogueEffect = DialogueEffect.new()
	effect.kind = DialogueEffect.Kind.REPUTATION
	effect.group = group
	effect.amount = amount
	return effect


func _item_remove_effect(key: StringName) -> DialogueEffect:
	var effect: DialogueEffect = DialogueEffect.new()
	effect.kind = DialogueEffect.Kind.ITEM_REMOVE
	effect.key = key
	effect.amount = 1
	return effect


func _item_condition(key: StringName) -> DialogueCondition:
	var condition: DialogueCondition = DialogueCondition.new()
	condition.kind = DialogueCondition.Kind.ITEM
	condition.key = key
	condition.minimum = 1
	return condition


func _conditions(items: Array[DialogueCondition]) -> Array[DialogueCondition]:
	return items


func _effects(items: Array[DialogueEffect]) -> Array[DialogueEffect]:
	return items


## Registra un encargo: da su recurso, fija el oficio en el primero y avisa.
func _on_task_completed(task_id: StringName) -> void:
	if _tasks_done.has(task_id):
		return
	_tasks_done[task_id] = true
	var index: int = TASK_IDS.find(task_id)
	if index >= 0:
		var item: ItemDefinition = _make_quest_item(TASK_ITEM_IDS[index], TASK_ITEM_KEYS[index])
		if inventory != null and item != null:
			inventory.add(item, 1)
	if character != null:
		character.register_skill_use(_skill_for_task(task_id), 4)
	if _oficio == &"":
		_oficio = task_id
		CampaignProgress.set_oficio(_oficio)
	if journal != null and _oficio != &"" and not journal.has(&"oficio"):
		journal.add_quest(&"oficio", &"PCH_Q_OFICIO_TITLE",
			CampaignProgress.oficio_body_key(_oficio))
	CampaignProgress.save(self)
	if hud != null:
		hud.show_hint(tr("PCH_TASK_DONE") % _tasks_done.size(), 3.0)
		if index >= 0:
			hud.show_subtitle(tr(String(TASK_DONE_KEYS[index])), 0.0)
	SessionLog.mark(&"task", String(task_id))
	if _tasks_done.size() >= TASKS_REQUIRED:
		if journal != null:
			journal.complete_quest(&"encargos")
		_spawn_messenger()
		if hud != null:
			hud.show_objective(tr("PCH_OBJ_MESSENGER"))


func _make_quest_item(id: StringName, name_key: StringName) -> ItemDefinition:
	var item: ItemDefinition = ItemDefinition.new()
	item.id = id
	item.name_key = name_key
	item.category = ItemDefinition.Category.QUEST
	item.max_stack = 1
	return item


static func _skill_for_task(task_id: StringName) -> StringName:
	match task_id:
		&"agua":
			return &"monte"
		&"maiz":
			return &"oficio"
		&"telar":
			return &"palabra"
		&"pirca":
			return &"monte"
	return &"oficio"


func _plaza_center_flat() -> Vector3:
	return Vector3(0.0, 0.0, 2.0)


## Casa de Rumi, o null si la escena aún no la construyó.
func _home_house() -> Node3D:
	return get_node_or_null(
		"Llacta/Houses/House%02d" % (HOME_HOUSE_INDEX + 1)) as Node3D


## Punto delante de la puerta de la casa, a la altura del pecho.
func _home_door_position() -> Vector3:
	var house: Node3D = _home_house()
	if house == null:
		return Vector3(16.7, 0.9, 7.8)
	return house.to_global(Vector3(0.0, 0.9, -HOME_DOOR_OFFSET))


## Posición de la madre ([param side] = 1) o del hermano (−1) junto al umbral.
## Se calcula desde la puerta para que la familia siga a la casa si se mueve.
func _home_family_position(side: float) -> Vector3:
	var door: Vector3 = _home_door_position()
	var house: Node3D = _home_house()
	var outward: Vector3 = Vector3.FORWARD
	if house != null:
		outward = door - house.global_position
	outward.y = 0.0
	outward = outward.normalized()
	var tangent: Vector3 = Vector3(-outward.z, 0.0, outward.x)
	var at: Vector3 = door + outward * 0.7 + tangent * (0.95 * side)
	at.y = 0.0
	return at


## Coloca a un personaje del elenco en una posición y lo gira hacia [param target].
func _place_npc(node_name: String, at: Vector3, target: Vector3) -> bool:
	var npc: NpcActor = get_node_or_null("Llacta/NPCs/" + node_name) as NpcActor
	if npc == null:
		return false
	npc.global_position = Vector3(at.x, 0.0, at.z)
	npc.face(target, true)
	return true


## Puebla la asamblea: la familia, Sisa, Puma y su hijo rodean la plaza. Sin
## esto la escena se reduce a un curaca hablando solo.
func _stage_assembly_cast() -> void:
	var center: Vector3 = _plaza_center_flat()
	_place_npc("Habitante1", Vector3(-3.4, 0.0, 3.6), center)
	_place_npc("Habitante2", Vector3(-2.4, 0.0, 4.6), center)
	_place_npc("Habitante3", Vector3(3.2, 0.0, 3.2), center)
	_place_npc("Principal2", Vector3(-4.6, 0.0, -0.6), center)
	_place_npc("HijoPuma", Vector3(-3.6, 0.0, 0.2), center)
	if act == 4:
		_place_npc("CuracaVecino", Vector3(4.6, 0.0, -0.8), center)


## Reúne a la familia en el umbral para el cierre del acto V.
func _stage_home_cast() -> void:
	var door: Vector3 = _home_door_position()
	var house: Node3D = _home_house()
	var outward: Vector3 = Vector3.FORWARD
	if house != null:
		outward = door - house.global_position
	outward.y = 0.0
	outward = outward.normalized()
	var tangent: Vector3 = Vector3(-outward.z, 0.0, outward.x)
	var camera: Vector3 = door + outward * 4.2
	_place_npc("Habitante1", door + outward * 0.4 + tangent * 2.0, camera)
	_place_npc("Habitante2", door + outward * 0.4 - tangent * 2.0, camera)
	_place_npc("Habitante3", door + outward * 1.0 + tangent * 1.5, camera)
	_place_npc("Principal2", door + outward * 1.0 - tangent * 1.5, camera)
	_place_npc("HijoPuma", door + outward * 1.6 - tangent * 0.9, camera)
	_place_npc("Anca", door + outward * 1.6 + tangent * 0.9, camera)


## Mensajero de la noticia: acto IV (muerte de Viracocha) y acto V (nombre nuevo).
func _spawn_cusco_messenger(at: Vector3) -> NpcActor:
	var npcs: Node3D = get_node_or_null("Llacta/NPCs") as Node3D
	if npcs == null or npcs.get_node_or_null("Mensajero") != null:
		return null
	var actor: NpcActor = _add_npc(npcs, "Mensajero", at, Color(0.55, 0.42, 0.32, 1.0))
	if actor != null:
		actor.watch_target = player
		actor.face(player.global_position, true)
	return actor


func loom_transform() -> Transform3D:
	var toward: Vector3 = _plaza_center_flat() - LOOM_POSITION
	toward.y = 0.0
	return Transform3D(Basis.looking_at(-toward.normalized(), Vector3.UP), LOOM_POSITION)


## Fuego comunal: piedras, troncos, llama y una luz cálida. Reconstrucción de
## ambiente (R): no documenta un fuego concreto, solo el uso del espacio.
func _add_community_fire(parent: Node3D) -> void:
	var root: Node3D = Node3D.new()
	root.name = "CommunityFire"
	root.position = FIRE_PIT_POSITION
	parent.add_child(root)
	var rock: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.ROCK, Color(0.50, 0.48, 0.45, 1.0))
	for index: int in range(8):
		var angle: float = TAU * float(index) / 8.0
		var stone_instance: MeshInstance3D = MeshInstance3D.new()
		var sphere: SphereMesh = SphereMesh.new()
		sphere.radius = 0.15
		sphere.height = 0.26
		sphere.radial_segments = 6
		sphere.rings = 3
		stone_instance.mesh = sphere
		stone_instance.material_override = rock
		stone_instance.position = Vector3(cos(angle) * 0.72, 0.10, sin(angle) * 0.72)
		root.add_child(stone_instance)
	var wood: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.WOOD, Color(0.36, 0.26, 0.17, 1.0))
	for offset: Vector3 in [Vector3(-0.55, 0.0, 0.2), Vector3(0.5, 0.0, -0.25)]:
		var log_instance: MeshInstance3D = MeshInstance3D.new()
		var cylinder: CylinderMesh = CylinderMesh.new()
		cylinder.top_radius = 0.07
		cylinder.bottom_radius = 0.09
		cylinder.height = 0.9
		log_instance.mesh = cylinder
		log_instance.material_override = wood
		log_instance.position = Vector3(offset.x, 0.12, offset.z)
		log_instance.rotation_degrees = Vector3(0.0, 20.0, 90.0)
		root.add_child(log_instance)
	for size: Vector2 in [Vector2(0.20, 0.48), Vector2(0.12, 0.30)]:
		var flame: MeshInstance3D = MeshInstance3D.new()
		var cone: CylinderMesh = CylinderMesh.new()
		cone.top_radius = 0.0
		cone.bottom_radius = size.x
		cone.height = size.y
		flame.mesh = cone
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = Color(0.98, 0.52, 0.16, 1.0)
		material.emission_enabled = true
		material.emission = Color(1.0, 0.42, 0.1, 1.0)
		material.emission_energy_multiplier = 2.0
		flame.material_override = material
		flame.position = Vector3(0.0, 0.12 + size.y * 0.5, 0.0)
		root.add_child(flame)
	var light: OmniLight3D = OmniLight3D.new()
	light.name = "FireLight"
	light.position = Vector3(0.0, 0.9, 0.0)
	light.light_color = Color(1.0, 0.62, 0.32, 1.0)
	light.light_energy = 1.0
	light.omni_range = 5.5
	light.shadow_enabled = false
	root.add_child(light)
	if AudioServer.get_driver_name() != "Dummy":
		CampaignAudio.add_loop_3d(self, "VillageFire", CampaignAudio.FIRE_PATH,
			FIRE_PIT_POSITION + Vector3.UP * 0.35, -18.0, 4.0, 24.0)


## Luz y ruinas según el acto: la posguerra es más fría y tiene muros caídos;
## la obra vuelve a la luz cálida.
func _apply_act_mood() -> void:
	if act == 1:
		return
	var environment: Environment = world_environment.environment
	if act == 4:
		sun.light_energy = 0.85
		sun.light_color = Color(0.76, 0.85, 1.0, 1.0)
		if environment != null:
			environment.ambient_light_energy = 0.75
			environment.ambient_light_color = Color(0.62, 0.70, 0.84, 1.0)
			environment.background_energy_multiplier = 0.72
			environment.fog_light_color = Color(0.60, 0.68, 0.82, 1.0)
		var fire: Node3D = get_node_or_null("Llacta/CommunityFire") as Node3D
		if fire != null:
			fire.visible = false
		_add_ruin(Vector3(-19.0, 0.0, 9.5), "RuinWest")
		_add_ruin(Vector3(19.0, 0.0, 11.5), "RuinEast")
		_add_ruin(Vector3(-33.0, 0.0, 3.0), "RuinNorthWest")
		_add_ruin(Vector3(33.0, 0.0, -5.0), "RuinNorthEast")
		_add_home_absence()
		_add_uncared_field()
	else:
		sun.light_energy = 1.35
		sun.light_color = Color(1.0, 0.87, 0.7, 1.0)
		if environment != null:
			environment.ambient_light_energy = 1.0
			environment.ambient_light_color = Color(0.72, 0.68, 0.61, 1.0)
			environment.background_energy_multiplier = 1.0
			environment.fog_light_color = Color(0.66, 0.74, 0.86, 1.0)
		var fire: Node3D = get_node_or_null("Llacta/CommunityFire") as Node3D
		if fire != null:
			fire.visible = true
		_add_home_absence()


## La casa de Rumi en la posguerra: la puerta se cubre con un paño oscuro y
## quedan piedras caídas en el umbral. No se toca el modelo de la casa.
func _add_home_absence() -> void:
	var house: Node3D = _home_house()
	if house == null:
		return
	var fabric: ShaderMaterial = SurfaceMaterials.layer_material(
		SurfaceMaterials.Layer.FABRIC, Color(0.24, 0.21, 0.17, 1.0))
	var cloth: MeshInstance3D = MeshInstance3D.new()
	cloth.name = "HomeAbsenceCloth"
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3(1.1, 1.8, 0.06)
	cloth.mesh = box
	cloth.material_override = fabric
	cloth.position = Vector3(0.0, 0.95, -3.08)
	cloth.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	house.add_child(cloth)
	_home_absence_nodes.append(cloth)
	var stone: ShaderMaterial = SurfaceMaterials.layer_material(
		SurfaceMaterials.Layer.ROCK, Color(0.45, 0.43, 0.40, 1.0))
	for offset: Vector3 in [Vector3(-1.35, 0.18, -3.35), Vector3(1.15, 0.14, -3.5)]:
		var rubble: MeshInstance3D = MeshInstance3D.new()
		var rubble_box: BoxMesh = BoxMesh.new()
		rubble_box.size = Vector3(0.55, 0.3, 0.42)
		rubble.mesh = rubble_box
		rubble.material_override = stone
		rubble.position = offset
		rubble.rotation.y = offset.x
		house.add_child(rubble)
		_home_absence_nodes.append(rubble)


## La posguerra también se ve en los campos: matas altas y una herramienta
## abandonada en las terrazas que nadie cuidó.
func _add_uncared_field() -> void:
	var grass: ShaderMaterial = SurfaceMaterials.layer_material(
		SurfaceMaterials.Layer.GRASS, Color(0.33, 0.34, 0.20, 1.0))
	var spots: Array[Vector3] = [
		Vector3(33.5, 0.85, -4.0), Vector3(35.0, 0.85, 2.5),
		Vector3(41.5, 1.65, 1.0), Vector3(43.0, 1.65, -3.0),
		Vector3(49.5, 2.45, -6.0), Vector3(-29.5, 0.0, -10.0),
	]
	for at: Vector3 in spots:
		var weed: MeshInstance3D = MeshInstance3D.new()
		var cone: CylinderMesh = CylinderMesh.new()
		cone.top_radius = 0.0
		cone.bottom_radius = 0.32
		cone.height = 0.75
		cone.radial_segments = 5
		weed.mesh = cone
		weed.material_override = grass
		weed.position = Vector3(at.x, at.y + 0.35, at.z)
		weed.rotation.y = at.x * 0.3
		weed.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		($Llacta as Node3D).add_child(weed)
	var wood: ShaderMaterial = SurfaceMaterials.layer_material(
		SurfaceMaterials.Layer.WOOD, Color(0.36, 0.26, 0.17, 1.0))
	var tool: MeshInstance3D = MeshInstance3D.new()
	var handle: BoxMesh = BoxMesh.new()
	handle.size = Vector3(0.12, 1.1, 0.12)
	tool.mesh = handle
	tool.material_override = wood
	tool.position = Vector3(32.0, 1.0, 0.0)
	tool.rotation_degrees = Vector3(0.0, 0.0, 38.0)
	($Llacta as Node3D).add_child(tool)


## La casa en obra: umbral reparado y una luz cálida en la puerta. El jugador
## ve que la casa volvió a tener hogar, no solo que la tarjeta lo diga.
func _add_home_repaired() -> void:
	var house: Node3D = _home_house()
	if house == null:
		return
	var stone: ShaderMaterial = SurfaceMaterials.layer_material(
		SurfaceMaterials.Layer.STONE, Color(0.58, 0.54, 0.48, 1.0))
	var threshold: MeshInstance3D = MeshInstance3D.new()
	threshold.name = "HomeThreshold"
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3(2.0, 0.16, 0.7)
	threshold.mesh = box
	threshold.material_override = stone
	threshold.position = Vector3(0.0, 0.08, -3.05)
	house.add_child(threshold)
	var light: OmniLight3D = OmniLight3D.new()
	light.name = "HomeLight"
	light.light_color = Color(1.0, 0.66, 0.34, 1.0)
	light.light_energy = 1.3
	light.omni_range = 5.0
	light.shadow_enabled = false
	light.position = house.to_global(Vector3(0.0, 1.6, -3.1))
	add_child(light)


func _add_ruin(at: Vector3, node_name: String) -> void:
	var stone: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.ROCK, Color(0.44, 0.42, 0.39, 1.0))
	var wall: StaticBody3D = _add_box_body($Llacta as Node3D, node_name, at + Vector3(0.0, 0.35, 0.0), Vector3(2.6, 0.7, 0.5), stone, 1)
	wall.rotation.y = 0.45
	wall.set_meta(PlayerFPS.FOOTSTEP_SURFACE_META, SURFACE_STONE)


func _setup_footsteps() -> void:
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
	if AudioServer.get_bus_index(&"Ambience") >= 0:
		player_audio.bus = &"Ambience"
	var wind: LlactaWind = get_node_or_null("Wind") as LlactaWind
	if wind != null:
		wind.ambience = player_audio
		wind.ambience_base_db = player_audio.volume_db


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


func _add_terrace(parent: Node3D, node_name: String, center_x: float, bottom_y: float, top_y: float, material: Material, back_exposed: bool = false) -> void:
	var bodies: Array[StaticBody3D] = []
	var mortar: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.ROCK, TERRACE_MORTAR_COLOR)
	var north: StaticBody3D = _add_box_body(parent, node_name + "North", Vector3(center_x, top_y * 0.5, -8.5), Vector3(8.0, top_y, 13.0), mortar, 1)
	var south: StaticBody3D = _add_box_body(parent, node_name + "South", Vector3(center_x, top_y * 0.5, 8.5), Vector3(8.0, top_y, 13.0), mortar, 1)
	bodies.append(north)
	bodies.append(south)
	var ramp_material: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.STONE, RAMP_COLOR)
	bodies.append(_add_ramp(parent, node_name + "Ramp", Vector3(center_x - 4.0, bottom_y, 0.0), 8.0, top_y - bottom_y, 4.0, ramp_material))
	if bottom_y > 0.0:
		bodies.append(_add_box_body(parent, node_name + "Fill", Vector3(center_x, bottom_y * 0.5, 0.0), Vector3(8.0, bottom_y, 4.0), material, 1))
	var cap_height: float = top_y - TERRACE_CAP_INSET
	bodies.append(_add_box_body(parent, node_name + "Cap", Vector3(center_x + 4.0 - TERRACE_CAP_THICKNESS * 0.5, cap_height * 0.5, 0.0), Vector3(TERRACE_CAP_THICKNESS, cap_height, 4.0), material, 1))
	for body: StaticBody3D in bodies:
		body.set_meta(PlayerFPS.FOOTSTEP_SURFACE_META, SURFACE_STONE)
	for field_body: StaticBody3D in [north, south]:
		field_body.remove_meta(PlayerFPS.FOOTSTEP_SURFACE_META)
		parent.add_child(field_mesh(node_name + ("FieldNorth" if field_body == north else "FieldSouth"),
			Vector3(center_x, top_y, field_body.position.z), Vector2(8.0, 13.0)))
	parent.add_child(terrace_walls_mesh(node_name + "Walls", center_x, top_y, back_exposed))


static func terrace_walls_mesh(node_name: String, center_x: float, top_y: float, back_exposed: bool) -> MeshInstance3D:
	var x0: float = center_x - 4.0
	var x1: float = center_x + 4.0
	var faces: Array[StoneWall.Face] = [
		StoneWall.Face.new(Vector3(x0, 0.0, -15.0), Vector3.BACK, Vector3.LEFT, 13.0, top_y),
		StoneWall.Face.new(Vector3(x0, 0.0, 2.0), Vector3.BACK, Vector3.LEFT, 13.0, top_y),
		StoneWall.Face.new(Vector3(x0, 0.0, -2.0), Vector3.RIGHT, Vector3.BACK, 8.0, top_y),
		StoneWall.Face.new(Vector3(x0, 0.0, 2.0), Vector3.RIGHT, Vector3.FORWARD, 8.0, top_y),
		StoneWall.Face.new(Vector3(x0, 0.0, -15.0), Vector3.RIGHT, Vector3.FORWARD, 8.0, top_y),
		StoneWall.Face.new(Vector3(x0, 0.0, 15.0), Vector3.RIGHT, Vector3.BACK, 8.0, top_y),
	]
	if back_exposed:
		faces.append(StoneWall.Face.new(Vector3(x1, 0.0, -15.0), Vector3.BACK, Vector3.RIGHT, 13.0, top_y))
		faces.append(StoneWall.Face.new(Vector3(x1, 0.0, 2.0), Vector3.BACK, Vector3.RIGHT, 13.0, top_y))
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = node_name
	mesh_instance.mesh = StoneWall.build(faces, hash(node_name))
	mesh_instance.material_override = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.STONE, Color.WHITE, true)
	return mesh_instance


static func field_mesh(node_name: String, top_center: Vector3, size: Vector2) -> MeshInstance3D:
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var half_x: float = size.x * 0.5 - FIELD_MARGIN
	var half_z: float = size.y * 0.5 - FIELD_MARGIN
	var y0: float = FIELD_LIFT
	var z0: float = -half_z
	var z1: float = half_z
	surface.set_color(FIELD_SOIL_COLOR.srgb_to_linear())
	for vertex: Vector3 in [Vector3(-half_x, y0, z0), Vector3(half_x, y0, z0), Vector3(half_x, y0, z1),
			Vector3(-half_x, y0, z0), Vector3(half_x, y0, z1), Vector3(-half_x, y0, z1)]:
		surface.add_vertex(vertex)
	var ridges: int = int(floorf((half_x * 2.0) / FIELD_FURROW_SPACING))
	var start_x: float = -half_x + (half_x * 2.0 - float(ridges - 1) * FIELD_FURROW_SPACING) * 0.5
	var half_width: float = FIELD_FURROW_SPACING * 0.3
	for index: int in range(ridges):
		var x: float = start_x + float(index) * FIELD_FURROW_SPACING
		var left: float = x - half_width
		var right: float = x + half_width
		var top: float = y0 + FIELD_RIDGE_HEIGHT
		surface.set_color(FIELD_RIDGE_COLOR.srgb_to_linear())
		for vertex: Vector3 in [Vector3(left, y0, z1), Vector3(x, top, z1), Vector3(x, top, z0),
				Vector3(left, y0, z1), Vector3(x, top, z0), Vector3(left, y0, z0),
				Vector3(x, top, z1), Vector3(right, y0, z1), Vector3(right, y0, z0),
				Vector3(x, top, z1), Vector3(right, y0, z0), Vector3(x, top, z0)]:
			surface.add_vertex(vertex)
	surface.generate_normals()
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = node_name
	mesh_instance.mesh = surface.commit()
	mesh_instance.material_override = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.SOIL, Color.WHITE, true)
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_instance.position = top_center
	return mesh_instance


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
	root.rotate_y(deg_to_rad(HOUSE_YAW_JITTER[index % HOUSE_YAW_JITTER.size()]))
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
	_add_house_props(root, index)


func _add_house_props(root: Node3D, index: int) -> void:
	var variant: int = index % MODEL_HOUSES.size()
	var front: float = -HOUSE_DEPTHS[variant] * 0.5 - PROP_WALL_GAP
	var left_x: float = HOUSE_LEFT_PROP_X[variant]
	var props: Array[Array] = []
	match index % 3:
		0:
			props = [[MODEL_PROP_JAR, Vector3(1.8, 0.0, front)], [MODEL_PROP_JAR, Vector3(2.3, 0.0, front - 0.25)],
				[MODEL_PROP_FIREWOOD, Vector3(left_x, 0.0, front)]]
		1:
			props = [[MODEL_PROP_FIREWOOD, Vector3(2.0, 0.0, front)], [MODEL_PROP_JAR, Vector3(left_x - 0.2, 0.0, front)]]
		_:
			props = [[MODEL_PROP_JAR, Vector3(2.0, 0.0, front)]]
	var no_blockout: Array[Node3D] = []
	var no_collisions: Array[Node] = []
	for prop_index: int in range(props.size()):
		var entry: Array = props[prop_index]
		var file: String = entry[0]
		var at: Vector3 = entry[1]
		var prop_files: Array[String] = [file]
		var slot: ModelSlot = _attach_model(root, "Prop%d" % prop_index, at, prop_files, no_blockout, no_collisions)
		slot.rotation.y = 0.35 * float((index + prop_index) % 3 - 1)


func _add_corral(parent: Node3D, node_name: String, center: Vector3, size: Vector2, entrance: Vector3) -> void:
	var root: Node3D = Node3D.new()
	root.name = node_name
	root.position = Vector3(center.x, _height_at(center.x, center.z) - CORRAL_SINK, center.z)
	parent.add_child(root)
	var stone: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.STONE, Color(0.52, 0.50, 0.46, 1.0))
	var half_x: float = size.x * 0.5
	var half_z: float = size.y * 0.5
	var segments: Array[Array] = []
	var entrance_side: Vector3 = entrance.normalized()
	segments.append([Vector3(0.0, CORRAL_WALL_HEIGHT * 0.5, -half_z), Vector3(size.x, CORRAL_WALL_HEIGHT, CORRAL_WALL_THICKNESS), Vector3(0.0, 1.0, 0.0)])
	segments.append([Vector3(0.0, CORRAL_WALL_HEIGHT * 0.5, half_z), Vector3(size.x, CORRAL_WALL_HEIGHT, CORRAL_WALL_THICKNESS), Vector3(0.0, 1.0, 0.0)])
	segments.append([Vector3(-half_x, CORRAL_WALL_HEIGHT * 0.5, 0.0), Vector3(CORRAL_WALL_THICKNESS, CORRAL_WALL_HEIGHT, size.y), Vector3(1.0, 0.0, 0.0)])
	segments.append([Vector3(half_x, CORRAL_WALL_HEIGHT * 0.5, 0.0), Vector3(CORRAL_WALL_THICKNESS, CORRAL_WALL_HEIGHT, size.y), Vector3(1.0, 0.0, 0.0)])
	for index: int in range(segments.size()):
		var segment: Array = segments[index]
		var segment_at: Vector3 = segment[0]
		var segment_size: Vector3 = segment[1]
		var body: StaticBody3D = _add_box_body(root, "Wall%d" % index, segment_at, segment_size, stone, 1)
		body.set_meta(PlayerFPS.FOOTSTEP_SURFACE_META, SURFACE_STONE)
	root.rotation.y = atan2(entrance_side.x, entrance_side.z)
	var faces: Array[StoneWall.Face] = []
	faces.append(StoneWall.Face.new(Vector3(-half_x, 0.0, -half_z), Vector3.RIGHT, Vector3.UP, size.x, CORRAL_WALL_HEIGHT))
	faces.append(StoneWall.Face.new(Vector3(-half_x, 0.0, half_z), Vector3.RIGHT, Vector3.UP, size.x, CORRAL_WALL_HEIGHT))
	faces.append(StoneWall.Face.new(Vector3(-half_x, 0.0, -half_z), Vector3.BACK, Vector3.UP, size.y, CORRAL_WALL_HEIGHT))
	faces.append(StoneWall.Face.new(Vector3(half_x, 0.0, -half_z), Vector3.BACK, Vector3.UP, size.y, CORRAL_WALL_HEIGHT))
	var walls: MeshInstance3D = MeshInstance3D.new()
	walls.name = "Stones"
	walls.mesh = StoneWall.build(faces, hash(node_name))
	walls.material_override = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.STONE, Color.WHITE, true)
	root.add_child(walls)


func _attach_pedestal(pedestal: StaticBody3D) -> void:
	var files: Array[String] = ["pch_pedestal.glb"]
	var blockout: Array[Node3D] = []
	for child: Node in pedestal.get_children():
		if child is MeshInstance3D:
			blockout.append(child as MeshInstance3D)
	_attach_model(pedestal, "ModelSlot", Vector3(0.0, -0.4, 0.0), files, blockout, [])


func _attach_model(parent: Node3D, slot_name: String, at: Vector3, files: Array[String], blockout: Array[Node3D], collisions: Array[Node]) -> ModelSlot:
	var full_paths: Array[String] = []
	for file: String in files:
		full_paths.append(MODEL_DIR + file)
	var slot: ModelSlot = ModelSlot.new()
	slot.name = slot_name
	slot.position = at
	slot.model_paths = full_paths
	slot.blockout_nodes = blockout
	slot.blockout_collisions = collisions
	parent.add_child(slot)
	return slot
