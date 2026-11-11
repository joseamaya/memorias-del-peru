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
	_add_visual_box(llacta, "PathEast", Vector3(20.0, 0.035, 0.0), Vector3(30.0, 0.07, 4.0), dirt)
	_add_visual_box(llacta, "PathWest", Vector3(-20.0, 0.035, 0.0), Vector3(30.0, 0.07, 4.0), dirt)

	var houses: Node3D = Node3D.new()
	houses.name = "Houses"
	llacta.add_child(houses)
	var positions: Array[Vector3] = [
		Vector3(18.0, 0.0, 0.0),
		Vector3(12.7, 0.0, 12.7),
		Vector3(0.0, 0.0, 18.0),
		Vector3(-12.7, 0.0, 12.7),
		Vector3(-18.0, 0.0, 0.0),
		Vector3(-12.7, 0.0, -12.7),
		Vector3(0.0, 0.0, -18.0),
		Vector3(12.7, 0.0, -12.7),
	]
	for index: int in range(positions.size()):
		_add_house(houses, index, positions[index], stone, thatch)

	var terraces: Node3D = Node3D.new()
	terraces.name = "Terraces"
	llacta.add_child(terraces)
	_add_box_body(terraces, "Terrace01", Vector3(34.0, 0.4, 0.0), Vector3(8.0, 0.8, 30.0), stone, 1)
	_add_box_body(terraces, "Terrace02", Vector3(42.0, 1.2, 0.0), Vector3(8.0, 0.8, 30.0), stone, 1)
	_add_box_body(terraces, "Terrace03", Vector3(50.0, 2.0, 0.0), Vector3(8.0, 0.8, 30.0), stone, 1)

	_add_box_body(llacta, "PedestalQuero", Vector3(4.0, 0.4, 4.0), Vector3(0.6, 0.8, 0.6), stone, 1)
	_add_box_body(llacta, "PedestalPututu", Vector3(-4.0, 0.4, 4.0), Vector3(0.6, 0.8, 0.6), stone, 1)

	_add_box_body(boundary, "North", Vector3(0.0, 1.0, -BOUNDARY_RADIUS), Vector3(BOUNDARY_RADIUS * 2.0, 2.0, 1.0), stone, 1)
	_add_box_body(boundary, "South", Vector3(0.0, 1.0, BOUNDARY_RADIUS), Vector3(BOUNDARY_RADIUS * 2.0, 2.0, 1.0), stone, 1)
	_add_box_body(boundary, "East", Vector3(BOUNDARY_RADIUS, 1.0, 0.0), Vector3(1.0, 2.0, BOUNDARY_RADIUS * 2.0), stone, 1)
	_add_box_body(boundary, "West", Vector3(-BOUNDARY_RADIUS, 1.0, 0.0), Vector3(1.0, 2.0, BOUNDARY_RADIUS * 2.0), stone, 1)

	var npcs: Node3D = Node3D.new()
	npcs.name = "NPCs"
	llacta.add_child(npcs)
	var weaver: Node3D = _add_npc(npcs, "Tejedora", Vector3(-11.0, 0.0, 5.0), Color(0.62, 0.38, 0.3, 1.0))
	var farmer: Node3D = _add_npc(npcs, "Agricultor", Vector3(30.0, 0.0, -8.0), Color(0.45, 0.35, 0.25, 1.0))
	var chasqui: Node3D = _add_npc(npcs, "Chasqui", Vector3(0.0, 0.0, -60.0), Color(0.75, 0.65, 0.4, 1.0))

	var event: ChasquiEvent = $EventController as ChasquiEvent
	var pututu: Pututu = $Pututu as Pututu
	var plaza_point: Marker3D = $PlazaPoint as Marker3D
	if event != null:
		event.bind(chasqui, weaver, farmer, plaza_point)
		if pututu != null:
			pututu.played.connect(event.start)


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


func _add_npc(parent: Node3D, node_name: String, at: Vector3, color: Color) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = node_name
	root.position = at
	parent.add_child(root)
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.position = Vector3(0.0, 0.85, 0.0)
	var capsule: CapsuleMesh = CapsuleMesh.new()
	capsule.radius = 0.3
	capsule.height = 1.7
	mesh_instance.mesh = capsule
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	mesh_instance.material_override = material
	root.add_child(mesh_instance)
	var body: StaticBody3D = StaticBody3D.new()
	body.collision_layer = 8
	body.collision_mask = 0
	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.position = Vector3(0.0, 0.85, 0.0)
	var shape: CapsuleShape3D = CapsuleShape3D.new()
	shape.radius = 0.3
	shape.height = 1.7
	collision.shape = shape
	body.add_child(collision)
	root.add_child(body)
	root.add_to_group("npcs")
	var tween: Tween = create_tween().set_loops()
	tween.tween_property(mesh_instance, "position:y", 0.03, 0.9).as_relative()
	tween.tween_property(mesh_instance, "position:y", -0.03, 0.9).as_relative()
	return root
