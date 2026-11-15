class_name Llacta
extends Node3D
## Mundo del acto I: la llacta del valle.
##
## Compone el terreno, el cielo, las viviendas, las terrazas, los corrales, el
## jugador y el HUD. El contenido narrativo (familia, encargos, mensajero y
## asamblea) se añade en las misiones del acto.

const TERRAIN_SIZE: float = 150.0
const TERRAIN_RESOLUTION: int = 64
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
const DISTANT_NEAR_RADIUS: float = 210.0
const DISTANT_MID_RADIUS: float = 270.0
const DISTANT_FAR_RADIUS: float = 330.0
const DISTANT_SEGMENTS: int = 160
const DISTANT_BOTTOM: float = -10.0
const DISTANT_NEAR_BASE: float = 28.0
const DISTANT_NEAR_AMPLITUDE: float = 34.0
const DISTANT_MID_BASE: float = 36.0
const DISTANT_MID_AMPLITUDE: float = 42.0
const DISTANT_FAR_BASE: float = 46.0
const DISTANT_FAR_AMPLITUDE: float = 48.0
const DISTANT_NEAR_COLOR: Color = Color(0.30, 0.34, 0.41, 1.0)
const DISTANT_MID_COLOR: Color = Color(0.36, 0.41, 0.48, 1.0)
const DISTANT_FAR_COLOR: Color = Color(0.43, 0.48, 0.55, 1.0)

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
}
const NPC_SCENE: String = "res://campaigns/01_pachacutec/scenes/npcs/npc_actor.tscn"
const MODEL_LOOM: String = "pch_loom.glb"
const FIRE_PIT_POSITION: Vector3 = Vector3(-6.0, 0.0, 7.0)
const LOOM_POSITION: Vector3 = Vector3(-10.0, 0.0, 6.2)
const TASK_SCENE: String = "res://campaigns/01_pachacutec/scenes/objects/task_point.tscn"
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
var _assembly_started: bool = false
var _assembly_done: bool = false
var _assembly_choice: StringName = &""
var _act_four_done: bool = false
var _act_five_done: bool = false
var _rebuild_done: Dictionary[StringName, bool] = {}
var _five_done_keys: Array[StringName] = []
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
			hud.show_objective(tr("PCH_OBJ_POST"))
		5:
			_setup_act_five()
			hud.show_objective(tr("PCH_OBJ_REBUILD"))
	_setup_footsteps()
	_setup_ambience()
	environment_controller.bind(world_environment, sun)
	_apply_act_mood()
	SessionLog.mark(&"control_taken")


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
	_build_range("DistantRangeNear", DISTANT_NEAR_RADIUS, DISTANT_NEAR_BASE,
		DISTANT_NEAR_AMPLITUDE, DISTANT_NEAR_COLOR)
	_build_range("DistantRangeMid", DISTANT_MID_RADIUS, DISTANT_MID_BASE,
		DISTANT_MID_AMPLITUDE, DISTANT_MID_COLOR)
	_build_range("DistantRangeFar", DISTANT_FAR_RADIUS, DISTANT_FAR_BASE,
		DISTANT_FAR_AMPLITUDE, DISTANT_FAR_COLOR)


func _build_range(node_name: String, radius: float, base_height: float, amplitude: float, color: Color) -> void:
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index: int in range(DISTANT_SEGMENTS):
		var angle0: float = TAU * float(index) / float(DISTANT_SEGMENTS)
		var angle1: float = TAU * float(index + 1) / float(DISTANT_SEGMENTS)
		var height0: float = _distant_height(angle0, base_height, amplitude)
		var height1: float = _distant_height(angle1, base_height, amplitude)
		var bottom0: Vector3 = Vector3(cos(angle0) * radius, DISTANT_BOTTOM, sin(angle0) * radius)
		var bottom1: Vector3 = Vector3(cos(angle1) * radius, DISTANT_BOTTOM, sin(angle1) * radius)
		var top0: Vector3 = Vector3(cos(angle0) * radius, height0, sin(angle0) * radius)
		var top1: Vector3 = Vector3(cos(angle1) * radius, height1, sin(angle1) * radius)
		surface.add_vertex(bottom0)
		surface.add_vertex(bottom1)
		surface.add_vertex(top1)
		surface.add_vertex(bottom0)
		surface.add_vertex(top1)
		surface.add_vertex(top0)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.disable_fog = true
	var range_node: MeshInstance3D = MeshInstance3D.new()
	range_node.name = node_name
	range_node.mesh = surface.commit()
	range_node.material_override = material
	range_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	range_node.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	add_child(range_node)


static func _distant_height(angle: float, base_height: float, amplitude: float) -> float:
	var ridge: float = 0.5 + 0.5 * sin(angle * 5.0 + 0.4) * sin(angle * 9.0 - 0.9)
	ridge = pow(maxf(ridge, 0.0), 0.65)
	var detail: float = 0.16 * sin(angle * 31.0 + 1.7) + 0.09 * sin(angle * 53.0 - 0.3) + 0.05 * sin(angle * 89.0 + 0.5)
	return base_height + amplitude * clampf(ridge + detail, 0.0, 1.0)


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
	var mother: NpcActor = _add_npc(npcs, "Habitante1", Vector3(9.0, 0.0, 4.0), Color(0.48, 0.36, 0.28, 1.0))
	var sibling: NpcActor = _add_npc(npcs, "Habitante2", Vector3(11.0, 0.0, -1.0), Color(0.42, 0.33, 0.26, 1.0))
	var sisa: NpcActor = _add_npc(npcs, "Habitante3", Vector3(7.0, 0.0, 8.0), Color(0.52, 0.4, 0.3, 1.0))
	var curaca: NpcActor = _add_npc(npcs, "Curaca", Vector3(-7.0, 0.0, -3.0), Color(0.72, 0.55, 0.45, 1.0))
	_curaca = curaca
	var puma: NpcActor = _add_npc(npcs, "Principal2", Vector3(-8.6, 0.0, 0.7), Color(0.5, 0.4, 0.3, 1.0))
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
	}
	if act == 4:
		lines = {
			"mother": &"PCH_TALK_MADRE_4",
			"sibling": &"PCH_TALK_HERMANO_4",
			"sisa": &"PCH_TALK_SISA_4",
			"curaca": &"PCH_TALK_CURACA_4",
			"puma": &"PCH_TALK_PUMA_4",
		}
	elif act == 5:
		lines = {
			"mother": &"PCH_TALK_MADRE_5",
			"sibling": &"PCH_TALK_HERMANO_5",
			"sisa": &"PCH_TALK_SISA_5",
			"curaca": &"PCH_TALK_CURACA_5",
			"puma": &"PCH_TALK_PUMA_5",
		}
	_add_talk(mother, lines["mother"])
	_add_talk(sibling, lines["sibling"])
	_add_talk(sisa, lines["sisa"])
	_add_talk(curaca, lines["curaca"])
	_add_talk(puma, lines["puma"])
	_add_talk(weaver, &"PCH_TALK_WEAVER")
	_add_talk(farmer, &"PCH_TALK_FARMER")
	if act == 4 and CampaignState.has_flag(&"herido_salvado"):
		var anca: NpcActor = _add_npc(npcs, "Anca", Vector3(-5.5, 0.0, 9.0), Color(0.45, 0.35, 0.3, 1.0))
		if anca != null:
			anca.watch_target = player
			_add_talk(anca, &"PCH_TALK_ANCA_4")


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
	if hud != null:
		hud.show_subtitle(tr(String(line_key)), 0.0)
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
	var required: bool = act == 1 and _tasks_done.size() >= TASKS_REQUIRED
	var can_assemble: bool = required or act == 4
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


## La asamblea del acto: en I decide quién va; en IV, qué se dice de los que no volvieron.
func _start_assembly() -> void:
	if _assembly_started or dialogue == null:
		return
	_assembly_started = true
	var graph: DialogueGraph = _build_act_four_assembly() if act == 4 else _build_act_one_assembly()
	if not dialogue.start(graph):
		return
	if _curaca != null and _curaca.turn_body_to_talk:
		_curaca.face(player.global_position)
		_curaca.perform(&"talk", TALK_HOLD_SECONDS)
	player.begin_dialogue(_curaca)


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
	graph.entry_id = &"start"
	var start: DialogueNode = DialogueNode.new()
	start.id = &"start"
	start.speaker_key = &"PCH_NPC_PUMA"
	start.text_key = &"PCH_ASM4_ASK"
	start.next_id = &"end"
	var speak: DialogueChoice = DialogueChoice.new()
	speak.text_key = &"PCH_ASM4_SPEAK"
	speak.next_id = &"speak"
	var silence: DialogueChoice = DialogueChoice.new()
	silence.text_key = &"PCH_ASM4_SILENCE"
	silence.next_id = &"silence"
	var choices: Array[DialogueChoice] = [speak, silence]
	start.choices = choices
	var nodes: Array[DialogueNode] = [start]
	for entry: Array in [[&"speak", &"PCH_ASM4_SPEAK_ANSWER", &"hablo_en_asamblea"],
			[&"silence", &"PCH_ASM4_SILENCE_ANSWER", &"asamblea_silencio"]]:
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

func _on_dialogue_line(speaker_key: StringName, text_key: StringName) -> void:
	_dialogue_speaker = speaker_key
	_dialogue_text = text_key
	_dialogue_choices.clear()
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
	if key == &"asm_go" or key == &"asm_together" or key == &"asm_doubt" \
			or key == &"hablo_en_asamblea" or key == &"asamblea_silencio":
		_assembly_choice = key


## Cierra el acto: fija las consecuencias y ofrece el paso.
func _end_act_one() -> void:
	_assembly_done = true
	CampaignState.set_flag(&"ofrecio", 1)
	if _assembly_choice == &"asm_go":
		CampaignState.set_flag(&"apoyo_comitiva", 1)
	elif _assembly_choice == &"asm_together":
		CampaignState.set_flag(&"apoyo_llacta", 1)
	else:
		CampaignState.set_flag(&"apoyo_duda", 1)
	CampaignState.set_flag(&"confianza_companero", 1)
	SessionLog.mark(&"act_one_end", String(_assembly_choice))
	if hud != null:
		hud.show_end_card(tr("PCH_END_TITLE"), tr("PCH_END_HINT"))


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var key: InputEventKey = event as InputEventKey
	if not key.pressed or key.echo or key.keycode != KEY_R:
		return
	if act == 1 and _assembly_done:
		get_tree().change_scene_to_file("res://campaigns/01_pachacutec/scenes/world/paso.tscn")
	elif act == 4 and _act_four_done:
		get_tree().change_scene_to_file("res://campaigns/01_pachacutec/scenes/world/llacta_act5.tscn")
	elif act == 5 and _act_five_done:
		get_tree().change_scene_to_file("res://core/ui/title_screen.tscn")


## Cierra el acto IV: la asamblea, la muerte de Viracocha y el regreso a la casa.
func _end_act_four() -> void:
	_act_four_done = true
	CampaignState.set_flag(&"viracocha_muerto", 1)
	if _assembly_choice == &"hablo_en_asamblea":
		CampaignState.set_flag(&"hablo_en_asamblea", 1)
	else:
		CampaignState.set_flag(&"asamblea_silencio", 1)
	SessionLog.mark(&"act_four_end")
	if hud != null:
		hud.show_subtitle(tr("PCH_ASM4_NEWS"), 0.0)
		hud.show_end_card(tr("PCH_END4_TITLE"), tr("PCH_END4_HINT"))


## Acto V: tres obras de reconstrucción y la noticia del nombre nuevo.
func _setup_act_five() -> void:
	var packed: PackedScene = load(TASK_SCENE) as PackedScene
	if packed == null:
		return
	var ids: Array[StringName] = [&"pirca", &"terraza", &"acequia"]
	var prompts: Array[StringName] = [&"PCH_REBUILD_PIRCA", &"PCH_REBUILD_TERRAZA", &"PCH_REBUILD_ACEQUIA"]
	var points: Array[Vector3] = [Vector3(-27.5, 0.0, -12.0), Vector3(34.0, 0.8, -3.0), Vector3(14.0, 0.0, 8.0)]
	var done_keys: Array[StringName] = [&"PCH_REBUILD_PIRCA_DONE", &"PCH_REBUILD_TERRAZA_DONE", &"PCH_REBUILD_ACEQUIA_DONE"]
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
		add_child(task)
		task.completed.connect(_on_rebuild_completed)


func _on_rebuild_completed(task_id: StringName) -> void:
	if _rebuild_done.has(task_id):
		return
	_rebuild_done[task_id] = true
	var index: int = [&"pirca", &"terraza", &"acequia"].find(task_id)
	if hud != null and index >= 0:
		hud.show_hint(tr("PCH_REBUILD_DONE") % _rebuild_done.size(), 3.0)
		hud.show_subtitle(tr(String(_five_done_keys[index])), 0.0)
	SessionLog.mark(&"rebuild", String(task_id))
	if _rebuild_done.size() >= 3:
		_finish_act_five()


func _finish_act_five() -> void:
	if _act_five_done:
		return
	_act_five_done = true
	CampaignState.set_flag(&"casa_reconstruida", 1)
	SessionLog.mark(&"act_five_end")
	if hud != null:
		hud.show_subtitle(tr("PCH_END5_NAME"), 0.0)
		hud.show_end_card(tr("PCH_END5_TITLE"), tr("PCH_END5_HINT"))


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
		add_child(task)
		task.completed.connect(_on_task_completed)


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
	if _oficio == &"":
		_oficio = task_id
		if character != null:
			character.register_skill_use(_skill_for_task(task_id), 3)
	if hud != null:
		hud.show_hint(tr("PCH_TASK_DONE") % _tasks_done.size(), 3.0)
		if index >= 0:
			hud.show_subtitle(tr(String(TASK_DONE_KEYS[index])), 0.0)
	SessionLog.mark(&"task", String(task_id))
	if _tasks_done.size() >= TASKS_REQUIRED and hud != null:
		hud.show_objective(tr("PCH_OBJ_WAIT"))


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
		sun.light_color = Color(1.0, 0.78, 0.6, 1.0)
		if environment != null:
			environment.ambient_light_energy = 0.7
		var fire: Node3D = get_node_or_null("Llacta/CommunityFire") as Node3D
		if fire != null:
			fire.visible = false
		_add_ruin(Vector3(-19.0, 0.0, 9.5), "RuinWest")
		_add_ruin(Vector3(19.0, 0.0, 11.5), "RuinEast")
	else:
		sun.light_energy = 1.35
		sun.light_color = Color(1.0, 0.87, 0.7, 1.0)
		if environment != null:
			environment.ambient_light_energy = 1.0


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
