class_name OfrendaPachamama
extends Interactable
## Adoratorio de ofrenda a la Pachamama.
##
## Solo puede usarse una vez por partida. No conoce la UI. Al dejar la ofrenda
## aparece el atado de coca y maíz sobre la losa (PCH-012): la respuesta tiene
## que verse, no solo oírse.

signal offered

## Altura desde la que cae el atado y tiempo que tarda en asentarse.
const GIFT_DROP_HEIGHT: float = 0.12
const GIFT_DROP_SECONDS: float = 0.3
const GIFT_START_SCALE: float = 0.6
const GIFT_START_YAW_DEGREES: float = -8.0

@export var gift: Node3D
@export var audio_stream: AudioStream

var used: bool = false
var _gift_node: Node3D = null
var _gift_rest_position: Vector3 = Vector3.ZERO
var _gift_tween: Tween = null


func _ready() -> void:
	_gift_node = gift
	if _gift_node == null:
		_gift_node = get_node_or_null("Gift") as Node3D
	if _gift_node != null:
		_gift_rest_position = _gift_node.position
		_gift_node.visible = false
		_gift_node.scale = Vector3.ONE


func get_interaction_text() -> String:
	return tr("PCH_OFFERING_INTERACT")


## Una vez dejada la ofrenda deja de enfocarse: el HUD no ofrece una acción
## que ya no responde (ADR-0008).
func is_available() -> bool:
	return not used


## Indica si el atado ya está a la vista (para las pruebas).
func is_gift_visible() -> bool:
	return _gift_node != null and _gift_node.visible


func interact(_interactor: Node3D) -> void:
	if used:
		return
	used = true
	if audio_stream != null:
		AudioManager.play_sfx(audio_stream)
	offered.emit()
	_place_gift()


## Deja el atado sobre la losa: cae desde un palmo de altura y se asienta.
## El sonido y la aparición son la respuesta visible de la interacción.
func _place_gift() -> void:
	if _gift_node == null:
		return
	if _gift_tween != null and _gift_tween.is_valid():
		_gift_tween.kill()
	_gift_node.visible = true
	_gift_node.position = _gift_rest_position + Vector3(0.0, GIFT_DROP_HEIGHT, 0.0)
	_gift_node.scale = Vector3.ONE * GIFT_START_SCALE
	_gift_node.rotation.y = deg_to_rad(GIFT_START_YAW_DEGREES)
	_gift_tween = create_tween()
	_gift_tween.set_parallel(true)
	_gift_tween.tween_property(_gift_node, "position", _gift_rest_position, GIFT_DROP_SECONDS) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_gift_tween.tween_property(_gift_node, "scale", Vector3.ONE, GIFT_DROP_SECONDS) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_gift_tween.tween_property(_gift_node, "rotation:y", 0.0, GIFT_DROP_SECONDS) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
