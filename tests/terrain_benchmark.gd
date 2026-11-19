class_name TerrainBenchmark
extends Node3D
## Escena de medición para el spike de Terrain3D.
##
## Construye el mismo sector con dos suelos posibles: Terrain3D o una malla
## simple. La cámara recorre un órbita fija para que las pasadas sean
## comparables. No forma parte del juego: es una herramienta de F1.

@export var use_terrain: bool = true
@export var size_meters: int = 512
@export var tree_count: int = 50
@export var npc_count: int = 20

var _camera: Camera3D = null
var _terrain: Terrain3D = null
var _elapsed: float = 0.0


func _ready() -> void:
	_build_environment()
	_build_camera()
	_build_ground()
	_build_props()
	set_process(true)


func _process(delta: float) -> void:
	_elapsed += delta
	if _camera == null:
		return
	var angle: float = _elapsed * 0.12
	var radius: float = 70.0
	var height: float = 14.0 + sin(_elapsed * 0.3) * 2.0
	_camera.position = Vector3(cos(angle) * radius, height, sin(angle) * radius)
	_camera.look_at(Vector3(0.0, 2.0, 0.0), Vector3.UP)


## Altura del terreno de referencia; la malla y Terrain3D usan la misma forma.
func height_at(x: float, z: float) -> float:
	return sin(x * 0.02) * 6.0 + cos(z * 0.025) * 5.0 + sin((x + z) * 0.01) * 3.0


func _build_environment() -> void:
	var environment: Environment = Environment.new()
	environment.background_mode = Environment.BG_SKY
	var sky: Sky = Sky.new()
	var sky_material: ProceduralSkyMaterial = ProceduralSkyMaterial.new()
	sky.sky_material = sky_material
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


func _build_ground() -> void:
	if use_terrain:
		_build_terrain()
	else:
		_build_mesh_ground()


func _build_terrain() -> void:
	_terrain = Terrain3D.new()
	_terrain.name = "Terrain3D"
	_terrain.region_size = Terrain3D.SIZE_256
	_terrain.vertex_spacing = 1.0
	_terrain.free_editor_textures = false
	_terrain.set("collision_mode", 3)
	add_child(_terrain)
	var image: Image = Image.create(size_meters, size_meters, false, Image.FORMAT_RF)
	for y: int in size_meters:
		for x: int in size_meters:
			var wx: float = float(x) - float(size_meters) * 0.5
			var wz: float = float(y) - float(size_meters) * 0.5
			image.set_pixel(x, y, Color(height_at(wx, wz), 0.0, 0.0, 1.0))
	var images: Array[Image] = [image, null, null]
	_terrain.data.import_images(
		images, Vector3(-float(size_meters) * 0.5, 0.0, -float(size_meters) * 0.5), 0.0, 1.0
	)
	_terrain.data.calc_height_range(true)
	_terrain.clipmap_target = _camera
	_terrain.set("collision_target", _camera)


func _build_mesh_ground() -> void:
	var step: float = 2.0
	var half: float = float(size_meters) * 0.5
	var steps: int = int(float(size_meters) / step)
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for z: int in steps + 1:
		for x: int in steps + 1:
			var wx: float = -half + float(x) * step
			var wz: float = -half + float(z) * step
			surface.add_vertex(Vector3(wx, height_at(wx, wz), wz))
	for z: int in steps:
		for x: int in steps:
			var index: int = z * (steps + 1) + x
			surface.add_index(index)
			surface.add_index(index + steps + 1)
			surface.add_index(index + 1)
			surface.add_index(index + 1)
			surface.add_index(index + steps + 1)
			surface.add_index(index + steps + 2)
	surface.generate_normals()
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.45, 0.42, 0.32)
	material.roughness = 0.95
	surface.set_material(material)
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = "MeshGround"
	mesh_instance.mesh = surface.commit()
	add_child(mesh_instance)
	mesh_instance.create_trimesh_collision()


func _build_props() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 20261119
	_add_multimesh(_tree_mesh(), tree_count, rng, 25.0, 230.0, 1.0)
	_add_multimesh(_npc_mesh(), npc_count, rng, 6.0, 30.0, 1.0)


func _add_multimesh(
	mesh: Mesh,
	count: int,
	rng: RandomNumberGenerator,
	min_radius: float,
	max_radius: float,
	model_scale: float
) -> void:
	var multimesh: MultiMesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = mesh
	multimesh.instance_count = count
	for index: int in count:
		var angle: float = rng.randf() * TAU
		var radius: float = rng.randf_range(min_radius, max_radius)
		var x: float = cos(angle) * radius
		var z: float = sin(angle) * radius
		var y: float = height_at(x, z)
		multimesh.set_instance_transform(
			index, Transform3D(Basis().scaled(Vector3.ONE * model_scale), Vector3(x, y, z))
		)
	var instance: MultiMeshInstance3D = MultiMeshInstance3D.new()
	instance.multimesh = multimesh
	add_child(instance)


func _tree_mesh() -> Mesh:
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = 0.25
	mesh.bottom_radius = 0.45
	mesh.height = 4.0
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.25, 0.35, 0.18)
	mesh.material = material
	return mesh


func _npc_mesh() -> Mesh:
	var mesh: CapsuleMesh = CapsuleMesh.new()
	mesh.radius = 0.35
	mesh.height = 1.7
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.55, 0.40, 0.30)
	mesh.material = material
	return mesh


func _build_camera() -> void:
	_camera = Camera3D.new()
	_camera.name = "BenchmarkCamera"
	_camera.current = true
	_camera.fov = 70.0
	_camera.position = Vector3(0.0, 14.0, 70.0)
	add_child(_camera)
