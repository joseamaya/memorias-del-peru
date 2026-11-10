extends RefCounted
## Comprueba que el head bobbing no da saltos laterales ni verticales por tick.

const MAX_STEP: float = 0.02
const TICKS: int = 600


func test_head_bob_max_step() -> bool:
	var player: PlayerFPS = PlayerFPS.new()
	var delta: float = 1.0 / 60.0
	var previous: Vector3 = Vector3.ZERO
	var max_dx: float = 0.0
	var max_dy: float = 0.0
	for _tick: int in range(TICKS):
		var offset: Vector3 = player.calculate_head_bob_offset(6.5, true, delta)
		max_dx = maxf(max_dx, absf(offset.x - previous.x))
		max_dy = maxf(max_dy, absf(offset.y - previous.y))
		previous = offset
	for _tick: int in range(TICKS):
		var offset: Vector3 = player.calculate_head_bob_offset(3.5, true, delta)
		max_dx = maxf(max_dx, absf(offset.x - previous.x))
		max_dy = maxf(max_dy, absf(offset.y - previous.y))
		previous = offset
	player.free()
	return max_dx <= MAX_STEP and max_dy <= MAX_STEP
