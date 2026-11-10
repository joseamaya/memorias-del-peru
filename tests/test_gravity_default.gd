extends RefCounted
## Comprueba que la gravedad por defecto sale de ProjectSettings.


func test_gravity_default() -> bool:
	var player: PlayerFPS = PlayerFPS.new()
	var expected: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
	var ok: bool = is_equal_approx(player.gravity, expected)
	player.free()
	return ok
