extends RefCounted
## Comprueba que el murmullo de la plaza suena desde la noticia hasta la
## llamada, calla en las demás fases y que su recurso existe y es un WAV.

const WORLD_SCRIPT: String = "res://campaigns/01_pachacutec/scripts/world/mundo_base.gd"
const MURMUR_PATH: String = "res://shared_assets/audio/murmullo_plaza.wav"


func test_plaza_murmur_phases() -> bool:
	var world_script: GDScript = load(WORLD_SCRIPT) as GDScript
	if world_script == null:
		return false
	var ok: bool = true
	var expected: Dictionary[int, bool] = {
		MessengerEvent.Phase.IDLE: false,
		MessengerEvent.Phase.ARRIVAL: false,
		MessengerEvent.Phase.MESSAGE: true,
		MessengerEvent.Phase.CALL: true,
		MessengerEvent.Phase.DEPARTURE: false,
		MessengerEvent.Phase.DONE: false,
	}
	for phase: int in expected:
		var plays: bool = world_script.call("murmur_plays_in", phase)
		ok = ok and plays == expected[phase]
	ok = ok and ResourceLoader.exists(MURMUR_PATH)
	ok = ok and load(MURMUR_PATH) is AudioStreamWAV
	return ok
