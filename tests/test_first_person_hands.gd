extends RefCounted
## Pruebas de la mano en primera persona.
##
## Comprueban que la mano de maniquí tiene antebrazo, palma y dedos separados,
## que el gesto de interacción la muestra y que el arma sujeta con un puño
## cerrado, sin depender de la mano detallada.

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
	var mannequin: MannequinHand = hand.mannequin_hand()
	var ok: bool = mannequin != null and mannequin.piece_count() == 2
	ok = ok and not mannequin.is_gripping()
	ok = ok and not hand.is_showing_hand()
	hand.play(&"offer")
	ok = ok and hand.is_showing_hand()
	hand.play(&"attack")
	ok = ok and hand.is_showing_hand()
	var weapon: FirstPersonWeapon = player.get_node_or_null(
		"Head/Camera3D/FirstPersonWeapon") as FirstPersonWeapon
	ok = ok and weapon != null
	var grip_hands: int = 0
	if weapon != null:
		for node: Node in weapon.find_children("*", "Node3D", true, false):
			if node is MannequinHand:
				var grip_hand: MannequinHand = node as MannequinHand
				grip_hands += 1
				ok = ok and grip_hand.is_gripping()
				ok = ok and grip_hand.piece_count() == 2
	ok = ok and grip_hands == 2
	player.free()
	return ok
