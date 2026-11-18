class_name FirstPersonHands
extends Node3D
## Mano de maniquí en primera persona para las interacciones.
##
## El antebrazo viene del UAL1 de Quaternius y la mano es una mano de maniquí
## con dedos separados (`MannequinHand`). Aparece al interactuar, entra hacia el
## centro y se retira; el interactuable elige la acción con `hand_action`.
## No tiene colisión ni participa en el raycast.

const REST_POSITION: Vector3 = Vector3(0.28, -0.24, -0.56)
const REST_ROTATION: Vector3 = Vector3(72.0, 45.0, 0.0)
const HAND_SCALE: float = 0.52
const REACH_SECONDS: float = 0.22
const HOLD_SECONDS: float = 0.18
const RETURN_SECONDS: float = 0.32

var _player: PlayerFPS = null
var _tween: Tween = null
var _hand: MannequinHand = null


func _ready() -> void:
	_hand = MannequinHand.new()
	_hand.name = "MannequinHand"
	_hand.grip = false
	_hand.scale = Vector3.ONE * HAND_SCALE
	_hand.position = REST_POSITION
	_hand.rotation_degrees = REST_ROTATION
	add_child(_hand)
	visible = false
	_player = _find_player()
	if _player != null:
		_player.interacted.connect(_on_interacted)


## Indica si la mano está en cuadro (para las pruebas).
func is_showing_hand() -> bool:
	return visible


## Mano de maniquí construida, para pruebas y capturas.
func mannequin_hand() -> MannequinHand:
	return _hand


## Reproduce la acción [param action]; `none` no hace nada.
func play(action: StringName) -> void:
	if action == &"none":
		return
	var target: Array = _action_target(action)
	if _tween != null and _tween.is_valid():
		_tween.kill()
	visible = true
	_hand.position = REST_POSITION
	_hand.rotation_degrees = REST_ROTATION
	_tween = create_tween()
	_tween.tween_property(_hand, "position", target[0], REACH_SECONDS) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(_hand, "rotation_degrees", target[1], REACH_SECONDS) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_interval(HOLD_SECONDS)
	_tween.tween_property(_hand, "position", REST_POSITION, RETURN_SECONDS) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.parallel().tween_property(_hand, "rotation_degrees", REST_ROTATION, RETURN_SECONDS) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.tween_callback(_hide_hand)


func _hide_hand() -> void:
	visible = false


func _on_interacted(interactable: Interactable) -> void:
	if interactable == null:
		return
	play(interactable.hand_action)


func _find_player() -> PlayerFPS:
	var node: Node = get_parent()
	while node != null and not (node is PlayerFPS):
		node = node.get_parent()
	return node as PlayerFPS


## Posición y giro de destino para cada acción. La mano no coge el objeto del
## mundo: entra hacia el centro y acompaña el gesto.
func _action_target(action: StringName) -> Array:
	match action:
		&"drink":
			return [Vector3(0.16, -0.18, -0.58), Vector3(70.0, 42.0, 4.0)]
		&"offer":
			return [Vector3(0.18, -0.20, -0.60), Vector3(72.0, 40.0, 2.0)]
		&"blow":
			return [Vector3(0.20, -0.18, -0.56), Vector3(70.0, 38.0, 4.0)]
		&"attack":
			return [Vector3(0.12, -0.24, -0.62), Vector3(78.0, 34.0, -6.0)]
		_:
			return [Vector3(0.18, -0.20, -0.60), Vector3(72.0, 40.0, 2.0)]
