extends RefCounted
## Comprueba que un punto de control restaura salud, aliento, inventario y
## posición, y que el respawn se marca para la siguiente carga.

const PASO: String = "res://campaigns/01_pachacutec/scenes/world/paso.tscn"


func test_checkpoint_restores_state() -> bool:
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
	var stamina: StaminaComponent = player.stamina
	var ok: bool = player != null and character != null and inventory != null and stamina != null
	character.damage(40.0)
	stamina.consume(30.0)
	inventory.remove(&"coca", 1)
	var checkpoint: Vector3 = Vector3(1.0, 0.0, 2.0)
	player.global_position = checkpoint
	CampaignProgress.save_checkpoint(world, checkpoint)
	# Se ensucia el estado después del punto de control.
	character.heal(50.0)
	stamina.restore(30.0)
	inventory.add(CampaignProgress.item_definition(&"agua"), 1)
	player.global_position = Vector3(8.0, 0.0, 8.0)
	CampaignProgress.request_respawn()
	ok = ok and CampaignProgress.is_respawn_pending()
	ok = ok and CampaignProgress.restore_checkpoint(world)
	ok = ok and is_equal_approx(character.get_health(), 60.0)
	ok = ok and is_equal_approx(stamina.get_current(), stamina.get_maximum() - 30.0)
	ok = ok and inventory.count(&"coca") == 1
	ok = ok and not inventory.has(&"agua")
	ok = ok and player.global_position.distance_to(checkpoint) < 0.01
	ok = ok and not CampaignProgress.is_respawn_pending()
	world.free()
	CampaignState.clear()
	return ok
