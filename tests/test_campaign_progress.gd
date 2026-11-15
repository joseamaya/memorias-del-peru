extends RefCounted
## Comprueba que los recursos, el oficio y las habilidades del acto I llegan al
## acto II: el inventario y el estado del personaje sobreviven al cambio.

const ACT_ONE: String = "res://campaigns/01_pachacutec/scenes/world/llacta.tscn"
const ACT_TWO: String = "res://campaigns/01_pachacutec/scenes/world/paso.tscn"


func test_progress_between_acts() -> bool:
	CampaignState.clear()
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var world: Node = (load(ACT_ONE) as PackedScene).instantiate()
	if world == null:
		return false
	tree.root.add_child(world)
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var inventory: Inventory = player.get_node_or_null("Inventory") as Inventory
	var character: CharacterState = player.get_node_or_null("CharacterState") as CharacterState
	var ok: bool = player != null and inventory != null and character != null
	for task_name: String in ["TaskAgua", "TaskPirca"]:
		var task: TaskPoint = world.get_node_or_null(task_name) as TaskPoint
		if task == null:
			ok = false
			break
		task.interact(player)
	ok = ok and inventory.has(&"agua") and inventory.has(&"cuerda")
	ok = ok and character.get_skill(&"monte") >= 2
	ok = ok and CampaignProgress.get_oficio() == &"agua"
	CampaignProgress.save(world)
	world.free()

	var paso: Node = (load(ACT_TWO) as PackedScene).instantiate()
	if paso == null:
		CampaignState.clear()
		return false
	tree.root.add_child(paso)
	var paso_player: PlayerFPS = paso.get_node_or_null("PlayerFPS") as PlayerFPS
	var paso_inventory: Inventory = paso_player.get_node_or_null("Inventory") as Inventory
	var paso_character: CharacterState = paso_player.get_node_or_null("CharacterState") as CharacterState
	ok = ok and paso_player != null and paso_inventory != null and paso_character != null
	ok = ok and paso_inventory.has(&"agua") and paso_inventory.has(&"cuerda")
	ok = ok and paso_character.get_skill(&"monte") >= 2
	ok = ok and CampaignProgress.get_oficio() == &"agua"
	paso.free()
	CampaignState.clear()
	return ok
