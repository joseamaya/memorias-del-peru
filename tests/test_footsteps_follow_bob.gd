extends RefCounted
## Comprueba los pasos del jugador: un paso por ciclo de balanceo, más
## frecuentes al correr, ninguno quieto o en el aire, y cada paso coincide con
## el punto bajo de la cámara.

const PLAYER_PATH: String = "res://core/player/player_fps.tscn"
const TICK: float = 1.0 / 60.0
const TICKS: int = 120


## Simula [constant TICKS] ticks y devuelve [pasos, pasos con la cámara baja].
func _simulate(speed: float, grounded: bool) -> Array[int]:
	var packed: PackedScene = load(PLAYER_PATH) as PackedScene
	var player: PlayerFPS = packed.instantiate() as PlayerFPS
	var steps: int = 0
	var low_steps: int = 0
	for _tick: int in range(TICKS):
		var offset: Vector3 = player.calculate_head_bob_offset(speed, grounded, TICK)
		if player.advance_footstep(speed, grounded, TICK):
			steps += 1
			if offset.y < 0.0:
				low_steps += 1
	player.free()
	var result: Array[int] = [steps, low_steps]
	return result


func test_footsteps_follow_bob() -> bool:
	var walk: Array[int] = _simulate(3.5, true)
	var run: Array[int] = _simulate(6.5, true)
	var still: Array[int] = _simulate(0.0, true)
	var airborne: Array[int] = _simulate(3.5, false)
	var ok: bool = true
	# 2 s caminando a ~2,2 Hz: 4 pasos; corriendo a 2,6 Hz: 5.
	ok = ok and walk[0] >= 4 and walk[0] <= 5
	ok = ok and run[0] > walk[0]
	ok = ok and still[0] == 0
	ok = ok and airborne[0] == 0
	ok = ok and walk[1] == walk[0]
	ok = ok and run[1] == run[0]
	return ok
