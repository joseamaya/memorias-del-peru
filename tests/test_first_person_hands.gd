extends RefCounted
## Pruebas de la mano en primera persona.
##
## Comprueban que la malla propia tiene antebrazo, palma, dedos y uñas, y que
## el gesto de interacción la muestra sin depender de un asset externo.

const PLAYER_PATH: String = "res://core/player/player_fps.tscn"


func test_first_person_hand_geometry() -> bool:
	var packed: PackedScene = load(PLAYER_PATH) as PackedScene
	if packed == null:
		return false
	var player: PlayerFPS = packed.instantiate() as PlayerFPS
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	tree.root.add_child(player)
	var hand: FirstPersonHands = player.get_node_or_null(
		"Head/Camera3D/FirstPersonHands") as FirstPersonHands
	if hand == null:
		player.free()
		return false
	var meshes: Array[Node] = hand.find_children("*", "MeshInstance3D", true, false)
	var ok: bool = meshes.size() >= 20
	ok = ok and not hand.is_showing_hand()
	hand.play(&"offer")
	ok = ok and hand.is_showing_hand()
	ok = ok and hand.finger_curl() < 12.0
	hand.play(&"attack")
	ok = ok and hand.finger_curl() > 30.0
	player.free()
	return ok
