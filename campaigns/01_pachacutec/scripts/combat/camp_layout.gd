class_name CampLayout
extends RefCounted
## Reparto geométrico de las tiendas del campamento chanca.
##
## Es la única fuente del layout: [CarmencaOverlook] dibuja las tiendas,
## [CarmencaSpawn] busca huecos libres y la batalla evita sus huellas. Las
## coordenadas son planas (y = 0) y relativas al centro del campamento; la
## altura la pone cada sistema con el terreno.


class Tent:
	extends RefCounted
	## Huella de una tienda: centro en horizontal, radio de la base y altura.

	var center: Vector3
	var radius: float
	var height: float
	var chief: bool

	func _init(at: Vector3, tent_radius: float, tent_height: float, is_chief: bool) -> void:
		center = at
		radius = tent_radius
		height = tent_height
		chief = is_chief


const COLUMNS: int = 4
const ROWS: int = 3
const SPACING: Vector2 = Vector2(9.0, 8.0)
const TENT_RADIUS: float = 2.2
const TENT_HEIGHT: float = 2.9
const CHIEF_INDEX: int = 5
const CHIEF_RADIUS_SCALE: float = 1.35
const CHIEF_HEIGHT_SCALE: float = 1.25


## Las doce tiendas del campamento, en el mismo orden que las dibuja el mirador.
static func tents(camp: Vector3) -> Array[Tent]:
	var result: Array[Tent] = []
	for row: int in ROWS:
		for column: int in COLUMNS:
			var index: int = row * COLUMNS + column
			var is_chief: bool = index == CHIEF_INDEX
			var radius: float = TENT_RADIUS * (CHIEF_RADIUS_SCALE if is_chief else 1.0)
			var height: float = TENT_HEIGHT * (CHIEF_HEIGHT_SCALE if is_chief else 1.0)
			result.append(Tent.new(camp + offset(index), radius, height, is_chief))
	return result


## Desplazamiento de una tienda respecto al centro del campamento.
static func offset(index: int) -> Vector3:
	var row: int = floori(float(index) / float(COLUMNS))
	var column: int = index % COLUMNS
	var x: float = (float(column) - 1.5) * SPACING.x
	var z: float = (float(row) - 1.0) * SPACING.y
	var jitter_x: float = float((index * 7) % 5) * 0.35
	var jitter_z: float = float((index * 3) % 4) * 0.30
	return Vector3(x + jitter_x, 0.0, z + jitter_z)
