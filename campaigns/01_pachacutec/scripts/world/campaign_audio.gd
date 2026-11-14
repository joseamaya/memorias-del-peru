class_name CampaignAudio
extends RefCounted
## Audio de ambiente y combate de los actos II y III.
##
## Reutiliza el viento de la llacta y añade agua, fuego, murmullo, tambor y
## golpes sintetizados para la campaña. Bajo el driver «Dummy» no crea nodos:
## las pruebas sin pantalla no liberan las reproducciones.

const AMBIENCE_PATH: String = "res://shared_assets/audio/ambiente_viento_andes.ogg"
const MURMUR_PATH: String = "res://shared_assets/audio/murmullo_plaza.wav"
const WATER_PATH: String = "res://shared_assets/audio/agua_arroyo.wav"
const FIRE_PATH: String = "res://shared_assets/audio/fuego_campamento.wav"
const DRUM_PATH: String = "res://shared_assets/audio/tambor_defensa.wav"
const WHOOSH_PATH: String = "res://shared_assets/audio/honda_zumbido.wav"
const IMPACT_PATH: String = "res://shared_assets/audio/honda_impacto.wav"
const PORRA_PATH: String = "res://shared_assets/audio/golpe_porra.wav"
const DIRT_FOOTSTEPS: Array[String] = [
	"res://shared_assets/audio/pasos_tierra_01.wav",
	"res://shared_assets/audio/pasos_tierra_02.wav",
	"res://shared_assets/audio/pasos_tierra_03.wav",
]
const STONE_FOOTSTEPS: Array[String] = [
	"res://shared_assets/audio/pasos_piedra_01.wav",
	"res://shared_assets/audio/pasos_piedra_02.wav",
	"res://shared_assets/audio/pasos_piedra_03.wav",
]


## Indica si el motor de audio es el driver mudo de las pruebas sin pantalla.
static func is_dummy() -> bool:
	return AudioServer.get_driver_name() == "Dummy"


## Pasos del jugador en tierra y en piedra.
static func setup_footsteps(player: PlayerFPS) -> void:
	if is_dummy() or player == null:
		return
	player.footstep_streams = load_streams(DIRT_FOOTSTEPS)
	var stone: FootstepSet = FootstepSet.new()
	stone.surface = &"stone"
	stone.streams = load_streams(STONE_FOOTSTEPS)
	var sets: Array[FootstepSet] = [stone]
	player.footstep_sets = sets


## Viento global; el [LlactaWind] puede modular su volumen con la ráfaga.
static func add_wind(parent: Node, volume_db: float = -18.0) -> AudioStreamPlayer:
	if is_dummy():
		return null
	var stream: AudioStream = load_loop(AMBIENCE_PATH)
	if stream == null:
		return null
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.name = "WindAmbience"
	player.stream = stream
	player.volume_db = volume_db
	player.autoplay = true
	parent.add_child(player)
	return player


## Bucle posicional (agua, fuego, murmullo).
static func add_loop_3d(
	parent: Node3D,
	node_name: String,
	path: String,
	at: Vector3,
	volume_db: float,
	unit_size: float,
	max_distance: float
) -> AudioStreamPlayer3D:
	if is_dummy():
		return null
	var stream: AudioStream = load_loop(path)
	if stream == null:
		return null
	var player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	player.name = node_name
	player.stream = stream
	player.volume_db = volume_db
	player.unit_size = unit_size
	player.max_distance = max_distance
	player.autoplay = true
	parent.add_child(player)
	player.global_position = at
	return player


## Bucle no posicional (tambor de combate).
static func add_loop(
	parent: Node,
	node_name: String,
	path: String,
	volume_db: float,
	autoplay: bool = true
) -> AudioStreamPlayer:
	if is_dummy():
		return null
	var stream: AudioStream = load_loop(path)
	if stream == null:
		return null
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.name = node_name
	player.stream = stream
	player.volume_db = volume_db
	player.autoplay = autoplay
	parent.add_child(player)
	return player


## Efecto puntual en el bus SFX.
static func play_sfx(path: String, volume_db: float = 0.0) -> void:
	if is_dummy() or not ResourceLoader.exists(path):
		return
	var stream: AudioStream = load(path) as AudioStream
	var audio: AudioManagerService = AudioManagerService.instance()
	if stream != null and audio != null:
		audio.play_sfx(stream, volume_db)


## Carga un bucle y activa la repetición según el formato.
static func load_loop(path: String) -> AudioStream:
	if not ResourceLoader.exists(path):
		return null
	var stream: AudioStream = load(path) as AudioStream
	if stream is AudioStreamWAV:
		var wav: AudioStreamWAV = stream as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_end = roundi(wav.get_length() * float(wav.mix_rate))
	elif stream is AudioStreamOggVorbis:
		var ogg: AudioStreamOggVorbis = stream as AudioStreamOggVorbis
		ogg.loop = true
	return stream


static func load_streams(paths: Array[String]) -> Array[AudioStream]:
	var streams: Array[AudioStream] = []
	for path: String in paths:
		if not ResourceLoader.exists(path):
			continue
		var stream: AudioStream = load(path) as AudioStream
		if stream != null:
			streams.append(stream)
	return streams
