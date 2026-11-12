class_name IntroMap
extends Control
## Mapa esquemático de la introducción (ADR-0025, ficha PCH-023).
##
## Solo muestra el Cusco al norte, la llacta al sur y el camino que las une,
## sobre un relieve de montañas dibujado. No marca territorios, fronteras ni
## pueblos vecinos: no debe adelantar la noticia que mide el cuestionario. La
## posición de la llacta es una reconstrucción (R): la llacta del juego no es
## un sitio real, y el Cusco queda al norte porque el camino del norte del
## juego es el que va al Cusco.

const CUSCO_KEY: StringName = &"PCH_MAP_CUSCO"
const LLACTA_KEY: StringName = &"PCH_MAP_LLACTA"
const NORTH_KEY: StringName = &"PCH_MAP_NORTH"

const BACKGROUND_COLOR: Color = Color(0.11, 0.09, 0.07, 1.0)
const RELIEF_COLOR: Color = Color(0.36, 0.3, 0.24, 1.0)
const ROAD_COLOR: Color = Color(0.78, 0.68, 0.52, 1.0)
const CUSCO_COLOR: Color = Color(0.88, 0.72, 0.32, 1.0)
const LLACTA_COLOR: Color = Color(0.95, 0.93, 0.88, 1.0)
const LABEL_SIZE: int = 30
## Zona del mapa, en fracción de la pantalla; deja libre el tercio inferior
## para el texto de la tarjeta.
const MAP_TOP: float = 0.08
const MAP_BOTTOM: float = 0.62
const MAP_HALF_WIDTH: float = 0.3
## Posiciones dentro de la zona del mapa (0–1).
const CUSCO_POINT: Vector2 = Vector2(0.56, 0.18)
const LLACTA_POINT: Vector2 = Vector2(0.46, 0.84)
const RELIEF_SEED: int = 1438
const RELIEF_PEAKS: int = 70


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


## Rectángulo de la zona del mapa en píxeles.
func map_rect() -> Rect2:
	var screen: Vector2 = size
	var left: float = screen.x * (0.5 - MAP_HALF_WIDTH)
	var top: float = screen.y * MAP_TOP
	return Rect2(left, top, screen.x * MAP_HALF_WIDTH * 2.0, screen.y * (MAP_BOTTOM - MAP_TOP))


## Posición en pantalla de un punto del mapa dado en fracciones (0–1).
func to_screen(point: Vector2) -> Vector2:
	var rect: Rect2 = map_rect()
	return rect.position + rect.size * point


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), BACKGROUND_COLOR)
	_draw_relief()
	_draw_road()
	var font: Font = get_theme_default_font()
	var cusco: Vector2 = to_screen(CUSCO_POINT)
	draw_circle(cusco, 14.0, CUSCO_COLOR)
	draw_arc(cusco, 22.0, 0.0, TAU, 32, CUSCO_COLOR, 2.0)
	_draw_label(font, tr(String(CUSCO_KEY)), cusco + Vector2(32.0, 10.0), CUSCO_COLOR)
	var llacta: Vector2 = to_screen(LLACTA_POINT)
	draw_circle(llacta, 9.0, LLACTA_COLOR)
	_draw_label(font, tr(String(LLACTA_KEY)), llacta + Vector2(24.0, 10.0), LLACTA_COLOR)
	_draw_north(font)


## Montañas como trazos en «^» repartidos con una semilla fija, para que el
## mapa sea siempre el mismo.
func _draw_relief() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = RELIEF_SEED
	var rect: Rect2 = map_rect()
	var keep_clear: Array[Vector2] = [to_screen(CUSCO_POINT), to_screen(LLACTA_POINT)]
	for index: int in range(RELIEF_PEAKS):
		var center: Vector2 = rect.position + Vector2(rng.randf() * rect.size.x, rng.randf() * rect.size.y)
		var width: float = rng.randf_range(26.0, 54.0)
		var height: float = width * rng.randf_range(0.45, 0.8)
		var clear: bool = true
		for point: Vector2 in keep_clear:
			if center.distance_to(point) < 70.0:
				clear = false
		if not clear:
			continue
		var peak: PackedVector2Array = [
			center + Vector2(-width * 0.5, height * 0.5),
			center + Vector2(0.0, -height * 0.5),
			center + Vector2(width * 0.5, height * 0.5),
		]
		draw_polyline(peak, RELIEF_COLOR, 2.0, true)


## Camino de la llacta al Cusco, a trazos y con una curva suave.
func _draw_road() -> void:
	var start: Vector2 = to_screen(LLACTA_POINT)
	var end: Vector2 = to_screen(CUSCO_POINT)
	var bend: Vector2 = (start + end) * 0.5 + Vector2(-60.0, 0.0)
	var points: PackedVector2Array = []
	var steps: int = 40
	for index: int in range(steps + 1):
		var t: float = float(index) / float(steps)
		points.append(start.lerp(bend, t).lerp(bend.lerp(end, t), t))
	for index: int in range(0, steps, 2):
		draw_line(points[index], points[index + 1], ROAD_COLOR, 3.0, true)


func _draw_north(font: Font) -> void:
	var rect: Rect2 = map_rect()
	var base: Vector2 = rect.position + Vector2(rect.size.x - 20.0, 70.0)
	var arrow: PackedVector2Array = [base + Vector2(-12.0, 0.0), base + Vector2(0.0, -40.0), base + Vector2(12.0, 0.0)]
	draw_colored_polygon(arrow, LLACTA_COLOR)
	_draw_label(font, tr(String(NORTH_KEY)), base + Vector2(-9.0, 32.0), LLACTA_COLOR)


func _draw_label(font: Font, text: String, position_px: Vector2, color: Color) -> void:
	draw_string_outline(font, position_px, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, LABEL_SIZE, 6, Color(0.0, 0.0, 0.0, 1.0))
	draw_string(font, position_px, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, LABEL_SIZE, color)
