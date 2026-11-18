extends RefCounted
## Comprueba que la llacta del acto I carga con terreno, viviendas, terrazas,
## corrales, límites, jugador y HUD.

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/llacta.tscn"


func test_llacta_loads() -> bool:
	CampaignState.clear()
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load(WORLD_PATH) as PackedScene
	if packed == null:
		return false
	var world: Node = packed.instantiate()
	if world == null:
		return false
	tree.root.add_child(world)
	var terrain: Node = world.get_node_or_null("Terrain")
	var terrain_mesh: MeshInstance3D = terrain.get_node_or_null("TerrainMesh") as MeshInstance3D
	var terrain_body: StaticBody3D = terrain.get_node_or_null("TerrainBody") as StaticBody3D
	var collision: CollisionShape3D = null
	if terrain_body != null:
		collision = terrain_body.get_node_or_null("TerrainCollision") as CollisionShape3D
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	var houses: Node = world.get_node_or_null("Llacta/Houses")
	var terraces: Node = world.get_node_or_null("Llacta/Terraces")
	var corrals: Node = world.get_node_or_null("Llacta/Corrals")
	var npcs: Node = world.get_node_or_null("Llacta/NPCs")
	var boundary: Node = world.get_node_or_null("Boundary")
	var tasks: int = 0
	for task_id: String in ["TaskAgua", "TaskMaiz", "TaskTelar", "TaskPirca"]:
		if world.get_node_or_null(task_id) != null:
			tasks += 1
	var ok: bool = terrain_mesh != null and terrain_mesh.mesh != null
	ok = ok and collision != null and collision.shape is ConcavePolygonShape3D
	ok = ok and player != null and hud != null
	ok = ok and hud.player == player and hud.stamina == player.stamina
	ok = ok and houses != null and houses.get_child_count() == 8
	ok = ok and terraces != null and terraces.get_child_count() >= 3
	ok = ok and corrals != null and corrals.get_child_count() == 2
	ok = ok and npcs != null and npcs.get_child_count() == 8
	ok = ok and tasks == 4
	ok = ok and boundary != null and boundary.get_child_count() == 5
	ok = ok and not hud.get_objective_text().is_empty()
	ok = ok and not hud.get_objective_text().begins_with("PCH_")
	ok = ok and world.get_node_or_null("UILayer/IntroCards") != null
	world.free()
	CampaignState.clear()
	return ok
