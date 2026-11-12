class_name LlactaWind
extends Node
## Viento de la llacta: una ráfaga lenta y variable (0–1) que mece la
## vegetación y sube el volumen del ambiente de viento al mismo tiempo, para
## que lo que se ve y lo que se oye vayan juntos.

## Segundos que tarda la ráfaga en recorrer su ruido (cuanto más, más lenta).
const GUST_PERIOD: float = 9.0
## Variación del ambiente de viento con la ráfaga, en dB.
const AMBIENCE_GUST_DB: float = 5.0

## Materiales que reciben `wind_gust`.
var materials: Array[ShaderMaterial] = []
## Ambiente de viento cuyo volumen sigue la ráfaga (puede faltar).
var ambience: AudioStreamPlayer = null
## Volumen del ambiente sin ráfaga.
var ambience_base_db: float = -16.0
var gust: float = 0.0

var _noise: FastNoiseLite = FastNoiseLite.new()
var _time: float = 0.0


func _init() -> void:
	_noise.seed = 7
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise.frequency = 1.0


func _process(delta: float) -> void:
	advance(delta)


## Avanza el viento [param delta] segundos y aplica la ráfaga.
func advance(delta: float) -> void:
	_time += delta
	gust = gust_at(_time)
	for material: ShaderMaterial in materials:
		material.set_shader_parameter("wind_gust", gust)
	if ambience != null:
		ambience.volume_db = ambience_base_db + (gust - 0.5) * AMBIENCE_GUST_DB


## Ráfaga en el segundo [param seconds]: ruido suave reescalado a 0–1, con
## más tiempo en calma que en ráfaga.
func gust_at(seconds: float) -> float:
	var value: float = _noise.get_noise_1d(seconds / GUST_PERIOD) * 0.5 + 0.5
	return smoothstep(0.25, 0.85, value)
