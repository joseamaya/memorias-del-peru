class_name CarmencaSpawn
extends RefCounted
## Anillo de aparición de la batalla de Carmenca.
##
## Sin estado: la batalla y las pruebas comparten el mismo cálculo. Cada hueco
## tiene un radio algo distinto para que la oleada no salga en un círculo
## perfecto. Si el hueco cae sobre el jugador, se refleja al lado opuesto para
## que ningún chanca nazca a su espalda.

## Radio máximo del anillo alrededor del campamento.
const RADIUS: float = 13.0
## Ningún chanca aparece más cerca que esto del jugador.
const MIN_DISTANCE: float = 6.0


## Punto del anillo para un hueco de oleada, en horizontal.
static func offset(center: Vector3, slot: int, count: int, player_position: Vector3) -> Vector3:
	var angle: float = TAU * float(slot) / float(maxi(count, 1))
	var radius: float = RADIUS * (0.6 + 0.4 * float((slot * 7) % 5) / 4.0)
	var point: Vector3 = center + Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)
	var flat: Vector2 = Vector2(point.x - player_position.x, point.z - player_position.z)
	if flat.length() < MIN_DISTANCE:
		point = center - Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)
	return point
