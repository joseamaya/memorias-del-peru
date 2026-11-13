extends RefCounted
## Comprueba las manos en primera persona: el jugador las tiene ocultas, cada
## interactuable declara su gesto y «Hablar» no muestra ninguna mano.

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"


func test_first_person_hands() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var world: Node = (load(WORLD_PATH) as PackedScene).instantiate()
	tree.root.add_child(world)
	var player: Node = world.get_node_or_null("PlayerFPS")
	var hands: Node = world.get_node_or_null("PlayerFPS/Head/Camera3D/FirstPersonHands")
	var offering: OfrendaPachamama = world.get_node_or_null("OfrendaPachamama") as OfrendaPachamama
	var quero: QueroChicha = world.get_node_or_null("QueroChicha") as QueroChicha
	var pututu: Pututu = world.get_node_or_null("Pututu") as Pututu
	var talk: Interactable = world.get_node_or_null("Llacta/NPCs/Tejedora/Talk") as Interactable
	if player == null or hands == null or offering == null or quero == null or pututu == null or talk == null:
		world.free()
		return false
	var ok: bool = (
		hands.call("is_showing_hand") == false
		and hands.get_child_count() > 0
		and player.has_signal("interacted")
		and offering.hand_action == &"offer"
		and quero.hand_action == &"drink"
		and pututu.hand_action == &"blow"
		and talk.hand_action == &"none"
	)
	hands.call("play", &"offer")
	ok = ok and hands.call("is_showing_hand") == true
	hands.set("visible", false)
	player.emit_signal("interacted", offering)
	ok = ok and hands.call("is_showing_hand") == true
	hands.set("visible", false)
	world.free()
	return ok
