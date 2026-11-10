extends RefCounted
## Comprueba las capas y máscaras de colisión del jugador.


func test_player_collision_layers() -> bool:
	var packed: PackedScene = load("res://core/player/player_fps.tscn") as PackedScene
	if packed == null:
		return false
	var player: PlayerFPS = packed.instantiate() as PlayerFPS
	if player == null:
		return false
	var ok: bool = player.collision_layer == 2 and player.collision_mask == 9
	player.free()
	return ok
