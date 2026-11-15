extends RefCounted
## Comprueba que el sigilo exige Monte y que la cuerda se consume al distraer.

const PASO: String = "res://campaigns/01_pachacutec/scenes/world/paso.tscn"


func test_sneak_and_distraction() -> bool:
	CampaignState.clear()
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var world: Node = (load(PASO) as PackedScene).instantiate()
	if world == null:
		return false
	tree.root.add_child(world)
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var character: CharacterState = player.get_node_or_null("CharacterState") as CharacterState
	var inventory: Inventory = player.get_node_or_null("Inventory") as Inventory
	var ok: bool = player != null and character != null and inventory != null
	character.register_skill_use(&"monte", 8)
	world.call("_on_sneak_requested")
	ok = ok and CampaignState.has_flag(&"mensaje_chanca")
	ok = ok and CampaignState.has_flag(&"paso_cruzado")
	inventory.add(CampaignProgress.item_definition(&"cuerda"), 1)
	world.call("_on_distract_requested")
	ok = ok and CampaignState.has_flag(&"distraccion_cuerda")
	ok = ok and not inventory.has(&"cuerda")
	world.free()
	CampaignState.clear()
	return ok
