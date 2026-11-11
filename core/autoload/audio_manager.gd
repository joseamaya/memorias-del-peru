class_name AudioManagerService
extends Node
## Gestor mínimo de audio.
##
## Crea un bus de efectos y una pequeña reserva de reproductores para no cortar
## un sonido al reproducir otro.

const BUS_MASTER: StringName = &"Master"
const BUS_SFX: StringName = &"SFX"
const SFX_PLAYERS: int = 8

var _players: Array[AudioStreamPlayer] = []
var _next_player: int = 0


func _ready() -> void:
	_ensure_bus(BUS_SFX)
	for _index: int in range(SFX_PLAYERS):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.bus = BUS_SFX
		add_child(player)
		_players.append(player)


## Reproduce un efecto en el bus de efectos.
func play_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
	if stream == null or _players.is_empty():
		return
	var player: AudioStreamPlayer = _players[_next_player]
	_next_player = (_next_player + 1) % _players.size()
	player.stream = stream
	player.volume_db = volume_db
	player.play()


## Ajusta el volumen lineal (0–1) de un bus.
func set_bus_volume(bus_name: StringName, linear: float) -> void:
	var index: int = AudioServer.get_bus_index(bus_name)
	if index < 0:
		return
	AudioServer.set_bus_volume_db(index, linear_to_db(clampf(linear, 0.0, 1.0)))


## Detiene los efectos en curso y libera sus recursos.
func stop_all() -> void:
	for player: AudioStreamPlayer in _players:
		player.stop()
		player.stream = null


func _ensure_bus(bus_name: StringName) -> void:
	if AudioServer.get_bus_index(bus_name) >= 0:
		return
	AudioServer.add_bus()
	var index: int = AudioServer.bus_count - 1
	AudioServer.set_bus_name(index, bus_name)
	AudioServer.set_bus_send(index, BUS_MASTER)
