extends RefCounted
## Comprueba que el head bobbing no acumula desplazamiento al detenerse.


func test_head_bob_no_drift() -> bool:
	var player: PlayerFPS = PlayerFPS.new()
	var delta: float = 1.0 / 60.0
	for _tick: int in range(180):
		player.calculate_head_bob_offset(3.5, true, delta)
	for _tick: int in range(180):
		player.calculate_head_bob_offset(0.0, true, delta)
	var offset: Vector3 = player.calculate_head_bob_offset(0.0, true, delta)
	player.free()
	return offset.length() < 0.001
