extends RefCounted
## La acción `jump` debe despegar al jugador cuando está en el suelo.

const PLAYER_PATH: String = "res://core/player/player_fps.tscn"


func test_jump_requires_ground_and_free_controls() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load(PLAYER_PATH) as PackedScene
	if packed == null:
		return false
	var player: PlayerFPS = packed.instantiate() as PlayerFPS
	if player == null:
		return false
	tree.root.add_child(player)
	player.jump.request(true, true, false)
	var ok: bool = player.jump.apply(player, true, false)
	ok = ok and is_equal_approx(player.velocity.y, player.jump.velocity)
	player.velocity.y = 0.0
	player.jump.request(true, false, false)
	ok = ok and not player.jump.apply(player, false, false)
	ok = ok and is_zero_approx(player.velocity.y)
	player.set_controls_locked(true)
	player.jump.request(true, true, true)
	ok = ok and not player.jump.apply(player, true, true)
	ok = ok and is_zero_approx(player.velocity.y)
	player.set_controls_locked(false)
	player.free()
	return ok
