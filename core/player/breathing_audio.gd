class_name BreathingAudio
extends AudioStreamPlayer
## Respiración del jugador atada al aliento.
##
## No hay barra fija: cuando el aliento baja, la respiración se oye más fuerte
## y más rápida. El sonido es de autoría propia y se sintetiza con
## `tools/synthesize_audio.py`.

const STREAM_PATH: String = "res://shared_assets/audio/respiracion.wav"
const MIN_INTERVAL: float = 2.4
const MAX_INTERVAL: float = 4.2
const SILENT_VOLUME: float = -60.0
const LOUD_VOLUME: float = -18.0

var _stamina: StaminaComponent = null
var _timer: float = 1.0


func _ready() -> void:
	if ResourceLoader.exists(STREAM_PATH):
		stream = load(STREAM_PATH) as AudioStream
	_stamina = StaminaComponent.find_in(get_parent())
	volume_db = SILENT_VOLUME
	play()


func _process(delta: float) -> void:
	if _stamina == null or stream == null:
		return
	var fatigue: float = 1.0 - _stamina.get_current() / maxf(_stamina.get_maximum(), 1.0)
	volume_db = lerpf(SILENT_VOLUME, LOUD_VOLUME, clampf(fatigue, 0.0, 1.0))
	pitch_scale = lerpf(0.96, 1.08, clampf(fatigue, 0.0, 1.0))
	_timer -= delta
	if _timer <= 0.0 and fatigue > 0.12:
		play()
		_timer = lerpf(MAX_INTERVAL, MIN_INTERVAL, clampf(fatigue, 0.0, 1.0))
