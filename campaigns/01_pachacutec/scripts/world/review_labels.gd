class_name ReviewLabels
extends Node
## Etiquetas de POI del blockout: ocultas por defecto y una sola con H.
##
## Solo gobierna las etiquetas del grupo `review_label`; las de interacción
## (puertas, lechos) quedan siempre visibles. La más cercana al jugador se
## muestra con su tamaño de revisión.

const LIMIT: int = 1
const PIXEL_SIZE: float = 0.03
const OUTLINE: int = 8

var _streamer: SectorStreamer = null
var _target: Node3D = null
var _visible: bool = false


func setup(streamer: SectorStreamer, target: Node3D) -> void:
	_streamer = streamer
	_target = target


func toggle() -> void:
	_visible = not _visible
	update()


func is_visible() -> bool:
	return _visible


func get_visible_count() -> int:
	var count: int = 0
	for label: Label3D in _candidates():
		if label.visible:
			count += 1
	return count


## Aplica la visibilidad de revisión a las etiquetas de los sectores cargados.
func update() -> void:
	var labels: Array[Label3D] = _candidates()
	for index: int in labels.size():
		var label: Label3D = labels[index]
		label.visible = _visible and index < LIMIT
		if label.visible:
			label.pixel_size = PIXEL_SIZE
			label.outline_size = OUTLINE


## Etiquetas de revisión de los sectores cargados, de la más cercana a la más
## lejana al jugador.
func _candidates() -> Array[Label3D]:
	var result: Array[Label3D] = []
	if _streamer == null or _target == null:
		return result
	var candidates: Array[Dictionary] = []
	for id: StringName in _streamer.get_loaded_ids():
		var node: Node3D = _streamer.get_loaded_node(id)
		if node == null:
			continue
		for label: Node in node.find_children("*", "Label3D", true, false):
			var label_3d: Label3D = label as Label3D
			if not label_3d.is_in_group(&"review_label"):
				continue
			var distance: float = (
				Vector2(
					label_3d.global_position.x - _target.global_position.x,
					label_3d.global_position.z - _target.global_position.z
				)
				. length()
			)
			candidates.append({"label": label_3d, "distance": distance})
	candidates.sort_custom(_closer)
	for candidate: Dictionary in candidates:
		var value: Variant = candidate["label"]
		if value is Label3D:
			result.append(value)
	return result


func _closer(first: Dictionary, second: Dictionary) -> bool:
	return str(first["distance"]).to_float() < str(second["distance"]).to_float()
