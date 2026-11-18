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
	_model = attach_look(self, look)
	if _model == null:
		return
	ModelSlot.fit_height(_model, target_height)
	_player = _model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	_play_current()


## Carga el UAL1, lo cuelga de [param parent] y le aplica el atuendo. El
## llamador decide la altura y lo anima: sirve para el prototipo y para los
## actores del juego sin duplicar la carga del modelo.
static func attach_look(parent: Node3D, target_look: CharacterLook) -> Node3D:
	var packed: PackedScene = load(MODEL_PATH) as PackedScene
	if packed == null or parent == null:
		return null
	var model_node: Node3D = packed.instantiate() as Node3D
	if model_node == null:
		return null
	model_node.name = "MannequinModel"
	parent.add_child(model_node)
	if target_look != null:
		CharacterOutfit.apply(model_node, target_look)
	return model_node


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
