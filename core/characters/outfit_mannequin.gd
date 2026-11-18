class_name OutfitMannequin
extends Node3D
## Maniquí UAL1 con un [CharacterLook] y un clip nativo.
##
## Es la pieza de prototipo para el nuevo estilo de personajes: cuerpo de
## maniquí de dos superficies, atuendo de primitivas y animación UAL1. No conoce
## campañas ni la lógica de los actores.

const MODEL_PATH: String = "res://shared_assets/characters/mannequin/ual1_standard.glb"

@export var look: CharacterLook
@export var target_height: float = 1.65
## Clip nativo del UAL1: Idle, Walk, Jog_Fwd, Idle_Talking…
@export var clip: StringName = &"Idle"

var _model: Node3D = null
var _player: AnimationPlayer = null


func _ready() -> void:
	var packed: PackedScene = load(MODEL_PATH) as PackedScene
	if packed == null:
		return
	_model = packed.instantiate() as Node3D
	if _model == null:
		return
	add_child(_model)
	# El UAL1 mira hacia +Z. El nodo que lo contiene decide el giro de juego.
	ModelSlot.fit_height(_model, target_height)
	if look != null:
		CharacterOutfit.apply(_model, look)
	_player = _model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	_play_current()


## Aplica o cambia el atuendo.
func set_look(value: CharacterLook) -> void:
	look = value
	if _model != null and look != null:
		CharacterOutfit.apply(_model, look)


## Reproduce un clip nativo del maniquí.
func play(clip_name: StringName, speed: float = 1.0) -> void:
	clip = clip_name
	if _player == null:
		return
	_play_current(speed)


## Nodo del modelo cargado, para pruebas y capturas.
func model() -> Node3D:
	return _model


## Número de piezas de atuendo visibles.
func outfit_piece_count() -> int:
	return CharacterOutfit.piece_count(_model) if _model != null else 0


func _play_current(speed: float = 1.0) -> void:
	if _player == null or clip.is_empty() or not _player.has_animation(clip):
		return
	var animation: Animation = _player.get_animation(clip)
	if animation != null and clip in [&"Idle", &"Walk", &"Jog_Fwd", &"Idle_Talking"]:
		animation.loop_mode = Animation.LOOP_LINEAR
	_player.speed_scale = speed
	_player.play(clip, 0.15)
