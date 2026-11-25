class_name CarmencaSpawn
extends RefCounted
## Anillo de aparición de la batalla de Carmenca.
##
## Sin estado: la batalla y las pruebas comparten el mismo cálculo. Cada hueco
## tiene un radio algo distinto para que la oleada no salga en un círculo
## perfecto. Si el hueco cae sobre el jugador, se refleja al lado opuesto para
## que ningún chanca nazca a su espalda. Si cae dentro de una tienda, se busca
## el punto libre más cercano: nacer dentro del cono dejaba al chanca atrapado
## contra la tienda y la oleada no cerraba.

## Radio máximo del anillo alrededor del campamento.
const RADIUS: float = 13.0
## Ningún chanca aparece más cerca que esto del jugador.
const MIN_DISTANCE: float = 6.0
## Tope de la búsqueda hacia fuera cuando el anillo cae dentro de una tienda.
const MAX_RADIUS: float = 24.0
## Margen libre alrededor de la tienda para el cuerpo del chanca.
const CLEARANCE: float = 0.5
## Escalas de radio que se prueban, de la más cercana al campamento a la más lejana.
const SEARCH_SCALES: Array[float] = [1.0, 1.2, 1.45, 1.7, 2.0]
## Barrido angular alrededor del hueco base, en radianes (0, ±5°, ±10°…).
const SEARCH_ANGLES: Array[float] = [
	0.0,
	0.0872665,
	-0.0872665,
	0.174533,
	-0.174533,
	0.261799,
	-0.261799,
	0.349066,
	-0.349066,
	0.436332,
	-0.436332,
]


## Punto del anillo para un hueco de oleada, en horizontal y libre de tiendas.
static func offset(
	center: Vector3,
	slot: int,
	count: int,
	player_position: Vector3,
	tents: Array[CampLayout.Tent] = [],
) -> Vector3:
	var angle: float = TAU * float(slot) / float(maxi(count, 1))
	var radius: float = RADIUS * (0.6 + 0.4 * float((slot * 7) % 5) / 4.0)
	var base: Vector3 = center + Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)
	if CampAvoidance.flat_distance(base, player_position) < MIN_DISTANCE:
		angle += PI
	return _search(center, angle, radius, player_position, tents)


## Punto libre más cercano a `preferred`, alrededor de `center`.
##
## Lo usan los aliados, que nacen a 4,5 m del jugador y también pueden caer
## dentro de una tienda.
static func clear_near(
	center: Vector3, preferred: Vector3, tents: Array[CampLayout.Tent]
) -> Vector3:
	if tents.is_empty() or CampAvoidance.is_clear(preferred, tents, CLEARANCE):
		return preferred
	var flat: Vector3 = Vector3(preferred.x - center.x, 0.0, preferred.z - center.z)
	var radius: float = maxf(flat.length(), 1.0)
	var angle: float = atan2(flat.z, flat.x) if flat.length_squared() > 0.0001 else 0.0
	return _search(center, angle, radius, center, tents, 0.0)


## Busca el primer punto libre probando radios crecientes y un barrido angular.
##
## `min_distance` se mide contra `player_position`; para los aliados es 0.
static func _search(
	center: Vector3,
	base_angle: float,
	base_radius: float,
	player_position: Vector3,
	tents: Array[CampLayout.Tent],
	min_distance: float = MIN_DISTANCE,
) -> Vector3:
	for scale: float in SEARCH_SCALES:
		var radius: float = minf(base_radius * scale, MAX_RADIUS)
		for step: float in SEARCH_ANGLES:
			var angle: float = base_angle + step
			var candidate: Vector3 = center + Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)
			if CampAvoidance.flat_distance(candidate, player_position) < min_distance:
				continue
			if CampAvoidance.is_clear(candidate, tents, CLEARANCE):
				return candidate
	# El radio máximo queda fuera de las doce tiendas; se devuelve el borde
	# exterior antes que un punto dentro de una huella.
	var fallback_angle: float = base_angle
	return center + Vector3(cos(fallback_angle) * MAX_RADIUS, 0.0, sin(fallback_angle) * MAX_RADIUS)
