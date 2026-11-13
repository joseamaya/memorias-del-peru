class_name TourCompass
extends Control
## Brújula del museo explorable: un anillo y una flecha que apuntan al hito
## pendiente más cercano. La rotación la fija el HUD con
## [method set_target_angle]; la flecha apunta arriba con ángulo cero.

const RING_COLOR: Color = Color(0.96, 0.90, 0.72, 0.55)
const ARROW_COLOR: Color = Color(0.96, 0.90, 0.72, 0.95)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(_update_pivot)
	_update_pivot()


## Gira la flecha; el ángulo es relativo a la vista del jugador.
func set_target_angle(angle: float) -> void:
	rotation = angle


func _update_pivot() -> void:
	pivot_offset = size * 0.5


func _draw() -> void:
	var center: Vector2 = size * 0.5
	var radius: float = minf(size.x, size.y) * 0.34
	draw_arc(center, radius, 0.0, TAU, 28, RING_COLOR, 2.0, true)
	var arrow: PackedVector2Array = PackedVector2Array([
		center + Vector2(0.0, -radius * 0.95),
		center + Vector2(-radius * 0.5, radius * 0.55),
		center + Vector2(0.0, radius * 0.15),
		center + Vector2(radius * 0.5, radius * 0.55),
	])
	draw_colored_polygon(arrow, ARROW_COLOR)
