extends RefCounted
## Comprueba que al dejar la ofrenda aparece un atado visible sobre el
## adoratorio: la interacción no puede quedarse en un simple temblor de la
## malla, porque entonces el jugador no ve que ha dejado nada (PCH-012).

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"


func test_offering_visual() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var world: Node = (load(WORLD_PATH) as PackedScene).instantiate()
	tree.root.add_child(world)
	var offering: OfrendaPachamama = world.get_node_or_null("OfrendaPachamama") as OfrendaPachamama
	var offering_node: Node3D = world.get_node_or_null("OfrendaPachamama") as Node3D
	var player: Node3D = world.get_node_or_null("PlayerFPS") as Node3D
	if offering == null or offering_node == null or player == null:
		world.free()
		return false
	offering.audio_stream = null
	var gift: Node3D = offering.get_node_or_null("Gift") as Node3D
	if gift == null:
		world.free()
		return false
	var slot: ModelSlot = gift.get_node_or_null("ModelSlot") as ModelSlot
	var offering_position: Vector3 = offering_node.global_position
	var rest_local: Vector3 = gift.position
	var rest_world: Vector3 = gift.global_position
	var ok: bool = (
		slot != null
		and slot.model != null
		and not offering.is_gift_visible()
		and not gift.is_visible_in_tree()
	)
	# El atado se apoya en la losa del adoratorio, no flota ni queda enterrado.
	ok = ok and absf(rest_world.y - (offering_position.y + 0.15)) < 0.02
	offering.interact(player)
	ok = ok and offering.used and not offering.is_available()
	ok = ok and offering.is_gift_visible() and gift.is_visible_in_tree()
	# Empieza a caer desde un palmo por encima del reposo.
	ok = ok and gift.position.y > rest_local.y + 0.05
	world.free()
	return ok
