extends RefCounted
## Comprueba las capas y máscaras de colisión del jugador.


func test_player_collision_layers() -> bool:
	var packed: PackedScene = load("res://core/player/player_fps.tscn") as PackedScene
	if packed == null:
		return false
	var player: PlayerFPS = packed.instantiate() as PlayerFPS
	if player == null:
		return false
	# Capa 2: jugador. Máscara 25 = mundo (1) + personajes (8) + multitud (16):
	# el jugador no atraviesa a nadie.
	var ok: bool = player.collision_layer == 2 and player.collision_mask == 25
	player.free()
	return ok
