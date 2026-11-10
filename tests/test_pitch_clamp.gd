extends RefCounted
## Comprueba el límite simétrico del pitch.


func test_pitch_clamp() -> bool:
	var limit: float = 80.0
	var high: float = PlayerFPS.clamp_pitch(deg_to_rad(400.0), limit)
	var low: float = PlayerFPS.clamp_pitch(deg_to_rad(-400.0), limit)
	return is_equal_approx(high, deg_to_rad(limit)) and is_equal_approx(low, deg_to_rad(-limit))
