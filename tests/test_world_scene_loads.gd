extends RefCounted
## Comprueba la composición de la escena del mundo base.


func test_world_scene_loads() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load("res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn") as PackedScene
	if packed == null:
		return false
	var world: Node = packed.instantiate()
	tree.root.add_child(world)
	var world_environment: WorldEnvironment = world.get_node_or_null("WorldEnvironment") as WorldEnvironment
	var sun: DirectionalLight3D = world.get_node_or_null("Inti") as DirectionalLight3D
	var terrain: Node3D = world.get_node_or_null("Terrain") as Node3D
	var spawn: Marker3D = world.get_node_or_null("PlayerSpawn") as Marker3D
	var audio: Node3D = world.get_node_or_null("EnvironmentAudio") as Node3D
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	var controller: EnvironmentQualityController = world.get_node_or_null("EnvironmentQualityController") as EnvironmentQualityController
	var terrain_mesh: MeshInstance3D = null
	var terrain_body: StaticBody3D = null
	if terrain != null:
		terrain_mesh = terrain.get_node_or_null("TerrainMesh") as MeshInstance3D
		terrain_body = terrain.get_node_or_null("TerrainBody") as StaticBody3D
	var ok: bool = (
		world_environment != null
		and world_environment.environment != null
		and sun != null
		and terrain != null
		and terrain_mesh != null
		and terrain_body != null
		and spawn != null
		and audio != null
		and player != null
		and hud != null
		and controller != null
	)
	world.free()
	return ok
