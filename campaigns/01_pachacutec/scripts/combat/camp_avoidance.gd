class_name CampAvoidance
extends RefCounted
## Evitación local de las tiendas del campamento.
##
## Ni [ChancaWarrior] ni [AlliedWarrior] usan navmesh: se mueven en línea recta
## hacia su objetivo. Cuando una tienda se cruza en ese camino, este módulo
## añade una componente tangencial para rodearla. No sustituye a un navmesh;
## resuelve el caso concreto de la batalla sin meter una IA de navegación
## completa en la slice.

## Distancia a la que se empieza a corregir el rumbo antes de tocar la tienda.
const LOOKAHEAD: float = 1.3
## Margen con el que se comprueba si un punto de aparición está libre.
const SPAWN_MARGIN: float = 0.5
## Empuje mínimo para salir de una tienda en la que ya se está dentro.
const MIN_PUSH: float = 0.6


## Indica si un punto está fuera de todas las tiendas con el margen dado.
static func is_clear(point: Vector3, tents: Array[CampLayout.Tent], margin: float) -> bool:
	for tent: CampLayout.Tent in tents:
		if flat_distance(point, tent.center) < tent.radius + margin:
			return false
	return true


## Indica si un punto cae dentro de la huella de alguna tienda.
static func inside_any(point: Vector3, tents: Array[CampLayout.Tent], margin: float = 0.0) -> bool:
	for tent: CampLayout.Tent in tents:
		if flat_distance(point, tent.center) < tent.radius + margin:
			return true
	return false


## Corrige una velocidad deseada para rodear las tiendas.
##
## `side_hint` desempata de forma estable cuando el objetivo está justo detrás
## de una tienda y el vector deseado es radial: sin desempate, el cuerpo se
## queda clavado contra el cono.
static func steer(
	desired: Vector3,
	position: Vector3,
	tents: Array[CampLayout.Tent],
	body_radius: float,
	side_hint: int = 0,
) -> Vector3:
	var flat: Vector3 = Vector3(desired.x, 0.0, desired.z)
	var speed: float = flat.length()
	if tents.is_empty():
		return flat
	var result: Vector3 = flat
	var heading: Vector3 = flat / speed if speed > 0.001 else Vector3.ZERO
	for tent: CampLayout.Tent in tents:
		var to_tent: Vector3 = tent.center - position
		to_tent.y = 0.0
		var distance: float = to_tent.length()
		var limit: float = tent.radius + body_radius + LOOKAHEAD
		if distance >= limit:
			continue
		var to_tent_dir: Vector3 = to_tent / distance if distance > 0.001 else Vector3.ZERO
		var inside: bool = distance < tent.radius + body_radius
		if not inside and heading.dot(to_tent_dir) <= 0.05:
			continue
		var away: Vector3 = -to_tent_dir
		if away.length_squared() < 0.0001:
			away = -heading if heading.length_squared() > 0.0001 else Vector3.FORWARD
		var side: Vector3 = Vector3(-away.z, 0.0, away.x)
		var side_sign: float = flat.dot(side)
		if absf(side_sign) < 0.01:
			side_sign = 1.0 if side_hint % 2 == 0 else -1.0
		side *= signf(side_sign)
		var depth: float = limit - distance
		var span: float = maxf(limit - (tent.radius + body_radius), 0.1)
		var weight: float = clampf(depth / span, 0.0, 1.0)
		var push: float = maxf(speed, MIN_PUSH) * weight
		result += side * push + away * push * 0.55
	if speed <= 0.001:
		return Vector3.ZERO if result.length_squared() <= 0.0001 else result.limit_length(MIN_PUSH)
	return result.limit_length(speed)


## Distancia plana entre dos puntos.
static func flat_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()
