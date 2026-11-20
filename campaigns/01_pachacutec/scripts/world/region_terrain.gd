class_name CampaignRegion
extends Node3D
## Relieve de blockout de la región de la campaña 01.
##
## Propuesta GN/GR basada en el mapa conceptual: valle este-oeste, río, quebrada
## alta, paso y cumbres. No es una reconstrucción topográfica ni contenido
## definitivo; se sustituirá o ajustará cuando el expediente geográfico deje de
## ser una hipótesis.
##
## Una región de Terrain3D de 1024 con paso de 4 m cubre los 3,5 × 2,5 km de
## juego con margen. Los sectores tendrán terreno local de 1 m en F2.2.

const REGION_SIZE: int = 1024
const SPACING: float = 4.0
const HALF_EXTENT: float = 2048.0
const SECTOR_LABEL_HEIGHT: float = 52.0

const SECTORS: Dictionary[StringName, Vector3] = {
	&"s1_cusco": Vector3(1200.0, 0.0, 400.0),
	&"s2_afueras": Vector3(750.0, 0.0, 150.0),
	&"s3_llacta": Vector3(300.0, 0.0, 0.0),
	&"s4_quebrada": Vector3(-700.0, 0.0, 350.0),
	&"s5_paso": Vector3(-1300.0, 0.0, 100.0),
	&"s6_frontera": Vector3(-1650.0, 0.0, 0.0),
}

const SECTOR_COLORS: Dictionary[StringName, Color] = {
	&"s1_cusco": Color(0.85, 0.70, 0.35),
	&"s2_afueras": Color(0.55, 0.72, 0.38),
	&"s3_llacta": Color(0.80, 0.55, 0.30),
	&"s4_quebrada": Color(0.35, 0.55, 0.60),
	&"s5_paso": Color(0.70, 0.70, 0.75),
	&"s6_frontera": Color(0.65, 0.35, 0.35),
}

const SECTOR_NAMES: Dictionary[StringName, String] = {
	&"s1_cusco": "S1 · Cusco preimperial",
	&"s2_afueras": "S2 · Afueras y terrazas",
	&"s3_llacta": "S3 · Llacta de Rumi",
	&"s4_quebrada": "S4 · Quebrada alta",
	&"s5_paso": "S5 · Paso",
	&"s6_frontera": "S6 · Frontera chanca",
}

@export var show_sector_markers: bool = true

var _terrain: Terrain3D = null
var _camera: Camera3D = null
var _build_ms: int = 0


func _ready() -> void:
	add_to_group(&"campaign_region")
	_build_environment()
	_build_terrain()
	if show_sector_markers:
		_build_sector_markers()
	_build_camera()


## Altura de blockout en coordenadas de mundo. Perfil GN/GR del mapa conceptual.
func height_at(x: float, z: float) -> float:
	var river_z: float = _river_z(x)
	var distance: float = absf(z - river_z)
	var base: float = 3420.0 + 780.0 * (1.0 - smoothstep(-1700.0, 1200.0, x))
	var wall: float = maxf(distance - 420.0, 0.0) * 0.36
	var peaks: float = smoothstep(750.0, 1300.0, absf(z)) * 300.0
	var noise: float = 22.0 * sin(x / 110.0) + 18.0 * cos(z / 85.0) + 8.0 * sin((x + z) / 55.0)
	var channel: float = -10.0 * exp(-pow(distance / 35.0, 2.0))
	var quebrada: float = _distance_to_segment(
		Vector2(x, z), Vector2(-700.0, _river_z(-700.0)), Vector2(-1050.0, -350.0)
	)
	var quebrada_cut: float = -160.0 * exp(-pow(quebrada / 170.0, 2.0))
	var paso: float = -90.0 * exp(-pow((x + 1300.0) / 220.0, 2.0) - pow((z - 100.0) / 180.0, 2.0))
	var puna: float = -50.0 * smoothstep(-1450.0, -1750.0, x)
	return base + wall + peaks + noise + channel + quebrada_cut + paso + puna


func get_terrain() -> Terrain3D:
	return _terrain


func get_camera() -> Camera3D:
	return _camera


func get_sector_centers() -> Dictionary[StringName, Vector3]:
	return SECTORS.duplicate()


func get_sector_height(id: StringName) -> float:
	if not SECTORS.has(id):
		return 0.0
	var center: Vector3 = SECTORS[id]
	return height_at(center.x, center.z)


func get_build_ms() -> int:
	return _build_ms


func _river_z(x: float) -> float:
	return 260.0 + 140.0 * sin(x / 420.0)


func _distance_to_segment(point: Vector2, from: Vector2, to: Vector2) -> float:
	var segment: Vector2 = to - from
	var length_squared: float = segment.length_squared()
	if length_squared <= 0.0001:
		return point.distance_to(from)
	var t: float = clampf((point - from).dot(segment) / length_squared, 0.0, 1.0)
	return point.distance_to(from + segment * t)


func _build_environment() -> void:
	# Cielo de revisión: sin él, el blockout se lee como una escena rota.
	# No es el arte final de la campaña; solo da horizonte, luz y profundidad.
	var sky_material: PhysicalSkyMaterial = PhysicalSkyMaterial.new()
	sky_material.rayleigh_coefficient = 1.4
	sky_material.rayleigh_color = Color(0.32, 0.52, 0.9)
	sky_material.mie_coefficient = 0.003
	sky_material.mie_eccentricity = 0.8
	sky_material.mie_color = Color(0.85, 0.75, 0.65)
	sky_material.turbidity = 1.7
	sky_material.ground_color = Color(0.22, 0.2, 0.17)
	sky_material.sun_disk_scale = 1.0
	var sky: Sky = Sky.new()
	sky.sky_material = sky_material

	var environment: Environment = Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.sky = sky
	# Ambiente de color neutro: la luz de cielo sola dejaba las caras en
	# sombra casi negras y las casas se leían como siluetas.
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.58, 0.62, 0.68)
	environment.ambient_light_energy = 1.2
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	# Bruma de profundidad suave: separa planos y evita que las cumbres se
	# recorten contra el cielo. No oculta el camino ni los POI.
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.66, 0.74, 0.86)
	environment.fog_light_energy = 0.5
	environment.fog_sky_affect = 0.2
	environment.fog_density = 0.00025
	environment.tonemap_mode = Environment.TONE_MAPPER_ACES
	environment.tonemap_exposure = 1.0
	var world_environment: WorldEnvironment = WorldEnvironment.new()
	world_environment.name = "BlockoutEnvironment"
	world_environment.environment = environment
	add_child(world_environment)

	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.name = "BlockoutSun"
	sun.rotation_degrees = Vector3(-38.0, -40.0, 0.0)
	sun.light_color = Color(1.0, 0.9, 0.76)
	sun.light_energy = 1.35
	sun.shadow_enabled = true
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
	sun.directional_shadow_max_distance = 300.0
	sun.directional_shadow_fade_start = 0.8
	sun.shadow_bias = 0.05
	add_child(sun)

	# Relleno frío sin sombra: las caras en sombra no pueden quedar negras en
	# una escena de revisión; sin él, las casas se leen como siluetas.
	var fill: DirectionalLight3D = DirectionalLight3D.new()
	fill.name = "BlockoutFill"
	fill.rotation_degrees = Vector3(-20.0, 140.0, 0.0)
	fill.light_color = Color(0.72, 0.80, 0.95)
	fill.light_energy = 0.55
	fill.shadow_enabled = false
	add_child(fill)


func _build_terrain() -> void:
	var start: int = Time.get_ticks_msec()
	_terrain = Terrain3D.new()
	_terrain.name = "RegionTerrain"
	_terrain.region_size = Terrain3D.SIZE_1024
	_terrain.vertex_spacing = SPACING
	_terrain.free_editor_textures = false
	add_child(_terrain)
	# Sin assets, Terrain3D dibuja su damero por defecto y el blockout parece
	# una textura ausente. Dos texturas planas de 8 × 8 dan pradera en llano y
	# roca en pendiente; el autoshader del material por defecto hace la mezcla.
	_build_terrain_assets()
	var image: Image = Image.create(REGION_SIZE, REGION_SIZE, false, Image.FORMAT_RF)
	for row: int in REGION_SIZE:
		for column: int in REGION_SIZE:
			var x: float = -HALF_EXTENT + float(column) * SPACING
			var z: float = -HALF_EXTENT + float(row) * SPACING
			image.set_pixel(column, row, Color(height_at(x, z), 0.0, 0.0, 1.0))
	var images: Array[Image] = [image, null, null]
	_terrain.data.import_images(images, Vector3(-HALF_EXTENT, 0.0, -HALF_EXTENT), 0.0, 1.0)
	_terrain.data.calc_height_range(true)
	_build_ms = Time.get_ticks_msec() - start


## Assets mínimos de blockout: una textura de pradera y otra de roca. No son
## arte final; solo evitan el damero y permiten leer pendientes y valles.
func _build_terrain_assets() -> void:
	var grass: Terrain3DTextureAsset = _texture_asset(
		Color(0.38, 0.45, 0.30), "BlockoutPradera", 0
	)
	var rock: Terrain3DTextureAsset = _texture_asset(
		Color(0.50, 0.48, 0.44), "BlockoutRoca", 1
	)
	var assets: Terrain3DAssets = Terrain3DAssets.new()
	assets.texture_list = [grass, rock]
	_terrain.assets = assets


func _texture_asset(
	color: Color, asset_name: String, asset_id: int
) -> Terrain3DTextureAsset:
	var image: Image = Image.create(8, 8, false, Image.FORMAT_RGBA8)
	image.fill(color)
	image.generate_mipmaps()
	var texture: ImageTexture = ImageTexture.create_from_image(image)
	var asset: Terrain3DTextureAsset = Terrain3DTextureAsset.new()
	asset.name = asset_name
	asset.id = asset_id
	asset.albedo_color = Color.WHITE
	asset.albedo_texture = texture
	asset.roughness = 0.95
	asset.uv_scale = 0.05
	return asset


func _build_sector_markers() -> void:
	for id: StringName in SECTORS.keys():
		var center: Vector3 = SECTORS[id]
		var ground: float = height_at(center.x, center.z)
		var marker: MeshInstance3D = MeshInstance3D.new()
		var capsule: CylinderMesh = CylinderMesh.new()
		capsule.top_radius = 7.0
		capsule.bottom_radius = 13.0
		capsule.height = 40.0
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = _sector_color(id)
		capsule.material = material
		marker.mesh = capsule
		marker.position = Vector3(center.x, ground + 20.0, center.z)
		add_child(marker)
		var label: Label3D = Label3D.new()
		label.text = "%s · %d m" % [SECTOR_NAMES[id], int(ground)]
		label.font_size = 128
		label.pixel_size = 0.30
		label.outline_size = 24
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.no_depth_test = true
		label.position = Vector3(center.x, ground + SECTOR_LABEL_HEIGHT, center.z)
		add_child(label)


func _build_camera() -> void:
	_camera = Camera3D.new()
	_camera.name = "RegionCamera"
	_camera.current = true
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.size = 3000.0
	_camera.near = 100.0
	_camera.far = 12000.0
	_camera.position = Vector3(0.0, 8000.0, 0.0)
	_camera.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	add_child(_camera)


func _sector_color(id: StringName) -> Color:
	return SECTOR_COLORS.get(id, Color.WHITE)
