class_name GameManagerService
extends Node
## Estado global mínimo del juego.
##
## Gestiona la pausa y expone el estado mediante [signal pause_changed].
## También gobierna el cierre del juego para que termine sin fugas de audio.
## No conoce escenas de campaña concretas.

signal pause_changed(paused: bool)

## Tipos de reproductor que se detienen antes de cerrar.
const AUDIO_PLAYER_TYPES: Array[String] = [
	"AudioStreamPlayer",
	"AudioStreamPlayer2D",
	"AudioStreamPlayer3D",
]

## Milisegundos de tiempo real entre detener el audio y salir.
const QUIT_AUDIO_DRAIN_MS: int = 250

var _paused: bool = false
var _quitting: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# El cierre de ventana pasa por request_quit(): en Godot 4.7.2, cerrar con un
	# flujo Ogg sonando deja la reproducción sin liberar y el motor imprime
	# «resources still in use at exit». Detenerla poco antes de salir lo evita.
	get_tree().auto_accept_quit = false


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		request_quit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		set_paused(not _paused)
		get_viewport().set_input_as_handled()


## Cambia el estado de pausa. No emite la señal si el valor no cambia.
func set_paused(paused: bool) -> void:
	if paused == _paused:
		return
	_paused = paused
	get_tree().paused = paused
	pause_changed.emit(paused)


## Devuelve el estado de pausa actual.
func is_paused() -> bool:
	return _paused


## Cierra el juego de forma ordenada: detiene todo el audio, deja pasar un
## fotograma para que el servidor de audio suelte las reproducciones y sale.
## Las llamadas repetidas durante el cierre se ignoran.
func request_quit(exit_code: int = 0) -> void:
	if _quitting:
		return
	_quitting = true
	var tree: SceneTree = get_tree()
	# Se pausa el árbol antes de barrer el audio: si los personajes siguen
	# procesando durante el drenaje, un paso o un golpe de trabajo puede
	# arrancar una reproducción nueva después del barrido y quedar viva al salir.
	tree.paused = true
	stop_audio_in(tree.root)
	# Se espera tiempo real, no fotogramas: sin vsync un fotograma puede durar
	# menos de un milisegundo y el hilo de audio aún no habría soltado nada.
	var deadline: int = Time.get_ticks_msec() + QUIT_AUDIO_DRAIN_MS
	await tree.process_frame
	while Time.get_ticks_msec() < deadline:
		await tree.process_frame
	tree.quit(exit_code)


## Detiene todos los reproductores de audio bajo [param root], incluido él
## mismo. Devuelve cuántos estaban sonando.
static func stop_audio_in(root: Node) -> int:
	if root == null:
		return 0
	var stopped: int = 0
	var players: Array[Node] = []
	for type_name: String in AUDIO_PLAYER_TYPES:
		if root.is_class(type_name):
			players.append(root)
		players.append_array(root.find_children("*", type_name, true, false))
	for node: Node in players:
		if _stop_player(node):
			stopped += 1
	return stopped


## Detiene un reproductor de cualquiera de los tres tipos y suelta su flujo.
## Devuelve `true` si estaba sonando.
##
## Soltar el flujo es lo que evita el «resources still in use at exit» de Godot
## 4.7.2: parar la reproducción no basta si el nodo conserva la referencia.
static func _stop_player(node: Node) -> bool:
	var was_playing: bool = false
	if node is AudioStreamPlayer:
		var player: AudioStreamPlayer = node as AudioStreamPlayer
		was_playing = player.playing
		player.stop()
		player.stream = null
	elif node is AudioStreamPlayer2D:
		var player_2d: AudioStreamPlayer2D = node as AudioStreamPlayer2D
		was_playing = player_2d.playing
		player_2d.stop()
		player_2d.stream = null
	elif node is AudioStreamPlayer3D:
		var player_3d: AudioStreamPlayer3D = node as AudioStreamPlayer3D
		was_playing = player_3d.playing
		player_3d.stop()
		player_3d.stream = null
	return was_playing
